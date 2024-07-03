import { ParameterType } from "../schema/clip";
import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim =  new Animation(
    'Reiser',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Direction',
            type: ParameterType.enum.bool,
            value: false
        },
        {
            name: 'Hold',
            type: ParameterType.enum.number,
            value: 1
        }
    ],
    render
);
export default anim;

function render(this: Animation, input: RenderInput) {
    let percent = input.time;
    const direction = !(this.getParameter('Direction') as boolean);
    const hold = this.getParameter('Hold') as number;

    let brightness = Math.log10(-(percent ** hold - 1)) + 1;
    if(direction) brightness = -(brightness - 1)
    brightness = Math.min(Math.max(brightness, 0), 1);
    for(let i = 0; i < input.out.length; i++) {
        const oldColor = Color.fromRaw(input.out[i]);
        const newColor = Color.fromRgb(Math.round(oldColor.r * brightness), Math.round(oldColor.g * brightness), Math.round(oldColor.b * brightness));
        input.out[i] = newColor.raw();
    }

    return input.out;
}
