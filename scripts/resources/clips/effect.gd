extends Clip
class_name EffectClip

@export var effects: Array[Effect] = []:
    set(v):
        effects = v
        emit_changed()

func render(percent: float):
    return
