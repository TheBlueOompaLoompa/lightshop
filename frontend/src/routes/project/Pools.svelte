<script lang="ts">
    import Pool from "./Pool.svelte";
    import { Client } from "$lib/stores";
    import type { Pool as TPool } from "@backend/types";

    export let projectName: string;
    let pools: TPool[] | undefined;

    Client.subscribe(async client => {
        if(!client) return;
        pools = await client.pools.list.query(projectName);
        if(pools) pools.splice(pools.findIndex(pool => pool.name == 'Roots'), 1);
    });
</script>

{#if pools}
<pools>
    {#each pools as pool, idx}
    <Pool {pool} {idx} project={projectName} />
    {/each}
</pools>
{/if}

<style>
    pools {
        display: flex;
        flex-direction: column;
        width: 100%;
        height: 100%;
        overflow-y: auto;
    }
</style>
