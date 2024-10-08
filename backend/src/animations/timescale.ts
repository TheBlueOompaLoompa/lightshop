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
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }

);

export default anim;

function render(this: Animation, input: RenderInput) {
    const start = this.getParameter('Start') as number;
    const end = this.getParameter('End') as number;
    const func = this.getParameter('Function') as string;

    switch(func) {
        case 'easeInOutSine':
            input.extra.time = easeInOutSine(input.extra.realTime);
            break;
        default:
            input.extra.time = input.extra.realTime;
            break;
    }

    input.extra.time = input.extra.time * (end - start) + start;

    return { ...input.extra };
}

function easeInOutSine(x: number): number {
    return -(Math.cos(Math.PI * x) - 1) / 2;
}
