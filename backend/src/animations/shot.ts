import { ParameterType } from "../schema/clip";
import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Gunshot',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Color',
            type: ParameterType.enum.color,
            value: Color.fromHsv(0, 0, 0).hex
        },
        {
            name: 'Direction',
            type: ParameterType.enum.bool,
            value: false
        },
        {
            name: 'Length',
            type: ParameterType.enum.number,
            value: 6
        },
        {
            name: 'Fade Length',
            type: ParameterType.enum.number,
            value: 0
        }
    ],
    render
);

export default anim;

function render(this: Animation, input: RenderInput) {
    const color = this.getParameter('Color') as Color;
    const direction = this.getParameter('Direction') as boolean;
    const length = this.getParameter('Length') as number;
    const fade = this.getParameter('Fade Length') as number;

    let percent = input.time;

    percent = direction ? 1 - percent : percent;
    const start = Math.floor(input.out.length * percent);

    for(let i = Math.max(start - fade); i < input.out.length && i < start + length + fade*2; i++) {
        let newCol = Color.fromHex(color.hex);
        newCol.v -= (i < start ? (start-i) / fade : 0) * 100;
        newCol.v -= ((i - start > length + fade) ? ((i - start - length - fade) - fade) / fade : 0) * 100;
        input.out[i] = newCol.raw();
    }

    return input.out;
}
