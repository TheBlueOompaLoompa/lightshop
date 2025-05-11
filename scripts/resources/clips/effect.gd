extends Clip
class_name EffectClip

@export var effects: Array[Effect] = []:
    set(_v):
        emit_changed()

func render(percent: float):
    return
