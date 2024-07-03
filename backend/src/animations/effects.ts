import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';
import Section from './sectionFlash';
import Twinkle from './twinkle';
import Swipe from './swipe';
import Gunshot from './shot';

export default {
    Solid,
    Reiser,
    Section,
    Twinkle,
    Swipe,
    Gunshot
} as A;

interface A {
    [foo: string]: Animation
}
