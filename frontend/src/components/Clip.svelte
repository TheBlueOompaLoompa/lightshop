<script lang="ts">
    import type { Clip } from '@backend/types';
    import { timelineSpacing } from "$lib/constants";
    import { OnCursor, Selected } from "$lib/stores";

    export let clip: Clip;
    export let style: string = '';
    export let scale: number;
    export let beat: number = 0;

    function onclick(e: Event) {
        e.stopPropagation();
        if(!$OnCursor) {
            $Selected = { type: 'clip', clip: clip };
        }
    }
</script>

<clip 
    on:click={onclick}
    class={$Selected && $Selected.type == 'clip' && $Selected.clip.id == clip.id ? 'selected': ''}
    style="{style}; background: {clip.params[0].value}; left: {scale * timelineSpacing * beat}px; width: {scale * timelineSpacing * (clip.end - clip.start)}px;">
    <span style="background-color: #333;">{clip.name}</span>
</clip>

<style>
    clip {
        display: block;
        position: absolute;
        box-sizing: border-box;
        height: 80px;
        max-height: 80px;

        background: #333;
        padding: calc(var(--spacing)/4);
        border-radius: var(--rounding);
        border: var(--border);
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
    }
</style>
