extends CompositeClip
class_name TrackClip

@export var render_enable: bool = true:
    set(v):
        render_enable = v

@export var targets: Array[Target] = []:
    set(v):
        targets = v
        emit_changed()


func render(percent: float):
    for clip in clips:
        if clip.start <= percent and clip.end > percent:
            return clip.render(percent)
