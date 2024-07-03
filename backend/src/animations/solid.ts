import { ParameterType } from "../schema/clip";
import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Solid',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Color',
            type: ParameterType.enum.color,
            value: Color.fromHsv(0, 0, 0).hex
        }
    ],
    render
);

export default anim;

function render(this: Animation, input: RenderInput) {
    input.out.fill(this.getParameter('Color').raw());

    return input.out;
}
