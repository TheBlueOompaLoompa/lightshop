import { timelineSpacing } from '$lib/constants';

export const time2beats = (time: number, bpm: number) => time / 1000 / 60 * bpm;
export const beats2time = (beats: number, bpm: number) => 1 / bpm * beats * 60 * 1000;

export function snap(x: number, snapping: number) {
    let t = x > 0 ? x : 1;
    const out = Math.round(t / (1/snapping)) * (1/snapping);
    return snapping == 0 ? x : out; 
}

export const px2beats = (px: number, scale: number) => px / scale / timelineSpacing;

export const beats2px = (beats: number, scale: number) => beats * scale * timelineSpacing;
