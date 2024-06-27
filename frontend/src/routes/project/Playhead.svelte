<script lang="ts">
    import { snap } from '$lib/util';
    import Head from '../../assets/head.svg?raw';

    export let trackCount: number = 1;
    export let beat = 1;

    let playheadElement: HTMLElement;
    let svgContainerElement: HTMLDivElement;
    let svgElement: SVGSVGElement;

    $: if(svgContainerElement) {
        svgElement = svgContainerElement.getElementsByTagName('svg')[0];
    }

    $: if(svgElement) {
        svgElement.style.height = '1rem';
        svgElement.style.width = '1rem';
    }
</script>

<playhead class="retiming" bind:this={playheadElement} style="left: calc({beat * 20 * 2 + 200}px + var(--spacing) * 2);">
    <div bind:this={svgContainerElement} style="left: calc(-1rem/4);">
        {@html Head}
    </div>
    <headline style="height: calc(100px * {trackCount} + 1rem + 1px)"></headline>
</playhead>

<style>
    playhead {
        position: absolute;
        top: 0px;
        left: 0px;
        width: 0;
        height: 0;
        z-index: 1;
        pointer-events: none;
    }

    headline {
        position: absolute;
        display: inline-block;
        background-color: red;
        width: 1px;
        left: .2rem;
    }

    div {
        height: 1rem;
        position: relative;
    }
</style>
