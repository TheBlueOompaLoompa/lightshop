extends CompositeClip
class_name TrackClip

@export var render_enable: bool = true:
    set(v):
        render_enable = v
        emit_changed()
@export var render_output_enable: bool = true:
    set(v):
        render_output_enable = v
        emit_changed()
@export var preview_output_enable: bool = true:
    set(v):
        preview_output_enable = v
        emit_changed()
@export var targets: Array[Target] = []:
    set(v):
        targets = v
        emit_changed()
@export var visible: bool = true:
    set(v):
        visible = v
        emit_changed()

func render(percent: float):
    for clip in clips:
        if clip.start <= percent and clip.end > percent:
            return clip.render(percent)
