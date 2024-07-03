import { TargetType, Vec3 } from '../schema/settings';
import { Parameter } from '../schema/clip';
import type { z } from 'zod';
import Color from './color';
import type { Effect } from 'types';

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
        return param ? (param.type == 'color' ? Color.fromHex(param.value as string) : param.value) : undefined;
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

    get effect(): Effect {
        return { name: this.name, params: this.params }
    }
}

export interface RenderInput {
    ledCount: number,
    spatialData: z.infer<typeof Vec3>[] | undefined,
    time: number
    out: Uint32Array,
    extra: any,
}

