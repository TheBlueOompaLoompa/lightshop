extends Resource
class_name Clip

@export var name: String = "":
    set(v):
        name = v
        emit_changed()
@export var start: float = 0:
    set(v):
        start = v
        emit_changed()
@export var end: float = 0:
    set(v):
        end = v
        emit_changed()
@export var type: Target.Type:
    set(v):
        type = v
        emit_changed()

func new(_name: String, _start: float, _end: float, _type: Target.Type):
    name = _name
    start = _start
    end = _end
    type = _type

func render(percent: float):
    return
