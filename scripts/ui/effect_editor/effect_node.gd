class_name EffectNode
extends GraphNode

@export var ports: Array[Port] = []
@export_storage var _port_slot_map: Dictionary = {}
@export_storage var non_ports: Array[int] = []
@export_storage var EffectNode_setup = false

@onready var graph: EffectGraph = $".."

func _init() -> void:
    if EffectNode_setup: return
    EffectNode_setup = true
    var init_ports = ports
    for i in get_child_count():
        non_ports.append(i)
    ports = []
    for port in init_ports:
        add_port(port)

## Returns code [b]STRING on success[/b] or [b]NULL on error[/b]
func compile():
    return "ERROR: COMPILE NOT IMPLEMENTED effect_node.gd"

func refresh_ports():
    var to_remove: Array[Node] = []
    print('START PORT REFRESH')
    
    for child in len(get_children()):
        if is_slot_enabled_left(child) or is_slot_enabled_right(child):
            set_slot_enabled_left(child, false)
            set_slot_enabled_right(child, false)
            to_remove.append(get_child(child))
    
    for child in to_remove:
        child.free()
    
    var left_port_count = 0
    var right_port_count = 0
    var slot_row_count = 0
    
    for i in len(ports):
        var port = ports[i]
        if port.is_output: right_port_count += 1
        else: left_port_count += 1
        
        var count = right_port_count if port.is_output else left_port_count
        
        if slot_row_count < count:
            var slot_row_idx = _add_slot_row()
            slot_row_count += 1
            _port_slot_map[i] = slot_row_idx
            print("a i: " + str(i) + " slot: " + str(_port_slot_map[i]) + " name: " + port.name)
        else:
            _port_slot_map[i] = count + len(non_ports) - 1
            print("b i: " + str(i) + " slot: " + str(_port_slot_map[i]) + " name: " + port.name)
        
        var side = "Right" if port.is_output else "Left"
        var side_box = get_child(_port_slot_map[i]).get_node(side + 'Box')
        side_box.get_node(side + 'Label').text = port.name
        
        if port.is_output:
            set_slot_enabled_right(_port_slot_map[i], true)
            set_slot_type_right(_port_slot_map[i], port.type)
            set_slot_color_right(_port_slot_map[i], Port.TypeColors[port.type])
        else:
            set_slot_enabled_left(_port_slot_map[i], true)
            set_slot_type_left(_port_slot_map[i], port.type)
            set_slot_color_left(_port_slot_map[i], Port.TypeColors[port.type])
            var scene
            if port.type == Port.Type.Bool:
                scene = load("res://scenes/ui/inputs/bool.tscn").instantiate()
            elif port.type == Port.Type.Color:
                scene = load("res://scenes/ui/inputs/color.tscn").instantiate()
            elif port.type == Port.Type.Float:
                scene = load("res://scenes/ui/inputs/float.tscn").instantiate()
            elif port.type == Port.Type.Int:
                scene = load("res://scenes/ui/inputs/int.tscn").instantiate()
            elif port.type == Port.Type.Vector2:
                scene = load("res://scenes/ui/inputs/vec_2.tscn").instantiate()
            elif port.type == Port.Type.Vector3:
                scene = load("res://scenes/ui/inputs/vec_3.tscn").instantiate()
            elif port.type == Port.Type.Vector4:
                scene = load("res://scenes/ui/inputs/vec_4.tscn").instantiate()
            
            side_box.add_child(scene)
            side_box.move_child(scene, 1)
        
        
        if port.removable:
            var remove: Button = side_box.get_node('Remove')
            remove.show()
            remove.pressed.connect(func():
                disconnect_by_name(port.name, port.is_output)
                ports.erase(port)
                refresh_ports()
            )

func add_port(port: Port):
    ports.append(port)
    refresh_ports()

# Returns true if port is found and removed
func remove_port_by_name(_name: String, is_output: bool) -> bool:
    var conns = graph.get_connections(name)
    # Remove from ports list
    for pi in len(ports):
        var port = ports[pi]
        if port.name and port.is_output == is_output:       
            ports.remove_at(pi)
            refresh_ports()
            return true
    return false

func disconnect_by_name(_name: String, is_output: bool):
    var conns = graph.get_connections(name)
    var id = get_port_slot_id(_name, is_output)
    for conn in conns:
        if is_output and conn.get('from_node') == name and get_output_port_slot(conn.get('from_port')) == id:
            graph.disconnect_node(conn.get('from_node'), conn.get('from_port'), conn.get('to_node'), conn.get('to_port'))
        elif !is_output and conn.get('to_node') == name and get_input_port_slot(conn.get('to_port')) == id:
            graph.disconnect_node(conn.get('from_node'), conn.get('from_port'), conn.get('to_node'), conn.get('to_port'))

func get_port_slot_id(_name: String, is_output: bool) -> int:
    for i in len(ports):
        if ports[i].name == _name:
            return _port_slot_map[i]
    return -1
        

func get_port_type(i: int, is_from: bool):
    return get_slot_type_right(_port_slot_map[i]) if is_from else get_slot_type_left(_port_slot_map[i])


func add_content_slot(content: Node):
    non_ports.append(get_child_count())
    add_child(content)


# Add port slot row returns slot child index
func _add_slot_row() -> int:
    var big_box := HBoxContainer.new()
    
    var left_box := HBoxContainer.new()
    left_box.name = "LeftBox"
    left_box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var left_label = Label.new()
    left_label.name = "LeftLabel"
    left_box.add_child(left_label)
    
    var left_remove = Button.new()
    left_remove.name = "Remove"
    left_remove.text = "Remove"        
    left_box.add_child(left_remove)
    left_remove.hide()
        
    var middle_expand = HBoxContainer.new()
    middle_expand.name = "MiddleExpand"
    middle_expand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var right_box := HBoxContainer.new()
    right_box.name = "RightBox"
    
    var right_remove = Button.new()
    right_remove.name = "Remove"
    right_remove.text = "Remove"
    right_box.add_child(right_remove)
    right_remove.hide()
    
    var right_label = Label.new()
    right_label.name = "RightLabel"
    right_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    right_label.size_flags_horizontal = Control.SIZE_FILL
    right_box.add_child(right_label)
    
    big_box.add_child(left_box)
    big_box.add_child(middle_expand)
    big_box.add_child(right_box)
    add_child(big_box)
    return big_box.get_index()
