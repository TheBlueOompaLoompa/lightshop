<script lang="ts">
    import { Selected, Client } from "$lib/stores";
    import { z } from "zod";
    import { type Parameter, Effect } from "@backend/schema/clip";
    import effects from "@backend/animations/effects";

    function updateParam(ei: number, pi: number, val: any) {
        if($Selected && $Selected.type == 'clip' && $Selected.clip && $Selected.clip.effects) {
            $Selected.clip.effects[ei].params[pi].value = val;
            $Client.clips.update.mutate($Selected.clip);
        }
    }

    function addEffect() {
        if($Selected && $Selected.type == 'clip' && $Selected.clip && $Selected.clip.effects) {
            $Selected.clip.effects = [...$Selected.clip.effects, { name: newEffect, params: Object.assign(effects[newEffect].params) }]
            $Client.clips.update.mutate($Selected.clip);
        }
    }

    function deleteEffect(idx: number) {
        if($Selected && $Selected.type == 'clip' && $Selected.clip && $Selected.clip.effects) {
            $Selected.clip.effects = $Selected.clip.effects.toSpliced(idx, 1);
            $Client.clips.update.mutate($Selected.clip);
        }
    }

    function moveEffect(idx: number, offset: number) {
        if($Selected && $Selected.type == 'clip' && $Selected.clip && $Selected.clip.effects) {
            if(idx+offset <= 0 || idx+offset >= $Selected.clip.effects.length) return;

            $Selected.clip.effects = $Selected.clip.effects.toSpliced(idx + offset, 0, $Selected.clip.effects.splice(idx, 1)[0]);
            $Client.clips.update.mutate($Selected.clip);
        }
    }

    let newEffect = 'Solid';
</script>

{#if $Selected && $Selected.type == 'clip' && $Selected.clip}
    <div id="effects">
    {#each ($Selected.clip.effects as z.infer<typeof Effect>[]) as effect, ei}
        <div class="params">
            <h2>{effect.name}</h2>

            {#if ei > 0}
            <div style="display: flex; flex-direction: row; align-items: center;">
                <button onclick={() => moveEffect(ei, -1)} style="margin-left: auto;">↑</button>
                <button onclick={() => moveEffect(ei, 1)}>↓</button>
                <button onclick={() => deleteEffect(ei)}>Delete</button>
            </div>
            {:else}
            <br/>
            {/if}
            
            {#each (effect.params as z.infer<typeof Parameter>[]) as param, pi}
                <span>{param.name}</span>
                {#if param.type == 'color'}
                <input type="color" bind:value={param.value} oninput={e => updateParam(ei, pi, e.target.value)}/>
                {:else if param.type == 'number'}
                <input type="number" bind:value={param.value} oninput={e => updateParam(ei, pi, parseFloat(e.target.value))}/>
                {:else if param.type == 'bool'}
                <input type="checkbox" bind:checked={param.value} oninput={e => updateParam(ei, pi, e.currentTarget.checked)}/>
                {:else if param.type == 'select'}
                <select bind:value={param.value}>
                    {#each param.options as option}
                    <option value={option}>{option}</option>
                    {/each}
                </select>
                {/if}
            {/each}
        </div>
    {/each}
    <div style="display: flex; flex-direction: row; margin-top: 1rem;">
        <select onchange={e => newEffect = e.target.value}>
            {#each Object.keys(effects) as effect}
            {#if effects[effect].targets.includes($Selected.clip.targetType)}
            <option value={effect}>{effect}</option>
            {/if}
            {/each}
        </select>
        <button onclick={addEffect}>+</button>
    </div>
    </div>
{/if}

<style>
    #effects {
        display: flex;
        flex-direction: column;
        width: 100%;
    }

    .params {
        display: grid;
        grid-template-columns: auto auto;
        grid-auto-rows: 1fr;
        gap: var(--spacing);
        width: 100%;
        height: fit-content;
        align-items: center;
        border-bottom: gray 1px solid;
        padding: var(--spacing) 0;
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
