import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'ColorFade',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Color1',
            type: 'color',
            value: Color.fromHsv(0, 0, 0).hex
        },
        {
            name: 'Color2',
            type: 'color',
            value: Color.fromHsv(0, 0, 0).hex
        }
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

function render(this: Animation, input: RenderInput) {
    const color1 = this.getParameter('Color1') as Color;
    const color2 = this.getParameter('Color2') as Color;
    const gradient = Color.fromRgb(color1.r + (color2.r - color1.r) * input.time, color1.g + (color2.g - color1.g) * input.time, color1.b + (color2.b - color1.b) * input.time);
    input.out.fill(gradient.raw());
}
