<script lang='ts'>
</script>

<background>
    <modal class="panel">
        <slot/>
    </modal>
</background>


<style>
    background {
        position: absolute;
        inset: 0px;

        display: flex;
        align-items: center;
        justify-content: center;

        z-index: 999999;
        background-color: rgb(0, 0, 0, 0.5);
    }
</style>
