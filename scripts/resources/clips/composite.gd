extends Clip
class_name CompositeClip

@export var clips: Array[Clip] = []:
    set(_v):
        emit_changed()

func render(percent: float):
    for clip in clips:
        if clip.start <= percent and clip.end > percent:
            return clip.render(percent)
