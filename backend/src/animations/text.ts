import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Text',
    [TargetType.enum.spatial],
    [
        {
            name: 'Color',
            type: 'color',
            value: Color.fromHsv(0, 0, 0).hex
        },
        {
            name: 'Text',
            type: 'text',
            value: ''
        },
        {
            name: 'Font',
            type: 'text',
            value: 'Arial'
        },
        {
            name: 'Font Size',
            type: 'number',
            value: 700
        },
        {
            name: 'Start X',
            type: 'number',
            value: 0
        },
        {
            name: 'Start Y',
            type: 'number',
            value: 0
        },
        {
            name: 'Offset',
            type: 'number',
            value: 0
        },
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

function render(this: Animation, input: RenderInput) {
    const color = this.getParameter('Color') as Color;
    const text = this.getParameter('Text') as string;
    const font = this.getParameter('Font') as string;
    const fontSize = this.getParameter('Font Size') as number;
    const startX = this.getParameter('Start X') as number;
    const startY = this.getParameter('Start Y') as number;
    const offset = this.getParameter('Offset') as number;

    if(input.ctx && input.canvas) {
        input.ctx.fillStyle = 'black';
        input.ctx.fillRect(0, 0, input.canvas.width, input.canvas.height);

        input.ctx.fillStyle = color.hex+"ff";
        input.ctx.font = `${fontSize}px "${font}"`;
        input.ctx.textBaseline = 'top';
        input.ctx.fillText(text, startX-offset*input.time, startY);
    }

    return { canvas: '' }; 
}
