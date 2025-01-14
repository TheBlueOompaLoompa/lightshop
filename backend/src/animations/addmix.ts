import Animation, { MixType, type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'AddMix',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

function render(this: Animation, input: RenderInput) {
    return { layer: input.out.slice(), mix: MixType.Add }; 
}
