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
    let ledPositions: number[][] = [];

    // TODO: Allow uploading LED positions file

    async function fileChange(event: any) {
        console.log(event.target.files);
        const text = await event.target.files[event.target.files.length - 1].text();
        const rows = text.split('\n');
        alert(rows.length + ' leds found!');
        ledPositions = [];

        rows.forEach(row => {
            const parts = row.split(';').map(str => parseInt(str));
            ledPositions.push(parts);
        });
    }

    function onPositive() {
        onpositive();
        settings.targets = [
            ...settings.targets,
            { name, address, ledCount, type, ledPositions }
        ]
    }
</script>

<ConfirmModal message="Create/Modify Render Target" positive="Create" negative="Cancel" onpositive={onPositive} {onnegative}>
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

        {#if type == 'spatial'}
        <span>Spatial Data (; seperated, \n per led)</span>
        <input type="file" on:change={fileChange}/>
        {/if}
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
