import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';
import SectionFlash from './sectionFlash';
import Twinkle from './twinkle';

export default {
    Solid,
    Reiser,
    SectionFlash,
    Twinkle
} as A;

interface A {
    [foo: string]: Animation
}
