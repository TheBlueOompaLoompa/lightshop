import type Animation from '$lib/animation';
import Solid from './solid';
import Reiser from './reiser';

export default {
    Solid,
    Reiser
} as A;

interface A {
    [foo: string]: Animation
}
