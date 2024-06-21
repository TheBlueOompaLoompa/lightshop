<script lang='ts'>
    import '$styles/global.css';
	import { onMount } from 'svelte';
    import { Client } from '$lib/stores';
    import createClient from '$lib/trpc';

    onMount(() => {
        $Client = createClient();
    });
</script>

<svelte:head>
    <title>Lightshop</title>
</svelte:head>

<slot/>
