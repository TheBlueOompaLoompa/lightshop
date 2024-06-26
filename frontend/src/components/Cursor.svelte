<script lang="ts">
    import Clip from "$components/Clip.svelte";
    import { OnCursor, Snapping, TimelineHover, Selected, Client } from "$lib/stores";
    import { beats2px, px2beats, snap } from "$lib/util";
    import type { CursorBasket } from "$lib/types";

    let { timelineScale, beats }: { timelineScale: number, beats: number } = $props();

    let x = $state(0);
    let y = $state(0);

    window.addEventListener('mousemove', event => {
        x = event.pageX;
        y = event.pageY;
        if($TimelineHover) {
            if($Snapping > 0) {
                let beatsLeft = snap(px2beats(x - $TimelineHover.x + beats2px(beats, timelineScale), timelineScale), $Snapping);
                x = beats2px(beatsLeft, timelineScale) + $TimelineHover.x - beats2px(beats, timelineScale);
            }

            y = $TimelineHover.y + 10;
        }
    });

    window.addEventListener('keydown', async event => {
        if(event.key == 'Escape') {
            $OnCursor = {};
            $OnCursor = undefined;
            $Selected = {};
            $Selected = undefined;
        }

        if(event.key == 'Delete') {
            if($Selected) await deleteThing($Selected);
            else if($OnCursor) await deleteThing($OnCursor);
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
            <Clip clip={$OnCursor.clip} scale={timelineScale}/>
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
