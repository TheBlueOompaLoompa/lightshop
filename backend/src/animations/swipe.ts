import Color from "../lib/color";
import Animation, { type RenderInput } from "../lib/animation";
import { TargetType } from "../schema/settings";


const anim = new Animation(
    'Swipe',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Direction',
            type: 'number',
            value: 0
        },
        {
            name: 'InvertDirection',
            type: 'bool',
            value: false
        },
        {
            name: 'InvertFill',
            type: 'bool',
            value: false
        }
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

function mult(v: number, x: number): number {
    return ((((v >> 24) & 0xff) * x) << 24) | ((((v >> 16) & 0xff) * x) << 16) | ((((v >> 8) & 0xff) * x) << 8)
}

function render(this: Animation, input: RenderInput) {
    const direction = this.getParameter('Direction') as number;
    const invertDirection = this.getParameter('InvertDirection') as boolean;
    const invertFill = this.getParameter('InvertFill') as boolean;

    let percent = input.time;

    percent = invertFill ? 1 - percent : percent;

    if(input.spatialData) {
        let coord = 0;
        let bottomCoord = 0;
        let topCoord = 0;

        for(let i = 0; i < input.ledCount; i++) {
            coord = input.spatialData.positions[i][direction];
            if(!invertDirection) {
                bottomCoord = input.spatialData.bounds[0][direction];
                topCoord = input.spatialData.bounds[1][direction];

                if(!((topCoord - bottomCoord) * percent + bottomCoord > coord)) {
                    input.out[i] = 0;
                }
            }else {
                bottomCoord = input.spatialData.bounds[1][direction];
                topCoord = input.spatialData.bounds[0][direction];

                if(!((topCoord - bottomCoord) * percent + bottomCoord < coord)) {
                    input.out[i] = 0;
                }
            }
        }
    }else {
        for(let i = 0; i < input.out.length; i++) {
            if(direction == 1) {
                input.out[i] = mult(input.out[i], input.ledCount - i <= Math.floor(percent*input.out.length) ? 1 : 0);
            }else {
                input.out[i] = mult(input.out[i], i <= Math.floor(percent*input.out.length) ? 1 : 0);
            }
        }
    }
}

/*function treeRender(this: Animation, time: number, input: RenderInput) {
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
}*/
