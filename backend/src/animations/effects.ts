import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';
import Section from './sectionFlash';
import Twinkle from './twinkle';
import Swipe from './swipe';
import Gunshot from './shot';
import TimeScale from './timescale';
import AddMix from './addmix';
import Mix from './mix';
import TimeWiggle from './timewiggle';
import ColorFade from './colorFade';
import SpiralFill from './spiralFill';
import Loop from './loop';
import Text from './text';

export default {
    Solid,
    Twinkle,
    ColorFade,
    Reiser,
    Section,
    Swipe,
    SpiralFill,
    Gunshot,
    Text,
    TimeScale,
    TimeWiggle,
    Loop,
    AddMix,
    Mix,
} as A;

interface A {
    [foo: string]: Animation
}
