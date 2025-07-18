class_name Preview extends PanelContainer

@export var preview_rect: TextureRect
@export var viewport: SubViewport
@export var viewport_models_node: Node3D
@export var outputs_node: Node3D
@export var scene_node: Node3D
@export var camera: Camera3D
@export var camera_y_axis: Node3D
@export var model_file_dialog: FileDialog
@export var add_output_window: PreviewAddOutputWindow
@export var output_meshes: Dictionary[String, PreviewLight] = {}
@export var project: Project = null:
    set(v):
        project = v
        camera_y_axis.position = project.preview_cam_pos
        camera_y_axis.rotation.y = project.preview_cam_rot.y
        camera.rotation.x = project.preview_cam_rot.x
@export var settings: Settings = null:
    set(v):
        settings = v
        add_output_window.settings = settings

const LIGHT_SHADER_TEMPLATE = """
shader_type spatial;

uniform lowp uvec4 render_buf[BUF_SIZE];

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
    ALBEDO = vec3(render_buf[int(floor((1.0-UV.x)*BUF_SIZE.0))].rgb) / 255.0;
    EMISSION = ALBEDO * 20.0;
}"""

var rmb_pressed = false
var move: Vector2 = Vector2.ZERO

var servers: Dictionary[String, PreviewServer] = {}
var port_idx = 8080

## Returns opened port
func restart(path: String, target: Target) -> int:
    servers.set(path, PreviewServer.new(target, port_idx, output_meshes.get(path)))
    port_idx += 1
    return port_idx - 1


class PreviewServer extends PacketPeerUDP:
    var compressor = StreamPeerGZIP.new()
    var target: Target
    var out_mat: ShaderMaterial
    
    func _init(p_target: Target, port: int, mesh: MeshInstance3D) -> void:
        target = p_target
        bind(port, "127.0.0.1")
        if target.type == Target.Type.LINEAR or target.type == Target.Type.SPATIAL:
            out_mat = ShaderMaterial.new()
            var shader = Shader.new()
            shader.code = LIGHT_SHADER_TEMPLATE.replace("BUF_SIZE", str(target.count))
            out_mat.shader = shader
            if mesh != null:
                mesh.set_surface_override_material(0, out_mat)
    
    func process():
        if get_available_packet_count() > 0:
            if target.type == Target.Type.LINEAR or target.type == Target.Type.SPATIAL:
                var buf = get_packet().decompress(target.count*4, FileAccess.CompressionMode.COMPRESSION_GZIP)
                out_mat.set_shader_parameter("render_buf", buf)
  

func _process(delta: float) -> void:
    if settings == null or project == null: return
    
    for server in servers.values():
        server.process()
    
    viewport.size = preview_rect.texture.get_size()
    
    if rmb_pressed == false: return
    
    move = Vector2.ZERO
    if Input.is_action_pressed("move_forward"):
        move.y = -1.0
    if Input.is_action_pressed("move_backward"):
        move.y = 1.0
    if Input.is_action_pressed("move_left"):
        move.x = -1.0
    if Input.is_action_pressed("move_right"):
        move.x = 1.0
        
    camera_y_axis.position += camera.global_basis.z * move.y * delta * settings.move_speed
    camera_y_axis.position += camera.global_basis.x * move.x * delta * settings.move_speed
    
    if move != Vector2.ZERO:
        project.preview_cam_pos = camera_y_axis.position


func _on_preview_rect_gui_input(event:  InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            rmb_pressed = event.pressed
            if rmb_pressed:
                DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
            else:
                DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
    if settings == null or project == null: return
    if event is InputEventMouseMotion and rmb_pressed:
        camera_y_axis.rotate_y(-event.relative.x * (settings.look_speed / 100.0))
        camera.rotate_x(-event.relative.y * (settings.look_speed / 100.0))
        camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -80.0, 80.0)
        project.preview_cam_rot.y = camera_y_axis.rotation.y
        project.preview_cam_rot.x = camera.rotation.x  


func _on_load_model_pressed() -> void:
    model_file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
    var gltf = GLTFDocument.new()
    var gltf_state = GLTFState.new()
    gltf.append_from_file(path, gltf_state)
    var scene = gltf.generate_scene(gltf_state)
    
    viewport_models_node.add_child(scene)


func _on_add_output_pressed() -> void:
    add_output_window.show()


func _on_add_output_window_selected(target: Target) -> void:
    if target.type == Target.Type.SPATIAL:
        var light = PreviewLight.new()
        light.target = target
        light.width = 0.02
        light.update()
        output_meshes.set(target.path, light)
        outputs_node.add_child(light)


enum PreviewOutputDeviceType {
    LIGHT_STRIP,
    SPATIAL,
    LIGHT_SET,
    ROTATOR,
    MOVER,
    FOG_MACHINE,
}
