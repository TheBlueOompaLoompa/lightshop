import Animation, { type RenderInput } from "../lib/animation";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'TimeWiggle',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Bottom',
            type: 'number',
            value: 0
        },
        {
            name: 'Top',
            type: 'number',
            value: 1
        },
        {
            name: 'Speed',
            type: 'number',
            value: 1
        },
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }

);

export default anim;

function render(this: Animation, input: RenderInput) {
    const top = this.getParameter('Top') as number;
    const bottom = this.getParameter('Bottom') as number;
    const speed = this.getParameter('Speed') as number;

    if(!input.extra.time) input.extra.time = input.extra.realTime;
    input.extra.time = (Math.sin(input.extra.time * speed*Math.PI*2+(3*Math.PI/2))+1)/2*(top-bottom) + bottom/2;

    return { ...input.extra };
}
