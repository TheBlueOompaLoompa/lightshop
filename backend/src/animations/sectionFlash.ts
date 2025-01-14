//import { normalize, sub } from "$lib/vec";
import Animation, { type RenderInput } from "../lib/animation";
import { TargetType } from "../schema/settings";


const anim = new Animation(
    'Section',
    [TargetType.enum.linear, TargetType.enum.spatial],
    [
        {
            name: 'Sections',
            type: 'number',
            value: 2
        },
        {
            name: 'Direction',
            type: 'bool',
            value: false
        },
        {
            name: 'Orientation(Spatial)',
            type: 'select',
            options: ['X', 'Y', 'Z'],
            value: 'X'
        },
        {
            name: 'Only One',
            type: 'number',
            value: 0
        }
    ],
    render,
    function clone(this: Animation) {
        return new Animation(this.name, this.targets, this.params, render, this.clone)
    }
);

export default anim;

const Orient = {
    'X': 0,
    'Y': 1,
    'Z': 2
}

function render(this: Animation, input: RenderInput) {
    let { time: percent, out, ledCount, spatialData } = input;

    const sections = this.getParameter('Sections') as number;
    const direction = this.getParameter('Direction') as boolean;
    const onlyOne = this.getParameter('Only One') as number;
    const orientation = this.getParameter('Orientation(Spatial)') as string;

    percent = direction ? 1 - percent : percent;

    const section = onlyOne > 0 ? onlyOne - 1 : Math.floor(percent * sections);
    
    if(!spatialData) {
        const ledsPerSection = ledCount / sections;
        
        for(let i = 0; i < ledCount; i++) {
            if(!(i >= section * ledsPerSection && i < (section * ledsPerSection) + ledsPerSection)) {
                out[i] = 0;
            }
        }
    }else {
        const ori = Orient[orientation]
        const lower = spatialData.bounds[0][ori];
        const upper = spatialData.bounds[1][ori];

        const sectionHeight = (upper-lower)/sections;
        for(let i = 0; i < ledCount; i++) {
            if(!(spatialData.positions[i][ori] > lower + sectionHeight * section &&
                 spatialData.positions[i][ori] < lower + sectionHeight * (section+1))) {
                input.out[i] = 0;
            }
                    /*if(!(spatialData.positions[i][Orient[orientation]] < sectionHeight * (section+1) && spatialData.positions[i][Orient[orientation]] > sectionHeight*section)) {
                        input.out[i] = 0;
                    }*/
            /*switch(orientation) {
                case 'X':
                    break;
                case 'Y':
                    if(!(spatialData.positions[i][1] < sectionHeight * (section+1) && spatialData.positions[i][Orient[orientation]] > sectionHeight*section)) {
                        input.out[i] = 0;
                    }
                    break;
                case 'Z':
                    break;
            }*/
            /*if(orientation == 'Y' != !((spatialData.positions[i][Orient[orientation]] < sectionHeight * (section+1) && spatialData.positions[i][Orient[orientation]] > sectionHeight*section) != Orient[orientation])) {
                input.out[i] = 0;
            }*/
        }
    }
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
