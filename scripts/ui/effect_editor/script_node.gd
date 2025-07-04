extends EffectNode
class_name ScriptNode

const SCRIPT_EDITOR = preload("uid://c1jr058pj22aq")
const PORT_ADD_ROW = preload("uid://b5nor3j4iffq1")

@export_storage var setup = false

func _ready():
    if setup: return
    setup = true
    var vbox = VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    
    var editor = SCRIPT_EDITOR.instantiate()    
    var row = PORT_ADD_ROW.instantiate()

    vbox.add_child(editor)
    vbox.add_child(row)
    
    add_content_slot(vbox)
    
    var name_node = row.get_node("Name")
    var port_type_node = row.get_node("PortType")
    
    row.get_node("AddInput").pressed.connect(func():
        if _validate_new_port(name_node.text, port_type_node.selected, false):
            add_port(Port.setup(name_node.text, port_type_node.selected, false, true))
    )
    row.get_node("AddOutput").pressed.connect(func():
        if _validate_new_port(name_node.text, port_type_node.selected, true):
            add_port(Port.setup(name_node.text, port_type_node.selected, true, true))
    )
    
    resizable = true
    size = Vector2i(600, 400)

func compile():
    ""

func _validate_new_port(_name: String, type: int, is_out: bool) -> bool:
    if len(_name) == 0:
        return false
    for port in ports:
        if port.name == _name and is_out == port.is_output:
            return false
    if type < 0:
        return false
    if _name.contains(' '):
        return false
    return true
