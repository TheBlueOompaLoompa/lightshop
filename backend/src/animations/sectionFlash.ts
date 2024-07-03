//import { normalize, sub } from "$lib/vec";

import { ParameterType } from "$schema/clip";
import Animation, { type RenderInput } from "$lib/animation";
import { TargetType } from "$schema/settings";


const anim = new Animation(
    'Section Flash',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Sections',
            type: ParameterType.enum.number,
            value: 2
        },
        {
            name: 'Direction',
            type: ParameterType.enum.bool,
            value: false
        },
        {
            name: 'Only One',
            type: ParameterType.enum.number,
            value: 0
        }
    ],
    render
);

export default anim;

function render(this: Animation, input: RenderInput) {
    let { time: percent, out, ledCount } = input;

    const sections = this.getParameter('Sections') as number;
    const direction = this.getParameter('Direction') as boolean;
    const onlyOne = this.getParameter('Only One') as number;

    percent = direction ? 1 - percent : percent;

    const section = onlyOne > 0 ? onlyOne - 1 : Math.floor(percent * sections);
    const ledsPerSection = ledCount / sections;
    
    for(let i = 0; i < ledCount; i++) {
        if(!(i >= section * ledsPerSection && i < (section * ledsPerSection) + ledsPerSection)) {
            out[i] = 0;
        }
    }

    return out;
}
/*
function treeRender(this: Animation, time: number, input: RenderInput) {
    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);
    const sections = this.getParameter('Sections') as number;
    const direction = this.getParameter('Direction') as boolean;
    const onlyOne = this.getParameter('Only One') as number;
    percent = direction ? 1 - percent : percent;

    let coord = [0, 0, 0];

    for(let i = 0; i < input.ledCount; i++) {
        coord = input.treeData.positions[i];
        const topRange = input.treeData.bounds[1][2] - input.treeData.bounds[0][2];
        const section = (onlyOne > 0 ? (onlyOne - 1) : Math.floor(percent * sections)) + 1;
        const max = topRange / sections * section;
        const min = topRange / sections * (section - 1);
        if(coord[2] < max + input.treeData.bounds[0][2] && coord[2] >= min) {
            input.out[i] = (this.getParameter('Color') as Color).raw();
        }
    }

    return input.out;
}

function render(this: Animation, time: number, input: RenderInput) {
}*/
