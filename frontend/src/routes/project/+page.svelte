<script lang="ts">
	import ProjectModal from "$components/ProjectModal.svelte";
    import ResizePanel from "$components/ResizePanel.svelte";
	import { Client } from "$lib/stores";
	import type { Project } from "@backend/types";

    const url = new URL(window.location.href);
    const projectName = decodeURIComponent(url.searchParams.get('name') as string);
    const version = decodeURIComponent(url.searchParams.get('version') as string);

    let project: Project | undefined;
    let audio: HTMLAudioElement;

    let showProjectModal = false;

    Client.subscribe(async client => {
        if(!client) return;
        project = await client.projects.open.query({ name: projectName, version: parseInt(version) });
    });

    $: if(audio && project) {
        audio.src = project.info.musicFile;
    }
</script>

{#if showProjectModal && project}
<ProjectModal info={project.info} onpositive={() => showProjectModal = false} onnegative={() => showProjectModal = false} />
{/if}

<main>
    <toolbar>
        <button>Manual Save</button>
        <button onclick={() => showProjectModal = true}>Song Config</button>
        <button onclick={() => location.href = '/'}>Exit</button>
        <h1>{projectName}</h1>
        <audio bind:this={audio}></audio>
    </toolbar>
    <ResizePanel orient="vertical" style="width: 100%; height: 100%;">
        <ResizePanel orient="horizontal">
            <div><h2>Clip Pool</h2></div>
            <div><h2>Properties</h2></div>
            <div class="no-right"><h2>Preview</h2></div>
        </ResizePanel>
        <div class="timeline no-right"><h2>Timeline</h2>
        <button onclick={() => audio.play()}>Play</button>
        </div>
    </ResizePanel>
</main>

<svelte:head>
    <title>Lightshop {projectName}</title>
</svelte:head>

<style>
    main {
        position: absolute;
        inset: 0px;
        display: flex;
        flex-direction: column;
    }

    div {
        display: flex;
        background-color: var(--background);
        padding: var(--spacing);
    }

    div:not(.no-right) {
        border-right: var(--border);
    }

    div {
        border-top: var(--border);
    }

    div * {
        width: 100%;
        height :100%;
    }


    toolbar {
        display: flex;
        flex-direction: row;
        align-items: center;
        padding: calc(var(--spacing) / 2);
    }

    toolbar * {
        margin-right: calc(var(--spacing) / 2);
    }

    toolbar h1 {
        margin-left: auto;
    }
</style>
