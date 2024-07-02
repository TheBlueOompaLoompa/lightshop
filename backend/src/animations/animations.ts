import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';
import SectionFlash from './sectionFlash';
import Twinkle from './twinkle';
import Swipe from './swipe';
import Gunshot from './shot';

export default {
    Solid,
    Reiser,
    SectionFlash,
    Twinkle,
    Swipe,
    Gunshot
} as A;

interface A {
    [foo: string]: Animation
}
