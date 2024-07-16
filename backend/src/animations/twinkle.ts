import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";
import { createNoise2D } from 'simplex-noise';

const anim = new Animation(
    'Twinkle',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Color',
            type: 'color',
            value: Color.fromHsv(0, 0, 0).hex
        },
        {
            name: 'Rate',
            type: 'number',
            value: 1
        },
        {
            name: 'Hold',
            type: 'number',
            value: 1
        },
        {
            name: 'Swap',
            type: 'number',
            value: 1
        }
    ],
    render
);

export default anim;

const noise = createNoise2D();

function render(this: Animation, input: RenderInput) {
    const { time: percent, out, ledCount } = input;

    const color = this.getParameter('Color');
    const newColor = color.raw() == 0 ? Color.fromHsv(Math.random()*360, 100, 100).raw() : color.raw();

    for(let i = 0; i < ledCount; i++) {
        const b = (noise(i*20, percent*this.getParameter('Rate')*10) + 1) / 2;
        out[i] = b > .8 ? newColor : 0;
    }
}
