<script lang="ts">
    import { Selected, Client } from "$lib/stores";
    import { z } from "zod";
    import { type Parameter, Effect, ParameterType } from "@backend/schema/clip";

    function updateParam(ei: number, pi: number, val: any) {
        if($Selected && $Selected.type == 'clip' && $Selected.clip && $Selected.clip.effects) {
            $Selected.clip.effects[ei].params[pi].value = val;
            $Client.clips.update.mutate($Selected.clip);
        }
    }
</script>

{#if $Selected && $Selected.type == 'clip' && $Selected.clip}
    <div id="effects">
    {#each ($Selected.clip.effects as z.infer<typeof Effect>[]) as effect, ei}
        <div style="display: flex; flex-direction: row; align-items: center;">
            <h2>{effect.name}</h2>
            {#if ei > 0}
            <button>↑</button>
            <button>↓</button>
            {/if}
        </div>

        <div id="params" style="margin-bottom: 1rem;">
        {#each (effect.params as z.infer<typeof Parameter>[]) as param, pi}
            <span>{param.name}</span>
            {#if param.type == ParameterType.enum.color}
            <input type="color" bind:value={param.value} oninput={e => updateParam(ei, pi, e.target.value)}/>
            {:else if param.type == ParameterType.enum.number}
            <input type="number" bind:value={param.value} oninput={e => updateParam(ei, pi, e.target.value)}/>
            {:else if param.type == ParameterType.enum.bool}
            <input type="checkbox" bind:checked={param.value} oninput={e => updateParam(ei, pi, e.currentTarget.checked)}/>
            {/if}
        {/each}
        </div>
    {/each}
    </div>
{/if}

<style>
    #effects {
        display: flex;
        flex-direction: column;
    }

    #params {
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
