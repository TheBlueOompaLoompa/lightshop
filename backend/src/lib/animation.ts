import { TargetType, Vec3 } from '$schema/settings';
import { Parameter } from '$schema/clip';
import type { z } from 'zod';

export default class Animation {
    name;
    targets;
    render;
    params;

    constructor(name: string, targets: z.infer<typeof TargetType>[], params: z.infer<typeof Parameter>[], render: (input: RenderInput) => Uint32Array) {
        this.name = name;
        this.targets = targets;
        this.params = params;
        this.render = render.bind(this);
    }

    public getParameter(name: string): any | undefined {
        const param = this.params.find(param => param.name === name);
        return param ? param.value : undefined;
    }

    public setParameter(name: string, value: any): boolean {
        this.params.forEach(param => {
            if(param.name == name) {
                param.value = value;
                return true;
            }
        })
        return false;
    }
}

export interface RenderInput {
    ledCount: number,
    spatialData: z.infer<typeof Vec3>[],
    time: number
    out: Uint32Array
}

