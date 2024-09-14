import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';
import Section from './sectionFlash';
import Twinkle from './twinkle';
import Swipe from './swipe';
import Gunshot from './shot';
import TimeScale from './timescale';
import AddMix from './addmix';

export default {
    Solid,
    Reiser,
    Section,
    Twinkle,
    Swipe,
    Gunshot,
    TimeScale,
    AddMix
} as A;

interface A {
    [foo: string]: Animation
}
