class_name Port
extends Resource

@export var is_output: bool
@export var type: Type
@export var name: String
@export var removable: bool

static func setup(_name: String, _type: Type, _is_output: bool, _removable: bool):
    var port = Port.new()
    port.name = _name
    port.type = _type
    port.is_output = _is_output
    port.removable = _removable
    return port
    

enum Type {
    Int,
    Float,
    Vector2,
    Vector3,
    Vector4,
    Color,
    Bool,
}

const TypeStrings = [
    "int",
    "float",
    "vec2",
    "vec3",
    "vec4",
    "vec4",
    "bool"
]

const TypeColors = [
    Color.GRAY,
    Color.BLUE,
    Color.DODGER_BLUE,
    Color.LAWN_GREEN,
    Color.MEDIUM_PURPLE,
    Color.YELLOW,
    Color.WHITE,
]
