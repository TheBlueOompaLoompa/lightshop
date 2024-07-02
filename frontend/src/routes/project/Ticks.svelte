<script lang="ts">
    import { time2beats, beats2time, snap } from "$lib/util";
    import { Snapping } from "$lib/stores";
    import { timelineSpacing } from "$lib/constants";

    let { scale, beats, snapping, onretime }: { scale: number, beats: number, snapping: number, onretime: (beat: number) => any } = $props();

    let realSnap = $derived(snapping <= 0 ? 2 : snapping);

    const spacing = timelineSpacing;

    let ticksWidth = $state(0);
    let tickCount = $derived(Math.ceil(ticksWidth / spacing * realSnap / scale) + realSnap);
    let numberCount = $derived(Math.ceil(tickCount / realSnap));

    let moving = false;

    let numbersElement: HTMLElement;

    function onmousemove(event: MouseEvent) {
        const rect = numbersElement.getBoundingClientRect();
        if(moving) {
            onretime(snap((event.pageX - rect.left) / timelineSpacing / scale, $Snapping) + beats);
        }
    }

    function onmousedown() {
        moving = true;
    }

    window.addEventListener('mouseup', () => {
        moving = false;
    });
</script>

<svelte:window {onmousemove} />

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<numbers {onmousedown} bind:this={numbersElement}>
    {#each {length: numberCount } as _, i}
        <span class="retiming" style="left: {spacing * scale * i - beats % 1 * spacing * scale}px"
        >{i + Math.floor(beats)}</span>
    {/each}
</numbers>
<ticks {onmousedown} bind:clientWidth={ticksWidth}>
    {#each {length: tickCount } as _, i}
        <tick style="left: {spacing * scale * i / realSnap - beats % 1 * spacing * scale}px">
            <tli class={`${i % realSnap == 0 ? 'long' : ''} ${snapping == 0 ? 'dot': ''}`}></tli>
        </tick>
    {/each}
</ticks>


<style>
    ticks, numbers {
        display: flex;
        align-items: center;
        justify-content: space-evenly;
        height: 1rem;
        min-height: 1rem;
        position: relative;

        --weird-margin: calc(200px + var(--spacing)*2 + .2rem);

        width: 100%;
        max-width: calc(100% - var(--weird-margin));
        overflow-x: hidden;
        margin-left: var(--weird-margin);
        user-select: none;
    }

    tick {
        position: absolute;
        display: flex;
        flex-direction: column;
        height: 100%;
        width: 0px;
    }

    tli {
        width: 1px;
        height: 20%;
        border-left: 2px white solid;
    }

    tli.dot {
        border-left: 2px gray solid;
    }

    .long {
        height: 60%;
    }

    span {
        position: absolute;
        font-size: x-small;
        width: 0px;
    }
</style>
