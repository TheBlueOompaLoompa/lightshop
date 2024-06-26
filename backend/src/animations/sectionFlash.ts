import Animation, { ParameterType, type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { AnimationType } from "$lib/types";
import { normalize, sub } from "$lib/vec";

export function clonerTree(){
    return new Animation(
        'Section Flash',
        [AnimationType.Tree],
        [
            {
                name: 'Color',
                type: ParameterType.color,
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Sections',
                type: ParameterType.number,
                value: 2
            },
            {
                name: 'Direction',
                type: ParameterType.boolean,
                value: false
            },
            {
                name: 'Only One',
                type: ParameterType.number,
                value: 0
            }
        ],
        treeRender, clonerTree
    );
}

export function clonerLinear(){
    return new Animation(
        'Section Flash',
        [AnimationType.Linear],
        [
            {
                name: 'Color',
                type: ParameterType.color,
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Sections',
                type: ParameterType.number,
                value: 2
            },
            {
                name: 'Direction',
                type: ParameterType.boolean,
                value: false
            },
            {
                name: 'Only One',
                type: ParameterType.number,
                value: 0
            }
        ],
        linearRender, clonerLinear
    );
}

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

function linearRender(this: Animation, time: number, input: RenderInput) {
    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);
    const sections = this.getParameter('Sections') as number;
    const direction = this.getParameter('Direction') as boolean;
    const onlyOne = this.getParameter('Only One') as number;

    percent = direction ? 1 - percent : percent;

    const section = onlyOne > 0 ? onlyOne - 1 : Math.floor(percent * sections);
    const ledsPerSection = input.ledCount / sections;
    
    for(let i = 0; i < input.ledCount; i++) {
        if(i >= section * ledsPerSection && i < (section * ledsPerSection) + ledsPerSection) {
            input.out[i] = (this.getParameter('Color') as Color).raw();
        }
    }

    return input.out;
}