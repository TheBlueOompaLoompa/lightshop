<script lang='ts'>
    import { PlusCircle } from 'svelte-bootstrap-icons';
	import ProjectRow from "./ProjectRow.svelte";
	import ProjectModal from '$components/ProjectModal.svelte';
	
	import { Client } from '$lib/stores';
	import type { Project } from '@backend/types';
	import SettingsModal from '$components/SettingsModal.svelte';

    let showSettings = false;
    let showNewProject = false;
    let projects: Project[] = [];
    let newProject: Project;

    Client.subscribe(async client => {
        if(client) {
            const list = await client.projects.list.query();
            console.log(list);
            if(list) projects = list;
        }
    });

    async function createProject() {
        const chunkSize = 6 * 1024 * 1024;
        let bigSong: string | null = null;
        let temp = {};
        Object.assign(temp, newProject);
        if(newProject.music.length > chunkSize) {
            bigSong = newProject.music;
            temp.music = null;
        }

        await $Client.projects.save.mutate(temp);

        if(bigSong) {
            for(let i = 0; i < Math.ceil(newProject.music.length / chunkSize); i++) {
                const start = i*chunkSize;
                const end = Math.min(bigSong.length-1, (i+1)*chunkSize);
                await $Client.projects.saveMusicPart.mutate({ project: newProject.name, part: bigSong.slice(start, end), end: end == bigSong.length-1 })
            }
        }

        location.href = `/project?name=${encodeURIComponent(newProject.name)}`;
    }
</script>

{#if showSettings}
<SettingsModal onpositive={() => showSettings = false} onnegative={() => showSettings = false} />
{/if}

{#if showNewProject}
<ProjectModal isNewProject={true} bind:project={newProject} onpositive={() => { createProject(); showNewProject = false; }} onnegative={() => showNewProject = false}/>
{/if}

<main>
    <vcenter>
        <div class="panel">
            <hrow style="margin-bottom: var(--spacing)">
                <h1>Projects</h1>
                <hrow>
                    <button onclick={() => showSettings = true}>Settings</button>
                    <button onclick={() => showNewProject = true}><PlusCircle class="icon-space"/>New</button>
                </hrow>
            </hrow>
            <projects>
                {#each projects as project}
                <ProjectRow projectName={`${project.name}`} />
                {/each}
            </projects>
        </div>
    </vcenter>
</main>


<style>
    .panel {
        min-width: 300px;
        width: calc(100% - 2rem);
        max-width: 600px;
    }

    main {
        position: absolute;
        inset: 0px;

        display: flex;
        flex-direction: column;
        align-items: center;
    }

    vcenter {
        justify-content: center;
        width: 100%;
    }

    hrow {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
    }

    projects {
        display: inline-block;
        max-height: 50vh;
        overflow-y: auto;
        width: 100%;

        background-color: rgb(0, 0, 0, 0.3);
        border-radius: var(--rounding);
        border: var(--white-border);
    }

    button {
        margin-left: var(--spacing);
    }
</style>
