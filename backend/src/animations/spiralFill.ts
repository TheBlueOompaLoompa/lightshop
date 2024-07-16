import Animation, { type RenderInput } from "$lib/animation";
import Color from "$lib/color";
import { AnimationType } from "$lib/types";
import { normalize, sub } from "$lib/vec";

export default cloner

function cloner(){
    return new Animation(
        'Spiral',
        [AnimationType.Tree],
        [
            {
                name: 'Color',
                type: 'color',
                value: Color.fromHsv(0, 0, 0)
            },
            {
                name: 'Direction',
                type: 'bool',
                value: false
            }
            ,
            {
                name: 'InvertFill',
                type: 'bool',
                value: false
            }
        ],
        render, cloner
    );
}

function render(this: Animation, time: number, input: RenderInput) {
    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);
    const direction = this.getParameter('Direction') as boolean;
    const invertFill = this.getParameter('InvertFill') as boolean;

    if(invertFill) percent = 1 - percent;

    let coord = [0, 0, 0];

    for(let i = 0; i < input.ledCount; i++) {
        coord = input.treeData.positions[i];
        const vec = normalize(sub(coord, input.treeData.center));
        
        // Convert vec to angle
        let angle = Math.atan2(vec[1], vec[0]);
        if(angle < 0) angle += 2 * Math.PI;

        if(direction) {
            angle += percent * 2 * Math.PI;
        }else {
            angle -= percent * 2 * Math.PI;
        }

        // Convert angle to coord
        coord = [
            Math.cos(angle) * input.treeData.bounds[1][0],
            Math.sin(angle) * input.treeData.bounds[1][1],
            0
        ];

        if(input.treeData.bounds[0][0] < coord[0] && coord[0] < input.treeData.bounds[1][0] && input.treeData.bounds[0][1] < coord[1] && coord[1] < input.treeData.bounds[1][1]) {
            input.out[i] = (this.getParameter('Color') as Color).raw();
        }
    }

    return input.out;
}

/*
        out[i] = (this.getParameter('Color') as Color).raw();
    }

    return out;
}*/
