<script lang="ts">
	import { onMount } from "svelte";
    import ConfirmModal from "./ConfirmModal.svelte";
    import type { Settings, RenderTarget } from '@backend/types';
	import { Client } from "$lib/stores";
	import NewTargetModal from "./NewTargetModal.svelte";

    let settings: Settings | undefined;

    onMount(async () => {
        settings = await $Client.settings.load.query();
    });

    export let onpositive: () => any;
    export let onnegative: () => any;

    async function onPositive() {
        onpositive();
        if(settings) await $Client.settings.save.mutate(settings);
    }

    function deleteTarget(target: RenderTarget) {
        if(settings) {
            settings.targets = settings.targets.toSpliced(settings.targets.indexOf(target), 1);
        }
    }

    let showNewTarget = false;
</script>

{#if settings}
<ConfirmModal message="Settings" positive="Save" negative="Cancel" bind:onpositive={onPositive} bind:onnegative={onnegative}>
    <content>
        <h3>Render Targets</h3>
        <button onclick={() => showNewTarget = true}>New Render Target</button>
        <div class="targets">
            {#each settings.targets as target}
            <row class="subpanel"><span>{target.name}</span><button onclick={deleteTarget}>Edit</button><button onclick={deleteTarget}>Delete</button></row>
            {/each}
        </div>
    </content>
    {#if showNewTarget}
    <NewTargetModal bind:settings={settings} onpositive={() => showNewTarget = false} onnegative={() => showNewTarget = false}/>
    {/if}
</ConfirmModal>
{/if}

<style>
    content {
        display: flex;
        flex-direction: column;
        margin-bottom: var(--spacing);
    }

    .targets {
        min-width: 400px;
        max-height: 400px;
        overflow-y: auto;
    }

    row {
        display: flex;
        flex-direction: row;
        align-items: center;
    }

    row span {
        margin-right: auto;
    }
</style>
