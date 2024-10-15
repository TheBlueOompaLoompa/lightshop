import type { Bpm } from './types';

export function time2beats(time: number, pbpms: Bpm[], startBpm: number | undefined) {
    let bpms: Bpm[] = [];
    Object.assign(bpms, pbpms);
    if(startBpm) bpms = [{ beat: 0, bpm: startBpm, project: '' }, ...bpms];

    let timeLeft = time;
    let beats = 0;

    bpmFor: for(let i = 0; i < bpms.length; i++) {
        const lastingBeats = (i < bpms.length - 1 ? bpms[i+1].beat : (timeLeft/60*bpms[i].bpm)) - bpms[i].beat;

        const thisBeats = Math.min(lastingBeats, timeLeft/1000/60*bpms[i].bpm);
        beats += thisBeats;
        timeLeft -= 1 / bpms[i].bpm * thisBeats * 60 * 1000;
        if(timeLeft <= 0) break bpmFor;
    }

    return beats;
}

export function beats2time(beats: number, pbpms: Bpm[], startBpm: number | undefined) {
    let bpms: Bpm[] = [];
    Object.assign(bpms, pbpms);
    if(startBpm) bpms = [{ beat: 0, bpm: startBpm, project: '' }, ...bpms];

    let beatsLeft = beats;
    let time = 0;

    bpmFor: for(let i = 0; i < bpms.length; i++) {
        const lastingBeats = (i < bpms.length - 1 ? bpms[i+1].beat : beatsLeft) - bpms[i].beat;

        const thisTime = Math.min(1/bpms[i].bpm*lastingBeats * 60 * 1000, 1/bpms[i].bpm*beatsLeft * 60 * 1000);
        time += thisTime;
        beatsLeft -= bpms[i].bpm * thisTime / 60 / 1000;
        if(beatsLeft <= 0) break bpmFor;
    }

    return time;
}

export function vecSub(a: number[], b: number[]) {
    return a.map((v, i) => v - b[i]);
}
