<script lang='ts'>
    export let orient: 'horizontal' | 'vertical';
    const orientation = `${orient}`;
    export let minPaneWidth = 300;
    export let style = '';

    let panel: HTMLElement;
    let sizers: HTMLElement;
    let splits: number[] = [];

    let width: number;
    let height: number;

    let updatePanels = (_a: any, _b: any) => {};

    let setup = false;

    let sizerDown = -1;

    $: if(panel && sizers && width && height && !setup) {
        setup = true;
        let panes: HTMLElement[] = [];
        for(let i = 0; i < panel.childElementCount - 1; i++) {
            panes.push(panel.children[i] as HTMLElement);
            if(i < panel.childElementCount - 2) {
                const sizer = document.createElement('div');
                sizer.onmousedown = () => sizerDown = i;
                sizer.setAttribute('style', `display: block; position: absolute; inset: 0px; cursor: ${orientation == 'horizontal' ? 'ew' : 'ns'}-resize; z-index: 2; pointer-events: all;`);
                sizers.appendChild(sizer);
            }
        }

        splits = [];
        panes.forEach((_, i) => {
            if(i < panel.childElementCount - 2) {
                splits.push((i + 1) / (panel.childElementCount - 1) * (orientation == 'horizontal' ? width : height));
            }
        });

        updatePanels = function(width: number, height: number) {
            panes.forEach((pane, i) => {
                pane.style.position = 'absolute';
                pane.style.zIndex = '0';
                pane.style.overflow = 'auto';
                if(orientation == 'horizontal') {
                    pane.style.top = '0px';
                    pane.style.bottom = '0px';
                } else {
                    pane.style.left = '0px';
                    pane.style.right = '0px';
                }

                const style = pane.style;
                if(orientation == 'horizontal') {
                    if(i > 0) {
                        style.left = `${splits[i - 1]}px`;
                    }else {
                        style.left = `0px`;
                    }

                    if(i < panes.length - 1) {
                        style.right = `${width - splits[i]}px`;
                    }else {
                        style.right = '0px';
                    }
                }else {
                    if(i > 0) {
                        style.top = `${splits[i - 1]}px`;
                    }else {
                        style.top = `0px`;
                    }

                    if(i < panes.length - 1) {
                        style.bottom = `${height - splits[i]}px`;
                    }else {
                        style.bottom = '0px';
                    }
                }
            });

            const sizerWidth = `.5rem`;
            [...sizers.children].forEach((s, i) => {
                const sizer = s as HTMLElement;
                if(orientation == 'horizontal') {
                    sizer.style.left = `calc(${splits[i]}px - ${sizerWidth}/2)`;
                    sizer.style.width = `${sizerWidth}`;
                }else {
                    sizer.style.top = `calc(${splits[i]}px - ${sizerWidth}/2)`;
                    sizer.style.height = `${sizerWidth}`;
                }
            });
        }
    }

    $: updatePanels(width, height);

    $: if(sizerDown > -1) {
        document.body.style.userSelect = 'none';
    }else {
        document.body.style.userSelect = 'auto';
    }

    const onmousemove = (ev: MouseEvent) => {
        if(ev.buttons != 1) {
            sizerDown = -1;
        }

        if(sizerDown > -1) {
            ev.stopPropagation();
            splits[sizerDown] =
                Math.min(
                Math.max((orientation == 'horizontal' ? ev.pageX - panel.getBoundingClientRect().left : ev.clientY - panel.getBoundingClientRect().top), (splits[sizerDown - 1] ?? 0) + minPaneWidth),
                (splits[sizerDown + 1] ?? (orientation == 'horizontal' ? width : height)) - minPaneWidth);

            updatePanels(width, height);
        }
    }
</script>

<div {style}>
    <panel bind:this={panel} bind:clientWidth={width} bind:clientHeight={height} {onmousemove}>
        <slot/>
        <sizers bind:this={sizers}>
        </sizers>
    </panel>
</div>


<style>
    div {
        display: block;
    }

    panel {
        display: block;
        position: relative;
        width: 100%;
        height: 100%;
    }

    sizers {
        position: relative;
        width: 100%;
        height: 100%;
        display: block;
        z-index: 2;
        pointer-events: none;
    }
</style>
