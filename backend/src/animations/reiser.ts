import { ParameterType } from "$schema/clip";
import Animation, { type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { TargetType } from "$schema/settings";

const anim =  new Animation(
    'Reiser',
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

    const oldColor = this.getParameter('Color') as Color;
    const newColor = Color.fromRgb(oldColor.r * brightness, oldColor.g * brightness, oldColor.b * brightness);
    
    input.out.fill(newColor.raw());


    return input.out;
}
