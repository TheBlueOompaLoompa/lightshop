<script lang="ts">
    import { Selected, Client } from "$lib/stores";
    import { z } from "zod";
    import { type Parameter, ParameterType } from "@backend/schema/clip";

    $effect(() => {
        if($Selected && $Selected.type == 'clip' && $Selected.clip) {
            $Client.clips.update.mutate($Selected.clip);
        }
    });
</script>

{#if $Selected && $Selected.type == 'clip' && $Selected.clip}
<div>
    {#each ($Selected.clip.params as z.infer<typeof Parameter>[]) as parameter}
        <span>{parameter.name}</span>

        {#if parameter.type == ParameterType.enum.color}
        <input type="color" bind:value={parameter.value}/>
        {:else if parameter.type == ParameterType.enum.number}
        <input type="number" bind:value={parameter.value}/>
        {:else if parameter.type == ParameterType.enum.bool}
        <input type="checkbox" bind:checked={parameter.value}/>
        {/if}
    {/each}
</div>
{/if}

<style>
    div {
        display: grid;
        grid-template-columns: auto auto;
        gap: var(--spacing);
        height: fit-content;
    }

    span {
        font-size: larger;
    }

    input {
        width: fit-content;
    }

    input[type="color"] {
        padding: 3px;
    }

    input[type="checkbox"] {
        min-width: 1rem;
    }
</style>
