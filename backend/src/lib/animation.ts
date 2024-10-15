import { TargetType, Vec3 } from '../schema/settings';
import { Parameter } from '../schema/clip';
import type { z } from 'zod';
import Color from './color';
import type { Effect } from 'types';
import _ from 'lodash';

export default class Animation {
    name;
    targets;
    render;
    params;
    clone;
    extra: any;

    constructor(name: string, targets: z.infer<typeof TargetType>[], params: z.infer<typeof Parameter>[], render: (input: RenderInput) => any, clone: () => Animation) {
        this.name = name;
        this.targets = targets;
        this.params = params;
        this.render = render.bind(this);
        this.clone = clone.bind(this);
    }

    public getParameter(name: string): any | undefined {
        const param = this.params.find(param => param.name === name);
        if(param) {
            switch(param.type) {
                case 'color':
                    return Color.fromHex(param.value as string);
                case 'number':
                    return parseFloat(param.value as string);
                default:
                    return param.value;
            }
        }else return undefined;
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
    spatialData: { positions: z.infer<typeof Vec3>[], bounds: z.infer<typeof Vec3>[] } | undefined,
    time: number
    out: Uint32Array,
    extra: any,
}
