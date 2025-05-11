extends CompositeClip
class_name TrackClip
@export var targets: Array[Target] = []:
    set(_v):
        emit_changed()

func render(percent: float):
    for clip in clips:
        if clip.start <= percent and clip.end > percent:
            return clip.render(percent)
