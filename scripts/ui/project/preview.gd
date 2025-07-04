class_name Preview extends PanelContainer
@export var preview_rect: TextureRect
@export var viewport: SubViewport
@export var camera: Camera3D
@export var camera_y_axis: Node3D
@export var out_mat: ShaderMaterial

@export var project: Project = null:
    set(v):
        project = v
        camera_y_axis.position = project.preview_cam_pos
        camera_y_axis.rotation.y = project.preview_cam_rot.y
        camera.rotation.x = project.preview_cam_rot.x
@export var settings: Settings = null

var rmb_pressed = false
var move: Vector2 = Vector2.ZERO

var server = UDPServer.new()
var peer: PacketPeerUDP = null

var compressor = StreamPeerGZIP.new()

func _ready():
    server.listen(8080)

func _process(delta: float) -> void:
    if settings == null or project == null: return
    
    server.poll() # Important!
    if server.is_connection_available():
        peer = server.take_connection()
    if peer != null:
        if peer.get_available_packet_count() > 0:
            out_mat.set_shader_parameter("render_buf", peer.get_packet().decompress(600*4, FileAccess.CompressionMode.COMPRESSION_GZIP))
    
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
        
