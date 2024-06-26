<script lang='ts'>
    import ConfirmModal from '$components/ConfirmModal.svelte';
	import { Client } from '$lib/stores';
    import { Trash } from 'svelte-bootstrap-icons';

    export let projectName: string;
    const prn = `${projectName}`;

    let showDeleteConfirm = false;

    function confirmDelete() {
        showDeleteConfirm = true;
    }

    async function deleteProject() {
        showDeleteConfirm = false;
        await $Client.projects.delete.mutate(prn);
        window.location.reload();
    }


    function openProject() {
        location.href = `/project?name=${encodeURIComponent(prn)}`;
    }
</script>

{#if showDeleteConfirm}
<ConfirmModal message={`Are you sure you want to delete ${projectName}?`}
    onpositive={deleteProject}
    onnegative={() => showDeleteConfirm = false}/>
{/if}

<row class="subpanel">
    <span id="projectName">{projectName}</span>
    <button onclick={openProject}>Open</button>
    <button onclick={confirmDelete}><Trash class="icon-space"/>Delete</button>
</row>


<style>
    row {
        display: flex;
        flex-direction: row;
        align-items: center;
    }
    
    #projectName {
        margin-right: auto;
    }

    button {
        margin-left: calc(var(--spacing) / 2);
    }
</style>
