import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Gunshot',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Direction',
            type: 'bool',
            value: false
        },
        {
            name: 'Length',
            type: 'number',
            value: 6
        },
        {
            name: 'Fade Length',
            type: 'number',
            value: 0
        }
    ],
    render
);

export default anim;

function mult(v: number, x: number): number {
    return ((((v >> 24) & 0xff) * x) << 24) | ((((v >> 16) & 0xff) * x) << 16) | ((((v >> 8) & 0xff) * x) << 8)
}

function render(this: Animation, input: RenderInput) {
    const direction = this.getParameter('Direction') as boolean;
    const length = this.getParameter('Length') as number;
    const fade = this.getParameter('Fade Length') as number;

    let { out, time: percent } = input;

    percent = direction ? 1 - percent : percent;
    const start = Math.floor(input.out.length * percent);

    for(let i = 0; i < input.out.length; i++) {
        if(i >= start - fade && i < start + length + fade) {
            out[i] = mult(out[i], (i < start+length) ? Math.min((i - start + fade)/fade, 1) : Math.max(-(i-start-fade)/fade, 0));
        }else out[i] = 0;
    }

    /*for(let i = Math.max(start - fade); i < input.out.length && i < start + length + fade*2; i++) {
        let newCol = Color.fromHex(color.hex);
        newCol.v -= (i < start ? (start-i) / fade : 0) * 100;
        newCol.v -= ((i - start > length + fade) ? ((i - start - length - fade) - fade) / fade : 0) * 100;
        input.out[i] = newCol.raw();
    }*/
}
