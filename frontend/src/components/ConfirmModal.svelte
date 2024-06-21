<script lang="ts">
	import Modal from "$components/Modal.svelte";

    export let message = 'Are you sure?';
    export let positive = 'Yes';
    export let negative = 'No';
    export let cancel = 'Cancel';

    export let enableCancel = false;

    export let onpositive: () => any = () => {};
    export let onnegative: () => any = () => {};
    export let oncancel: () => any = () => {};
</script>

<Modal>
    <h3 style="margin-bottom: var(--spacing);">{message}</h3>
    <slot/>
    <row>
        <button onclick={onpositive}>{positive}</button>
        <button onclick={onnegative}>{negative}</button>
        {#if enableCancel}
        <button onclick={oncancel}>{cancel}</button>
        {/if}
    </row>
</Modal>

<style>
    row {
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
    }
</style>
