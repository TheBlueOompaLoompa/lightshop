<script lang="ts">
    import type { Pool, Clip } from "@backend/types";
    import { Client, OnCursor } from "$lib/stores";

    let { pool, project, idx }: { pool: Pool, project: string, idx: number } = $props();
    let open = $state(false);

    let clips: Clip[] | undefined = $state();
    $inspect(clips);

    $effect(() => {
        if(open && $Client && pool && pool.name) {
            $Client.clips.list.query({ pool: pool.name, project }).then((res: Clip[]) => {
                clips = res;
                console.log(res);
            });
        }
    });

    function applyClip(clip: Clip) {
        let newClip: Clip | any = {};
        Object.assign(newClip, clip);
        $OnCursor = { type: 'clip', clip: newClip };
    }
</script>

<pool role="group">
    <span 
        class="title"
        style="filter: hue-rotate({idx * 30}deg);" role="button" tabindex=0
        onclick={() => open = !open}
        onkeypress={() => open = !open}>{pool.name} {open ? '⯆' : '⯈'}</span>
    {#if clips && open}
    <clips>
        {#each clips as clip}
        <span class="clip" role="button" tabindex=0 onclick={() => applyClip(clip)} onkeypress={() => applyClip(clip)}>{clip.name}</span>
        {/each}
    </clips>
    {/if}
</pool>

<style>
    pool {
        display: flex;
        flex-direction: column;
    }

    clips {
        display: flex;
        flex-direction: column;

        max-height: 300px;
        overflow-y: auto;
    }

    .title {
        font-size: x-large;
        color: #faa;
    }

    .clip {
        font-size: large;
        margin-left: 1.5rem;
    }

    span {
        user-select: none;
    }
</style>
