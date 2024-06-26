<script lang="ts">
    import { Bpm, Time, TimelineScale, Playing, Offset } from '$lib/stores';
    import { snap } from '$lib/util';
    import Head from '../../assets/head.svg?raw';

    export let tracks: any[];

    let playheadElement: HTMLElement;
    let svgContainerElement: HTMLDivElement;
    let svgElement: SVGSVGElement;

    $: if(svgContainerElement) {
        svgElement = svgContainerElement.getElementsByTagName('svg')[0];
    }

    $: if(svgElement) {
        svgElement.style.left = `${-svgElement.clientWidth/2}px`;
    }

    $: if(playheadElement) {
        playheadElement.style.left = `${($Time + ($Offset/1000)) * 10 * $TimelineScale}px`;
    }
</script>

<playhead class="retiming" bind:this={playheadElement}>
    <div bind:this={svgContainerElement}>
        {@html Head}
    </div>
    <headline style="height: calc(var(--min-track-height) * {tracks.length} + 1rem + (var(--spacing) * {tracks.length} * 2 + var(--spacing) * 3))"/>
</playhead>

<style>
    playhead {
        position: absolute;
        top: 0px;
        left: 0px;
        width: 0;
        height: 0;
        z-index: 1;
    }

    headline {
        display: inline-block;
        background-color: red;
        width: 1px;
    }

    div {
        height: 1rem;
        position: relative;
    }
</style>