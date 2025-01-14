import Animation, { type RenderInput, MixType } from "../lib/animation";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'Mix',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Mix Mode',
            type: 'select',
            value: 'Add',
            options: ['Add', 'Multiply', 'Overlay']
        }
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

function render(this: Animation, input: RenderInput) {
    let mix = MixType.Add;

    switch(this.getParameter('Mix Mode') as string) {
        case 'Multiply':
            mix = MixType.Multiply;
            break;
        case 'Overlay':
            mix = MixType.Overlay;
            break;
        default:
            break;
    }

    return { layer: input.out.slice(), mix }; 
}
