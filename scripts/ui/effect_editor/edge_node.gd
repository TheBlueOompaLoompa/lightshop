class_name EdgeNode
extends EffectNode

@export var type: Type = Type.Input
@export_storage var EdgeNode_setup = false

func _ready():
    if EdgeNode_setup: return
    EdgeNode_setup = true
    title = "Output" if type == Type.Output else "Input"
    name = title
    add_port(Port.setup("color", Port.Type.Color, type == Type.Input, false))
    add_port(Port.setup("time", Port.Type.Float, type == Type.Input, false))

enum Type {
    Input,
    Output
}
