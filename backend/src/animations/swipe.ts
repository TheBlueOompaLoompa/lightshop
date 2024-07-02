import { ParameterType } from "$schema/clip";
import Animation, { type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { TargetType } from "$schema/settings";


const anim = new Animation(
    'Swipe',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Color',
            type: ParameterType.enum.color,
            value: Color.fromHsv(0, 0, 0).hex
        },
        {
            name: 'Direction',
            type: ParameterType.enum.number,
            value: 0
        },
        {
            name: 'InvertDirection',
            type: ParameterType.enum.bool,
            value: false
        },
        {
            name: 'InvertFill',
            type: ParameterType.enum.bool,
            value: false
        }
    ],
    render
);

export default anim;

function render(this: Animation, input: RenderInput) {
    const color = this.getParameter('Color') as Color;
    const direction = this.getParameter('Direction') as number;
    const invertFill = this.getParameter('InvertFill') as boolean;

    let percent = input.time;

    percent = invertFill ? 1 - percent : percent;

    for(let i = 0; i < input.out.length; i++) {
        if(direction == 1) {
            if(input.ledCount - i <= Math.floor(percent*input.out.length)) {
                input.out[i] = color.raw();
            }
        }else if(i <= Math.floor(percent*input.out.length)){
            input.out[i] = color.raw();
        }
    }

    return input.out;
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
