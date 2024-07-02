<script lang="ts">
    import Clip from "$components/Clip.svelte";
    import { OnCursor, Snapping, TimelineHover, Selected, Client, NextStart, HoverBeat } from "$lib/stores";
    import { beats2px, px2beats, snap } from "$lib/util";
    import { type CursorBasket, SCursorBasket } from "$lib/types";

    let { timelineScale, beats }: { timelineScale: number, beats: number } = $props();

    let x = $state(0);
    let y = $state(0);

    let saveEnd = -1;

    function endPlaceBound(depth = 0) {
        if($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip.end != undefined) {
            if($NextStart > 0 && $OnCursor.clip.end + $HoverBeat > $NextStart) {
                if(saveEnd == -1) saveEnd = $OnCursor.clip.end;
                $OnCursor.clip.end = $NextStart - $HoverBeat;
            }else {
                if(saveEnd > -1) $OnCursor.clip.end = saveEnd;
                saveEnd = -1;
                if(depth < 4) endPlaceBound(depth + 1);
            }
        }
    }

    window.addEventListener('mousemove', event => {
        x = event.pageX;
        y = event.pageY;
        if($TimelineHover) {
            if($Snapping > 0) {
                let beatsLeft = snap(px2beats(x - $TimelineHover.x + beats2px(beats, timelineScale), timelineScale), $Snapping);
                x = beats2px(beatsLeft, timelineScale) + $TimelineHover.x - beats2px(beats, timelineScale);
            }

            endPlaceBound();

            y = $TimelineHover.y + 10;
        }else {
            if($OnCursor && $OnCursor.type == 'clip' && $OnCursor.clip.end != undefined && saveEnd > -1) $OnCursor.clip.end = saveEnd;
        }
    });

    window.addEventListener('keydown', async event => {
        if(event.key == 'Escape') {
            $OnCursor = undefined;
            $Selected = undefined;
        }

        if(event.key == 'Delete') {
            if($Selected) await deleteThing($Selected);
            else if($OnCursor) await deleteThing($OnCursor);
        }

        if(event.ctrlKey) {
            switch(event.key) {
            case 'c':
                await navigator.clipboard.writeText(JSON.stringify($Selected));
                break;
            case 'v':
                $OnCursor = SCursorBasket.parse(JSON.parse(await navigator.clipboard.readText()));
                if($OnCursor && $OnCursor.type == "clip" && $OnCursor.clip) {
                    $OnCursor.clip.end -= $OnCursor.clip.start;
                    $OnCursor.clip.start = 0;
                }
                break;
            }
        }
    });

    async function deleteThing(thing: CursorBasket) {
        switch(thing?.type) {
            case 'clip':
                await $Client.clips.delete.mutate(thing.clip.id);
                thing = undefined;
                break;
        }
    }
</script>

<div class={!$TimelineHover ? 'fade' : ''}>
    <cursor style="inset: 0px; left: {x}px; top: {y}px;">
        {#if $OnCursor}
            {#if $OnCursor.type == 'clip'}
            <Clip clip={$OnCursor.clip} scale={timelineScale} style=""/>
            {/if}
        {/if}
    </cursor>
</div>

<style>
    div {
        position: absolute;
        inset: 0px;
        pointer-events: none;
        overflow: hidden;

        opacity: .7;
    }

    cursor {
        display: flex;
        position: relative;
        z-index: 9999;
    }

    .fade {
        opacity: 0.3;
    }
</style>
