<script lang="ts">
    import Marker from './Marker.svelte';

    export let trackCount: number = 1;
    export let beats = 1;
    export let scale = 2;

    function selectBpm() {
        
    }
</script>

<Marker {trackCount} {beats} {scale} onclick={selectBpm} />
