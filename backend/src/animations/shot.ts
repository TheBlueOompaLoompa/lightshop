import Animation, { ParameterType, type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { AnimationType } from "$lib/types";

export default cloner

function cloner(){
    return new Animation(
        'Gunshot',
        [AnimationType.Tree, AnimationType.Linear],
        [
            {
                name: 'Color',
                type: ParameterType.color,
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Direction',
                type: ParameterType.boolean,
                value: false
            },
            {
                name: 'Length',
                type: ParameterType.number,
                value: 6
            }
        ],
        render, cloner
    );
}

function render(this: Animation, time: number, input: RenderInput) {
    const color = this.getParameter('Color') as Color;
    const direction = this.getParameter('Direction') as boolean;
    const length = this.getParameter('Length') as number;

    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);

    percent = direction ? 1 - percent : percent;

    for(let i = 0; i < input.out.length; i++) {
        if(i >= Math.floor(percent*input.out.length) && i < Math.floor(percent*input.out.length) + length) {
            input.out[i] = color.raw();
        }
    }

    return input.out;
}