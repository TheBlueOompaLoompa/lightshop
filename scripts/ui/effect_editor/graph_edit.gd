extends GraphEdit
class_name EffectGraph

@export_storage var id = ""

static func create_unique(name: String) -> EffectGraph:
    var graph = EffectGraph.new()
    graph.name = name
    graph.id = uuid.v4()
    
    return graph


## Returns code [b]STRING on success[/b] or [b]NULL on error[/b]
func compile():
    var code = ""
    
    var input_node = get_node_or_null("Input")
    var output_node = get_node_or_null("Output")
    if input_node == null or output_node == null: return null
        
    for node in get_children():
        if node is EffectNode:
            var out = node.compile()
            if out == null: return null
    
    return code

func _ready() -> void:
    for type in Port.Type.size():
        add_valid_connection_type(type, type)
    
    add_valid_dual_connection_type(Port.Type.Color, Port.Type.Vector3)


func add_valid_dual_connection_type(type_a: int, type_b: int):
    add_valid_connection_type(type_a, type_b)
    add_valid_connection_type(type_b, type_a)


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    print("Conn Req", from_port, to_port)
    var from_type = -1
    var to_type = -1
    
    var from_index = 0
    var to_index = 0
    
    var from: GraphNode = get_node(NodePath(from_node))
    var to: GraphNode = get_node(NodePath(to_node))
    for slot_i in from.get_child_count():
        if from.is_slot_enabled_right(slot_i):
            if from_index == from_port:
                from_type = from.get_slot_type_right(slot_i)
            from_index+=1
    for slot_i in to.get_child_count():
        if to.is_slot_enabled_left(slot_i):
            if to_index == to_port:
                to_type = to.get_slot_type_left(slot_i)
            to_index+=1
    
    if is_valid_connection_type(from_type, to_type):
        var conn = has_connection(to_node, Direction.TO) # Left port already connected
        if has_node_in_net(to_node, from_node): # Check for recursive loops
            return
        var connected = get_connected_ports(from_node, to_node)
        if connected['ports'].has(to_port): # Disconnect previous connection on left
            var c = connected['conns']
            disconnect_node(c[to_port]['from_node'], c[to_port]['from_port'], c[to_port]['to_node'], c[to_port]['to_port'])
        connect_node(from_node, from_port, to_node, to_port) # Make connection
        
func get_connections(node: StringName):
    var out = []
    for conn in get_connection_list():
        if conn.get('from_node') == node or conn.get('to_node') == node:
            out.append(conn)
    return out

enum Direction {
    FROM,
    TO
}

func has_connection(node: StringName, dir = Direction.TO):
    var from = dir == Direction.FROM
    for conn in get_connection_list():
        if from and conn.get('from_node') == node:
            return conn
        elif !from and conn.get('to_node') == node:
            return conn
    return null

func get_connected_ports(from_node: StringName, to_node: StringName, key = Direction.TO) -> Dictionary:
    var out = { conns = {}, ports = {} }
    for conn in get_connection_list():
        if conn.get('from_node') == from_node and conn.get('to_node') == to_node:
            if key == Direction.TO:
                out['ports'].set(conn.get('to_port'), conn.get('from_port'))
                out['conns'].set(conn.get('to_port'), conn)
            else:
                out['ports'].set(conn.get('from_port'), conn.get('to_port'))
                out['conns'].set(conn.get('from_port'), conn)
    return out
    

func has_node_in_net(root: StringName, target: StringName, direction = Direction.FROM) -> bool:
    var dir_key = 'from_node'
    if direction == Direction.TO:
        dir_key = 'to_node'
    
    # Create quick lookup dictionary
    var node_dict = {}
    for conn in get_connection_list():
        var key = conn.get(dir_key)
        if not node_dict.has(key):
            node_dict[key] = []
        
        node_dict[key].append(conn)
    
    # Run actual search
    return _has_node_in_net_opt(root, target, direction, node_dict)

func _has_node_in_net_opt(root: StringName, target: StringName, direction: Direction, node_dict: Dictionary) -> bool:
    if not node_dict.has(root): return false
    var dir_key = 'from_node'
    if direction == Direction.FROM:
        dir_key = 'to_node'
    
    for conn in node_dict[root]:
        var to_node = conn.get(dir_key)
        if to_node == target:
            return true
        else:
            if _has_node_in_net_opt(to_node, target, direction, node_dict):
                return true
    return false
        

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
    disconnect_node(from_node, from_port, to_node, to_port)
