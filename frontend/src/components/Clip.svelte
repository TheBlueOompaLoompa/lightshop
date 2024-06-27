<script lang="ts">
    import type { Clip } from '@backend/types';
    import { timelineSpacing } from "$lib/constants";
    import { OnCursor, Selected } from "$lib/stores";

    export let clip: Clip;
    export let style: string = '';
    export let scale: number;
    export let beat: number = 0;
    export let onresize: (side: 'left' | 'right') => any = () => {};

    function onclick(e: Event) {
        if(!$OnCursor) {
            $Selected = { type: 'clip', clip: clip };
        }
    }

    function resize(event: Event, side: 'left' | 'right') {
        onresize(side);
    }
</script>

<clip 
    on:click={onclick}
    class={$Selected && $Selected.type == 'clip' && $Selected.clip.id == clip.id ? 'selected': ''}
    style="{style}; background: {clip.params[0].value}; left: {scale * timelineSpacing * beat}px; width: {scale * timelineSpacing * (clip.end - clip.start)}px;">

    <span style="background-color: #333;">{clip.name}</span>
    <grab id="left" on:mousedown={(e: Event) => resize(e, 'left')}></grab>
    <grab id="right" on:mousedown={(e: Event) => resize(e, 'right')}></grab>
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
        border-radius: var(--rounding);
        border: var(--border);
    }

    grab {
        position: absolute;
        top: 0px;
        bottom: 0px;
        width: 20px;
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
