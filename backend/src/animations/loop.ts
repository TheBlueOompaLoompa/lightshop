import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Loop',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Times',
            type: 'number',
            value: 2
        },
        {
            name: 'Mode',
            type: 'select',
            value: 'Back to Start',
            options: ['Back to Start', 'Ping Pong']
        }
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }

);

export default anim;

function render(this: Animation, input: RenderInput) {
    const times = this.getParameter('Times') as number;
    const mode = this.getParameter('Mode') as string;

    input.extra.time = input.extra.realTime*times
    input.extra.time -= Math.floor(input.extra.time);

    switch(mode) {
        case 'Ping Pong':
            if(Math.floor(input.extra.realTime*times)%2 != 0) {
                input.extra.time = 1-input.extra.time;
            }
            break;
    }

    return { ...input.extra };
}
