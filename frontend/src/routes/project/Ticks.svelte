<script lang="ts">
    import { time2beats, beats2time, snap } from "$lib/util";
    import { timelineSpacing } from "$lib/constants";

    let { scale, beats, snapping, onretime }: { scale: number, beats: number, snapping: number, onretime: () => any } = $props();

    const spacing = timelineSpacing;

    let ticksWidth = $state(0);
    let tickCount = $derived(Math.ceil(ticksWidth / spacing * snapping / scale) + snapping);
    let numberCount = $derived(Math.ceil(tickCount / snapping));
    //$: numberCount = Math.floor(seconds2beats($Length, $Bpm));

    let moving = false;

    function moveTime(event: any) {
/*        if(moving) {
            $Playing = false;
            $Time = snap(event.offsetX / 10 / $TimelineScale, $Snapping, $Bpm) - ($Offset / 1000);
        }*/
    }

    function startMove() {
        moving = true;
    }

    window.addEventListener('mouseup', () => {
        moving = false;
    });
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<numbers onmousedown={startMove} onmousemove={moveTime}>
    {#each {length: numberCount } as _, i}
        <span class="retiming" style="left: {spacing * scale * i - beats % 1 * spacing * scale}px"
        >{i + Math.floor(beats)}</span>
    {/each}
</numbers>
<ticks bind:clientWidth={ticksWidth}>
    {#each {length: tickCount } as _, i}
        <tick style="left: {spacing * scale * i / snapping - beats % 1 * spacing * scale}px">
            <tli class={i % snapping == 0 ? 'long' : ''}></tli>
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
        background-color: white;
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
