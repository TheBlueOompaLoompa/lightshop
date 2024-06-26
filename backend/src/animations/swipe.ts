import Animation, { ParameterType, type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { AnimationType } from "$lib/types";

export function clonerTree(){
    return new Animation(
        'Swipe',
        [AnimationType.Tree],
        [
            {
                name: 'Color',
                type: ParameterType.color,
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Direction',
                type: ParameterType.number,
                value: 0
            },
            {
                name: 'InvertDirection',
                type: ParameterType.boolean,
                value: false
            }
            ,
            {
                name: 'InvertFill',
                type: ParameterType.boolean,
                value: false
            }
        ],
        treeRender, clonerTree
    );
}

export function clonerLinear(){
    return new Animation(
        'Swipe',
        [AnimationType.Linear],
        [
            {
                name: 'Color',
                type: ParameterType.color,
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Direction',
                type: ParameterType.boolean,
                value: 0
            },
            {
                name: 'InvertFill',
                type: ParameterType.boolean,
                value: false
            }
        ],
        linearRender, clonerLinear
    );
}

function treeRender(this: Animation, time: number, input: RenderInput) {
    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);
    const direction = this.getParameter('Direction');
    const invertDirection = this.getParameter('InvertDirection');

    if(this.getParameter('InvertFill')) percent = 1 - percent;

    let coord = 0;
    let bottomCoord = 0;
    let topCoord = 0;

    for(let i = 0; i < input.ledCount; i++) {
        coord = input.treeData.positions[i][direction];
        if(!invertDirection) {
            bottomCoord = input.treeData.bounds[0][direction];
            topCoord = input.treeData.bounds[1][direction];

            if((topCoord - bottomCoord) * percent + bottomCoord > coord) {
                input.out[i] = (this.getParameter('Color') as Color).raw();
            }
        }else {
            bottomCoord = input.treeData.bounds[1][direction];
            topCoord = input.treeData.bounds[0][direction];

            if((topCoord - bottomCoord) * percent + bottomCoord < coord) {
                input.out[i] = (this.getParameter('Color') as Color).raw();
            }
        }
    }

    return input.out;
}

function linearRender(this: Animation, time: number, input: RenderInput) {
    const color = this.getParameter('Color') as Color;
    const direction = this.getParameter('Direction') as boolean;
    const invertFill = this.getParameter('InvertFill');

    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);

    percent = invertFill ? 1 - percent : percent;

    for(let i = 0; i < input.out.length; i++) {
        if(direction) {
            if(input.ledCount - i <= Math.floor(percent*input.out.length)) {
                input.out[i] = color.raw();
            }
        }else if(i <= Math.floor(percent*input.out.length)){
            input.out[i] = color.raw();
        }
    }

    return input.out;
}