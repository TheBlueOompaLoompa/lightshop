<script lang="ts">
    import Clip from '$components/Clip.svelte';
    import { TimelineHover, OnCursor, Snapping, Client, Project } from '$lib/stores';
    import { px2beats, beats2px, snap } from '$lib/util';
    import type { Clip as TClip } from '@backend/types';
    import _ from 'lodash';

    export let clip: TClip;
    export let scale = 2;
    export let beats = 0;

    let main: HTMLElement;
    let clips: TClip[] = [];

    let hoverBeat = 0;

    Client.subscribe(async client => {
        if(client) {
            clips = await client.clips.listChildren.query(clip.id);

            client.clips.onDelete.subscribe(undefined, {
                onData(clip: TClip) {
                    clips = clips.toSpliced(clips.findIndex(c => c.id == clip.id), 1);
                }
            });
        }
    })

    function onmousemove(event: MouseEvent) {
        if(!($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip)) return;
        if($OnCursor.clip.targetType != clip.targetType) return;

        const rect = main.getBoundingClientRect()
        hoverBeat = snap(px2beats(event.pageX - rect.x + beats2px(beats, scale), scale), $Snapping);
        $TimelineHover = { x: rect.x, y: rect.y };
        clips.forEach(clip => {
            if(
                clip.start < ($OnCursor.clip.start + hoverBeat) && (clip.end > $OnCursor.clip.start + hoverBeat) ||
                clip.start < ($OnCursor.clip.end + hoverBeat) && (clip.end > $OnCursor.clip.end + hoverBeat) ||
                clip.start == ($OnCursor.clip.start + hoverBeat) && (clip.end == $OnCursor.clip.end + hoverBeat)
            ) {
                $TimelineHover = undefined;
                return;
            }
        });
    }

    function onmouseout() {
        $TimelineHover = undefined;
    }

    async function onclick() {
        if($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip.targetType == clip.targetType && $TimelineHover) {
            let newClip: Clip = {} as Clip;
            Object.assign(newClip, $OnCursor.clip);
            newClip.start += hoverBeat;
            newClip.end += hoverBeat;
            newClip.parent = clip.id;
            newClip.pool = '';
            newClip.id = undefined;
            newClip.project = $Project.name;

            $OnCursor = { type: undefined, clip: undefined };
            $OnCursor = undefined;
            
            clips = [...clips, ...(await $Client.clips.new.mutate(newClip))];
        }
    }
</script>

<timeline class="timeline">
    <div class="side">
        {#if clip.type == 'composite'}
        <span contenteditable="true" bind:textContent={clip.name}></span>
        {:else}
        <span>{clip.name}</span>
        {/if}
        <span style="font-size: small; color: gray;">{clip.targetType}</span>
    </div>
    <div class="main" role="feed" {onmousemove} {onmouseout} onblur={onmouseout} {onclick} bind:this={main}>
    {#each clips as clip}
    {#if clip.end >= beats}
    <Clip {clip} {scale} beat={clip.start - beats}/>
    {/if}
    {/each}
    </div>
</timeline>

<style>
    div {
        display: flex;
        padding: var(--spacing);
    }

    timeline {
        display: flex;
        width: 100%;
        height: 100%;
        border: var(--white-border);
        border-radius: calc(var(--rounding)/2);
    }

    span {
        user-select: none;
    }

    .side {
        border-right: var(--white-border);
        min-width: 200px;
        max-width: 200px;
        flex-direction: column;
    }

    .main {
        display: flex;
        flex-direction: row;
        align-items: center;
        position: relative;
        width: 100%;
        overflow: hidden;
    }

    span[contenteditable="true"] {
        border: .1rem #333 solid;
        border-radius: var(--rounding);
        padding: calc(var(--spacing)/2);
    }

    span[contenteditable="true"]:hover {
        border: .15rem white dotted;
    }
</style>
