<script lang="ts">
    import Timeline from "$components/Timeline.svelte";
    import Ticks from "./Ticks.svelte";
    import type { Clip, Project, Bpm } from "@backend/types";
    import { Client, FPS, Snapping } from '$lib/stores';
    import { time2beats, beats2time } from '@backend/util';
	import Playhead from "./Playhead.svelte";

    let { project, scale = $bindable(2), beats: bindBeats = $bindable(0) }:
        { project: Project, scale: number, beats: number } = $props();
    let bpms: Bpm[] = $state([]);
    let clips: Clip[] = $state([]);

    Client.subscribe(async client => {
        if(client) {
            bpms = await client.bpm.listEvents.query(project.name);
            clips = await client.clips.list.query({ pool: 'Roots', project: project.name });
        }
    });

    const audioCtx = new AudioContext();
    let latency = $derived(audioCtx.outputLatency * 1000);

    let time = $state(0);
    let beats = $derived(Math.max(time2beats(time, bpms, project.tempo), 0));
    let viewBeats = $state(0);
    let playing = $state(false);

    $effect(() => {
        viewBeats = Math.max(viewBeats, 0)
        if(playing) {
            if(viewBeats < beats - (20/scale)) {
                viewBeats = beats - (20/scale)
            }
        }
    });

    
    let minutes = $state(0);
    let seconds = $state(0);
    
    function setTime(newTime: number) {
        player.currentTime = newTime / 1000;
        time = player.currentTime * 1000 + project.offset - latency;
        updateTimes();
    }

    function onChangeTime() {
        player.currentTime = minutes * 60 + seconds;
        setTime(player.currentTime * 1000);
    }

    let startTime = $state(0);
    let player: HTMLAudioElement = new Audio(project.music);

    $effect(() => {
        time;
        sendTime();
    });


    const updateTimes = () => { minutes = Math.floor(player.currentTime / 60); seconds = player.currentTime % 60; }

    function sendTime(beforeCall: () => any = () => {}) {
        const timeDiff = Date.now() - lastTime;

        if(timeDiff > 1000/$FPS) {
            beforeCall();
            lastTime = Date.now();
            $Client.player.setBeat.mutate(beats);

            updateTimes();
        }
    }

    let lastTime = 0;
    async function timing() {
        sendTime(() => time = player.currentTime*1000 + project.offset - latency);
        if(time >= project.time * 1000) player.pause();
        if(!player.paused) window.requestAnimationFrame(timing);
    }

    async function playPause() {
        if(player.paused) {
            await player.play();
            lastTime = Date.now();
            time = player.currentTime*1000;
            startTime = parseInt(time.toString());
            time += project.offset - latency;
            
            timing();
        }else {
            player.pause();
        }

        playing = !player.paused;
    }

    async function stop() {
        if(!player.paused) {
            player.pause();
            viewBeats = Math.min(time2beats(startTime, bpms, project.tempo), viewBeats);
            player.currentTime = startTime/1000;
            time = player.currentTime*1000 - project.offset - latency;
        }else {
            player.currentTime = 0;
            time = 0;
            viewBeats = 0;
        }

        playing = !player.paused;
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
            viewBeats -= (e.deltaX != 0 ? -e.deltaX : e.deltaY) / 80;
        }
    }

    let mouseDrag = $state(false);

    function onmousemove(e: MouseEvent) {
        mouseDrag = e.buttons == 4;
        if(mouseDrag) {
            viewBeats -= e.movementX / scale / 20;
        }
    }

    function onretime(newBeats: number) {
        setTime(beats2time(newBeats, bpms, project.tempo));
    }

    window.addEventListener('keyup', (e: KeyboardEvent) => {
        if(e.key == ' ') {
            e.preventDefault();
            e.stopPropagation();
            playPause();
        }
    });
</script>

<main bind:this={timelineBody} {onmousemove} style={mouseDrag ? 'cursor: move;' : ''}>
    <bar>
        <button onclick={playPause} class="ibutton">⏯</button>
        <button onclick={stop} class="ibutton">⏹</button>
        <input type="number" bind:value={minutes} onchange={onChangeTime}>:<input type="number" bind:value={seconds} onchange={onChangeTime}>
        <input type="checkbox" bind:checked={$Snapping}/>
        <input type="range" min="1" max="8" step="1" bind:value={$Snapping}>1/{$Snapping}
    </bar>
    
    <div>
        <Playhead {scale} beats={time2beats(player.currentTime*1000, bpms, project.tempo) - viewBeats + time - time}/>
        <Ticks {scale} beats={viewBeats} snapping={$Snapping} {onretime} />
        <timelines>
            {#each clips as _clip, i}
            <div>
                <Timeline bind:clip={clips[i]} beats={viewBeats} {scale} />
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
