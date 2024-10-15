<script lang="ts">
    import Clip from '$components/Clip.svelte';
    import { TimelineHover, OnCursor, Snapping, Client, Project, NextStart, HoverBeat } from '$lib/stores';
    import { px2beats, beats2px, snap } from '$lib/util';
    import type { Clip as TClip } from '@backend/types';
    import { clientId } from '$lib/trpc';
    import _ from 'lodash';

    export let clip: TClip;
    export let scale = 2;
    export let beats = 0;

    let main: HTMLElement;
    let clips: TClip[] = [];


    $: {
        if($Client) {
            $Client.clips.update.mutate(clip);
        }
    }

    Client.subscribe(async client => {
        if(client) {
            // Initial load
            clips = await client.clips.listChildren.query(clip.id);

            // Remove clips when deleted on server
            client.clips.onDelete.subscribe(undefined, {
                onData(clip: TClip) {
                    clips = clips.toSpliced(clips.findIndex(c => c.id == clip.id), 1);
                }
            });

            client.clips.onUpdate.subscribe(undefined, {
                onData(data: any) {
                    const { id, clip: nclip } = data;
                    if(id == clientId) return;
                    const idx = clips.findIndex(c => c.id == nclip.id);
                    if(idx > -1) clips = clips.toSpliced(idx, 1, nclip);
                }
            });

            client.clips.onNew.subscribe(undefined, {
                onData(data: any) {
                    const { id, clip: nclip } = data;
                    if(id == clientId) return;
                    clips = [...clips, nclip];
                }
            });
        }
    });

    function onmousemove(event: MouseEvent) {
        if(!($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip)) return;
        if($OnCursor.clip.targetType != clip.targetType && !($OnCursor.clip.targetType == 'linear' && clip.targetType == 'spatial')) return;

        const rect = main.getBoundingClientRect();
        $TimelineHover = { x: rect.x, y: rect.y };
        $NextStart = 0;
        clips.forEach(clip => {
            if(clip.start >= $HoverBeat && ($NextStart == 0 || clip.start < $NextStart)) $NextStart = clip.start;
            if(!($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip && $OnCursor.clip.start != undefined && $OnCursor.clip.end != undefined)) return;
            if(
                clip.start < ($OnCursor.clip.start + $HoverBeat) && (clip.end > $OnCursor.clip.start + $HoverBeat) ||
                clip.start == ($OnCursor.clip.start + $HoverBeat) && (clip.end == $OnCursor.clip.end + $HoverBeat) ||
                clip.start == $HoverBeat
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
        if($OnCursor && $OnCursor.type == 'clip' && ($OnCursor.clip.targetType == clip.targetType || ($OnCursor.clip.targetType == 'linear' && clip.targetType == 'spatial')) && $TimelineHover) {
            let newClip: Clip = {} as Clip;
            Object.assign(newClip, $OnCursor.clip);
            newClip.start += $HoverBeat;
            newClip.end += $HoverBeat;
            newClip.parent = clip.id;
            newClip.pool = '';
            newClip.id = undefined;
            newClip.project = $Project.name;

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
        $HoverBeat = snap(px2beats(event.pageX - rect.x + beats2px(beats, scale), scale), $Snapping);

        if(resizingClip) {
            // Verify not overlapping other clips
            for(let i = 0; i < clips.length; i++) {
                if(
                    clips[i] != resizingClip &&
                    (
                    (clips[i].start < $HoverBeat && clips[i].end > $HoverBeat) ||
                    (clips[i].start < $HoverBeat && clips[i].end <= $HoverBeat && resizingClip.start < clips[i].start) ||
                    (clips[i].start >= $HoverBeat && clips[i].end > $HoverBeat && resizingClip.end > clips[i].end)
                    )
                ) {
                    return;
                }
            }

            if(resizeSide == 'left' && resizingClip.end > $HoverBeat) resizingClip.start = $HoverBeat;
            else if(resizingClip.start < $HoverBeat) resizingClip.end = $HoverBeat;
            resizingClip = resizingClip;
            clips = clips;
            $Client.clips.update.mutate(resizingClip);
        }
    }

    window.addEventListener('mouseup', () => {
        resizingClip = null;
    });
</script>

<svelte:window onmousemove={resizeMouseMove} />

<timeline class="timeline" {onmousemove}>
    <div class="side">
        <span contenteditable="true" bind:textContent={clip.name}></span>
        <span style="font-size: small; color: gray;">{clip.targetType}</span>
    </div>
    <div class="main" role="feed" {onmousemove} {onmouseout} onblur={onmouseout} {onclick} bind:this={main}>
        {#each clips as clip}
        {#if clip.end >= beats}
        <Clip style="" {clip} {scale} beat={clip.start - beats} onresize={(side) => {onresizeClip(side, clip)}}/>
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
