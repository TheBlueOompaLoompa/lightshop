<script lang="ts">
    import Timeline from "$components/Timeline.svelte";
    import Ticks from "./Ticks.svelte";
    import type { Clip, Project, Bpm } from "@backend/types";
    import { Client, FPS, Snapping } from '$lib/stores';
    import { beats2time } from '$lib/util';
    import { time2beats } from '@backend/util';
	import Playhead from "./Playhead.svelte";

    let { project, scale = $bindable(2), beats = $bindable(0) }:
        { project: Project, scale: number, beats: number } = $props();
    let bpms: Bpm[] = [];

    Client.subscribe(async client => {
        if(client) {
            bpms = await client.bpm.listEvents.query(project.name);
            clips = await client.clips.list.query({ pool: 'Roots', project: project.name });
        }
    });

    const audioCtx = new AudioContext();
    let latency = $derived(audioCtx.outputLatency * 1000);

    let time = $state(0);
    let minutes = $state(0);
    let seconds = $state(0);

    function onChangeTime() {
        player.currentTime = minutes * 60 + seconds;
        time = player.currentTime * 1000 + project.offset - latency;
    }

    let startTime = 0;
    let player: HTMLAudioElement = new Audio(project.music);

    $effect(() => {
        let timeLeft = time;
        beats = Math.max(time2beats(timeLeft, bpms, project.tempo), 0);

        $Client.player.setTime.mutate(beats);
    });


    const updateTimes = () => { minutes = Math.floor(player.currentTime / 60); seconds = player.currentTime % 60; }

    let lastTime = 0;
    async function timing() {
        const timeDiff = Date.now() - lastTime;

        if(timeDiff > 1000/$FPS) {
            time = player.currentTime*1000 + project.offset - latency;
            lastTime = Date.now();

            updateTimes();
        }

        if(time >= project.time * 1000) player.pause();
        if(!player.paused) window.requestAnimationFrame(timing);
    }

    function playPause() {
        if(player.paused) {
            player.play();
            lastTime = Date.now();
            time = player.currentTime*1000 + project.offset - latency;
            startTime = time;
            
            timing();
        }else {
            player.pause();
        }
    }

    function stop() {
        if(!player.paused) {
            player.pause();
            player.currentTime = startTime/1000;
            time = player.currentTime*1000 - project.offset - latency;
        }else {
            player.currentTime = 0;
            time = 0;
        }

        updateTimes();
    }

    let timelineBody: HTMLElement;
    $effect(() => {
        if(timelineBody) {
            timelineBody.addEventListener("wheel", onwheel, { passive: false })
        }
    });

    const zoomSpeed = .001;
    const wheelMultiplier = 2;
    function onwheel(e: WheelEvent) {
        e.preventDefault();
        if(e.ctrlKey) {
            scale -= e.deltaY * zoomSpeed * wheelMultiplier;
            scale = Math.max(scale, 0.5);
        }else {
            time = Math.max(time - (e.deltaX != 0 ? -e.deltaX : e.deltaY), 0);
            updateTimes();
            player.currentTime = time / 1000;
        }
    }

    let mouseDrag = $state(false);

    function onmousemove(e: MouseEvent) {
        mouseDrag = e.buttons == 4;
        if(mouseDrag) {
            time -= e.movementX / scale * 10;
            updateTimes();
            player.currentTime = time / 1000;
        }
    }

    let clips: Clip[] = $state([]);
</script>

<main bind:this={timelineBody} {onmousemove} style={mouseDrag ? 'cursor: move;' : ''}>
    <bar>
        <button onclick={playPause} class="ibutton">⏯</button>
        <button onclick={stop} class="ibutton">⏹</button>
        <input type="number" bind:value={minutes} onchange={onChangeTime}>:<input type="number" bind:value={seconds} onchange={onChangeTime}>
        <input type="range" min="1" max="8" step="1" bind:value={$Snapping}>1/{$Snapping}
    </bar>
    
    <div>
        <Playhead/>
        <Ticks {scale} {beats} snapping={$Snapping}/>
        <timelines>
            {#each clips as _clip, i}
            <div>
                <Timeline bind:clip={clips[i]} {beats} {scale} />
            </div>
            {/each}
        </timelines>
    </div>
</main>

<style>
    main {
        display: flex;
        flex-direction: column;
        height: 100%;
        width: 100%;
    }

    timelines {
        overflow-y: auto;
    }

    main div {
        position: relative;
        width: 100%;
        height: fit-content;
    }

    bar {
        display: flex;
        flex-direction: row;
        align-items: center;
        padding-bottom: calc(var(--spacing)/4);
    }

    bar * {
        margin: 0 calc(var(--spacing)/2);
    }

    bar input[type="number"] {
        max-width: 40px;
    }

    .ibutton {
        font-size: larger;
    }
</style>
