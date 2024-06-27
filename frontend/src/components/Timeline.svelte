<script lang="ts">
    import Clip from '$components/Clip.svelte';
    import { TimelineHover, OnCursor, Snapping, Client, Project } from '$lib/stores';
    import { px2beats, beats2px, snap } from '$lib/util';
    import type { Clip as TClip } from '@backend/types';
    import _ from 'lodash';
	import Playhead from '../routes/project/Playhead.svelte';

    export let clip: TClip;
    export let scale = 2;
    export let beats = 0;

    let main: HTMLElement;
    let clips: TClip[] = [];

    let hoverBeat = 0;

    // Remove clips when deleted on server
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

        const rect = main.getBoundingClientRect();
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
        // When user clicks with clip on cursor
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

    let resizingClip: TClip | undefined;
    let resizeSide: 'left' | 'right';

    function onresizeClip(side: 'left' | 'right', clip: TClip) {
        resizeSide = side;
        resizingClip = clip;
    }

    function resizeMouseMove(event: MouseEvent) {
        const rect = main.getBoundingClientRect();
        hoverBeat = snap(px2beats(event.pageX - rect.x + beats2px(beats, scale), scale), $Snapping);

        if(resizingClip) {
            // Verify not overlapping other clips
            for(let i = 0; i < clips.length; i++) {
                if(
                    clips[i] != resizingClip &&
                    (
                    (clips[i].start < hoverBeat && clips[i].end > hoverBeat) ||
                    (clips[i].start < hoverBeat && clips[i].end <= hoverBeat && resizingClip.start < clips[i].start) ||
                    (clips[i].start >= hoverBeat && clips[i].end > hoverBeat && resizingClip.end > clips[i].end)
                    )
                ) {
                    return;
                }
            }

            if(resizeSide == 'left' && resizingClip.end > hoverBeat) resizingClip.start = hoverBeat;
            else if(resizingClip.start < hoverBeat) resizingClip.end = hoverBeat;
            resizingClip = resizingClip;
            clips = clips;
        }
    }

    window.addEventListener('mouseup', () => {
        resizingClip = null;
    });
</script>

<svelte:window onmousemove={resizeMouseMove} />

<timeline class="timeline" {onmousemove}>
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
        <Clip {clip} {scale} beat={clip.start - beats} onresize={(side) => {onresizeClip(side, clip)}}/>
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
        height: 100px;
        border: var(--white-border);
        border-radius: calc(var(--rounding)/2);
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
