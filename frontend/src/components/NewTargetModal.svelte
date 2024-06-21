<script lang="ts">
	import type { Settings } from "@backend/types";
    import ConfirmModal from "./ConfirmModal.svelte";

    export let settings: Settings;

    export let onpositive: () => any;
    export let onnegative: () => any;

    let name = '';
    let address = '';
    let ledCount = 0;
    let type = 'linear';

    // TODO: Allow uploading LED positions file

    function onPositive() {
        onpositive();
        settings.targets = [
            ...settings.targets,
            { name, address, ledCount, type }
        ]
    }
</script>

<ConfirmModal message="Create New Render Target" positive="Create" negative="Cancel" onpositive={onPositive} {onnegative}>
    <div>
        <span>Name</span>
        <input type="text" placeholder="Bar" bind:value={name}>

        <span>Address</span>
        <input type="text" placeholder="192.168.1..." bind:value={address}>

        <span>Led Count</span>
        <input type="number" placeholder="100" bind:value={ledCount}>

        <span>Type</span>
        <select bind:value={type}>
            <option value="linear">Linear</option>
            <option value="spatial">Spatial</option>
        </select>
    </div>
</ConfirmModal>

<style>
    div {
        display: grid;
        grid-template-columns: auto auto;
        grid-gap: calc(var(--spacing)/2) var(--spacing);
        margin-bottom: var(--spacing);
    }

    span {
        align-content: center;
    }
</style>
