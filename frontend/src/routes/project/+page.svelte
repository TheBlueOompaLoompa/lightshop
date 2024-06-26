<script lang="ts">
	import ProjectModal from "$components/ProjectModal.svelte";
    import ResizePanel from "$components/ResizePanel.svelte";
    import Timeline from "./Timeline.svelte";
    import Properties from "./Properties.svelte";
    import Pools from "./Pools.svelte";
    import Cursor from "$components/Cursor.svelte";
	import { Client, Project } from "$lib/stores";
	import type { Project as TProject } from "@backend/types";

    const url = new URL(window.location.href);
    const projectName = decodeURIComponent(url.searchParams.get('name') as string);

    let data: { project: TProject } | undefined = $state();
    let audio: HTMLAudioElement;

    let showProjectModal = $state(false);
    let scale = $state(2);
    let beats = $state(0);

    Client.subscribe(async client => {
        if(!client) return;
        data = await client.projects.open.query(projectName);
        if(data) {
            $Project = data.project;
        }
    });

    $effect(() => {
        if(audio && data) {
            audio.src = data.project.music;
        }
    });

    async function saveConfig() {
        if(!data) return;
        await $Client.projects.save.mutate(data.project);
    }
</script>

{#if showProjectModal && data}
<ProjectModal project={data.project} onpositive={() => { showProjectModal = false; saveConfig(); }} onnegative={() => showProjectModal = false} />
{/if}

{#if data}
<main>
    <toolbar>
        <button onclick={() => showProjectModal = true}>Song Config</button>
        <button onclick={() => location.href = '/'}>Exit</button>
        <h1>{projectName}</h1>
    </toolbar>
    <ResizePanel orient="vertical" minPaneWidth={235} style="width: 100%; height: 100%;">
        <ResizePanel orient="horizontal">
            <div>
                <Pools projectName={data.project.name}/>
            </div>
            <div>
                <Properties/>
            </div>
            <div class="no-right"><h2>Preview</h2></div>
        </ResizePanel>
        <div class="timeline no-right">
            <Timeline project={data.project} bind:scale={scale} bind:beats={beats}/>
        </div>
    </ResizePanel>
</main>
{/if}

<Cursor timelineScale={scale} {beats} />

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
