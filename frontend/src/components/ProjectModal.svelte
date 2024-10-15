<script lang='ts'>
    import ConfirmModal from "$components/ConfirmModal.svelte";
    import type { Project } from '@backend/types';

    export let isNewProject = false;

    export let project: Project = { name: '', tempo: 120, time: 0, version: 0, music: '', offset: 0 };
    export let minutes = (project.time - project.time % 60) / 60;
    export let seconds = project.time % 60;

    export let onpositive = () => {};
    export let onnegative = () => {};

    function onMusicUpload(e: any) {
        const files: FileList|undefined = e.target.files;

        if(files && files[0]) {
            const file = files[0];
            const reader = new FileReader();

            reader.onload = (_e: any) => {
                if(typeof reader.result == 'string') project.music = reader.result;
                console.log(project.music)
            };

            reader.readAsDataURL(file);
        }
    }

    async function onPositive() {
        onpositive();
    }

    $: project.time = minutes * 60 + seconds;
</script>

<ConfirmModal
    message={isNewProject ? 'New Project' : 'Edit Project'}
    positive={isNewProject ? 'Create' : 'Save Changes'}
    negative="Cancel"

    onpositive={onPositive}
    bind:onnegative={onnegative}
>
    <div class="area">
        <span>Name</span>
        <input type="text" placeholder="Name" bind:value={project.name}/>
        <span>Tempo</span>
        <input type="number" bind:value={project.tempo}/>
        <span>Length</span>
        <div>
            <input type="number" size="4" bind:value={minutes}/>
            <span>:</span>
            <input type="number" size="4" bind:value={seconds}/>
        </div>
        <span>Offset (ms)</span>
        <input type="number" bind:value={project.offset}>
        <span>Music File</span>
        <input type="file" onchange={onMusicUpload}/>
    </div>
</ConfirmModal>

<style>
    div.area {
        display: grid;
        grid-template-columns: auto auto;
        margin-bottom: var(--spacing);
        gap: var(--spacing);
    }

    input {
        display: inline-flex;
        min-width: unset;
    }

    span {
        align-content: center;
    }

    input[type=file] {
        max-width: 400px;
        overflow-x: auto;
    }
</style>
