<script lang="ts">
    import type { Clip } from '@backend/types';
    import { timelineSpacing } from "$lib/constants";
    import { OnCursor, Selected, Client } from "$lib/stores";

    let {
        clip,
        style = '',
        scale,
        beat = 0,
        onresize = () => {},
    }: { clip: Clip, style: string, scale: number, beat: number, onresize: (side: 'left' | 'right') => any } = $props();

    function onclick(e: Event) {
        if(!$OnCursor) {
            $Selected = { type: 'clip', clip: clip };
        }
    }

    function resize(event: MouseEvent, side: 'left' | 'right') {
        if(event.button != 0) return;
        onresize(side);
    }
</script>

<clip 
    onclick={onclick}
    class={$Selected && $Selected.type == 'clip' && $Selected.clip.id == clip.id ? 'selected': ''}
    style="{style}; background: {clip.effects[0].params[0].value}; left: {scale * timelineSpacing * beat}px; width: {scale * timelineSpacing * (clip.end - clip.start)}px;">

    <span style="background-color: #333;">{clip.name}</span>
    <grab id="left" onmousedown={(e: MouseEvent) => resize(e, 'left')}></grab>
    <grab id="right" onmousedown={(e: MouseEvent) => resize(e, 'right')}></grab>
</clip>

<style>
    clip {
        display: block;
        position: absolute;
        box-sizing: border-box;
        height: 80px;
        max-height: 80px;
        padding: calc(var(--spacing)/4);

        background: #333;
        border-radius: calc(var(--rounding)/2);
        border: var(--border);
    }

    grab {
        position: absolute;
        top: 0px;
        bottom: 0px;
        width: 10px;
        z-index: 2;
    }

    #left {
        left: 0px;
        cursor: url(/ClipScaleLeft.svg) 0 8,auto;
    }

    #right {
        right: 0px;
        cursor: url(/ClipScaleRight.svg) 8 8,auto;
    }

    .selected {
        border: var(--white-border);
    }

    span {
        display: block;
        width: 100%;
        max-width: 100%;
        box-sizing: border-box;
        text-overflow: ellipsis;
        overflow: hidden;
        border-radius: .5rem;
        width: fit-content;
        padding: .5rem;
        user-select: none;
    }
</style>
