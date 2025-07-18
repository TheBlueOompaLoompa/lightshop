extends Clip
class_name EffectClip

signal effects_changed
signal drivers_changed

@export var effects: Array[Effect] = []:
    set(v):
        effects = v
        effects_changed.emit()
        emit_changed()
@export var drivers: Array[ParameterDriver] = []:
    set(v):
        drivers = v
        drivers_changed.emit()
