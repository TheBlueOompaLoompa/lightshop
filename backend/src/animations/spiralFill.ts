import { vecSub } from "../util";
import Animation, { type RenderInput } from "../lib/animation";
import Color from "../lib/color";
import { TargetType } from "../schema/settings";

const anim = new Animation(
    'SpiralFill',
    [TargetType.enum.spatial],
    [
        {
            name: 'Direction',
            type: 'bool',
            value: false,
        },
        {
            name: 'Orientation',
            type: 'select',
            options: ['X','Y','Z'],
            value: 'Y'
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

function render(this: Animation, input: RenderInput) {
    const direction = this.getParameter('Direction') as boolean;
    const invertFill = !this.getParameter('InvertFill') as boolean;
    const orientation = this.getParameter('Orientation') as string;

    const angle = (invertFill?1-input.time:input.time)*2*Math.PI;

    if(!input.spatialData) return;
    for(let i = 0; i < input.ledCount; i++) {
        let pointAngle = 0;
        const coord = normalized(vecSub(input.spatialData.positions[i], input.spatialData.bounds[2]));
        switch(orientation) {
            case 'X':
                pointAngle = Math.atan2(coord[1], coord[0]);
                break;
            case 'Y':
                pointAngle = Math.atan2(coord[2], coord[0]);
                break;
            case 'Z':
                pointAngle = Math.atan2(coord[1], coord[2]);
                break;
        }

        if(pointAngle < 0) pointAngle += 2*Math.PI;
        if((pointAngle < angle) != direction) input.out[i] = 0;
    }
}

function normalized(vec: number[]) {
    const greatest = Math.max(Math.abs(vec[0]), Math.abs(vec[1]), Math.abs(vec[2]));
    return [vec[0]/greatest, vec[1]/greatest, vec[2]/greatest];
}

/*
import { normalize, sub } from "$lib/vec";
function render(this: Animation, time: number, input: RenderInput) {
    const relTime = time - this.start;
    let percent = relTime / (this.end - this.start);
    const direction = this.getParameter('Direction') as boolean;
    const invertFill = this.getParameter('InvertFill') as boolean;

    if(invertFill) percent = 1 - percent;

    let coord = [0, 0, 0];

    for(let i = 0; i < input.ledCount; i++) {
        coord = input.spatialData.positions[i];
        const vec = normalize(sub(coord, input.spatialData.center));
        
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
            Math.cos(angle) * input.spatialData.bounds[1][0],
            Math.sin(angle) * input.spatialData.bounds[1][1],
            0
        ];

        if(input.spatialData.bounds[0][0] < coord[0] && coord[0] < input.spatialData.bounds[1][0] && input.spatialData.bounds[0][1] < coord[1] && coord[1] < input.spatialData.bounds[1][1]) {
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
