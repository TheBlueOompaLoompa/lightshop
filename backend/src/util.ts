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
