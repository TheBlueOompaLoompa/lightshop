import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'TimeScale',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Start',
            type: 'number',
            value: 0
        },
        {
            name: 'End',
            type: 'number',
            value: 1
        },
        {
            name: 'Function',
            type: 'select',
            value: 'linear',
            options: ['linear', 'easeInOutSine']
        }
    ],
    render
);

export default anim;

function render(this: Animation, input: RenderInput) {
    const start = this.getParameter('Start') as number;
    const end = this.getParameter('End') as number;
    const func = this.getParameter('Function') as string;

    input.extra = {};

    switch(func) {
        case 'easeInOutSine':
            input.extra.time = easeInOutSine(input.time);
            break;
        default:
            input.extra.time = input.time;
            break;
    }

    input.extra.time = input.extra.time * (end - start) + start;

    return { ...input.extra };
}

function easeInOutSine(x: number): number {
    return -(Math.cos(Math.PI * x) - 1) / 2;
}
