extends Node
class_name Renderer

signal compilation_failed(error: String)
signal compilation_successful

@export var project: Project:
    set(v):
        project = v
        if project != null:
            _on_project_loaded()
@export var settings: Settings:
    set(v):
        settings = v
        if settings != null:
            settings.device_changed.connect(_on_settings_device_changed)
@export var effects: Effects:
    set(v):
        effects = v
        if effects != null:
            _on_effects_changed()
            effects.changed.connect(_on_effects_changed)
            for effect in effects.values():
                effect.changed.connect(_on_effects_changed)
@export var preview: Preview

var rd: RenderingDevice
var connections: Dictionary[String, RenderConn]
var renderer_template = ""

var renderer_source = ""
var noise_source = ""
var renderer_compiled_successfully = false
var renderer_loaded: Dictionary[String, bool] = {}

func _init() -> void:
    rd = RenderingServer.create_local_rendering_device()
    var file = FileAccess.open("res://renderer.glsl", FileAccess.READ)
    renderer_template = file.get_as_text()
    file.close()
    file = FileAccess.open("res://FastNoiseLite.glsl", FileAccess.READ)
    noise_source = file.get_as_text()
    file.close()


func _on_project_loaded():
    project.tracks_changed.connect(on_tracks_changed)
    on_tracks_changed()


func _on_settings_device_changed(device: Device, _idx: int):
    for target in device.targets.values():
        update_render_conn(target.path)
        restart_device(device, target.name)


func on_tracks_changed():
    for track in project.tracks:
        var t_changed = func():
            on_track_changed(track)
        if not track.renderer_reload.is_connected(t_changed):
            track.renderer_reload.connect(t_changed)
            on_track_changed(track)


var polling_devices: Dictionary[String, Device]
func _process(_delta: float) -> void:
    for device in polling_devices.values():
        device.poll()


func on_track_changed(track: TrackClip):
    for t in track.targets:
        await update_render_conn(t.path, track)
    _on_effects_changed()


func update_render_conn(path: String, track: TrackClip = null) -> Error:
    var target: Target
    var device: Device
    for d in settings.devices:
        if d.name == path.split('/')[0]:
            device = d
            target = d.targets.get(path.split('/')[1])
            break
    if target == null: return ERR_DOES_NOT_EXIST
    
    var err = OK
    if not connections.has(path):
        if track == null: return ERR_INVALID_PARAMETER
        err = await restart_device(device, target.name)
        connections.set(target.path, RenderConn.new(target, track, preview))
    else:
        err = await restart_device(device, target.name)
        (connections.get(path) as RenderConn).reset_output_params(target)
    
    return err


func restart_device(device: Device, output_name: String):
    var err = OK
    device.connect_control()
    polling_devices.set(device.name, device)
    var conn_status = StreamPeerTCP.STATUS_CONNECTING
    while conn_status != StreamPeerTCP.STATUS_CONNECTED and conn_status != StreamPeerTCP.STATUS_ERROR:
        conn_status = await device.status_update
    if conn_status == StreamPeerTCP.STATUS_CONNECTED:
        device.restart_output(output_name)
    else:
        err = ERR_CANT_CONNECT
    polling_devices.erase(device.name)
    if err != OK:
        Log.error('Failed to restart output', device.name + '/' + output_name, error_string(err))
    return err


func _on_effects_changed():
    renderer_source = generate_renderer()
    var shader_source = RDShaderSource.new()
    shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
    shader_source.set_stage_source(RenderingDevice.SHADER_STAGE_COMPUTE, renderer_source)
    var shader_spirv := rd.shader_compile_spirv_from_source(shader_source)
    if shader_spirv.compile_error_compute:
        renderer_compiled_successfully = false
        var lines = renderer_source.split("\n")
        var error_lines = shader_spirv.compile_error_compute.split("\n")
        var err_line_num = 0
        for line in error_lines:
            if line.begins_with("ERROR: "):
                err_line_num = int(line.split(":")[2])
                break
        var error_output: String = shader_spirv.compile_error_compute
        var i = err_line_num - 5
        for line in lines.slice(err_line_num - 5, err_line_num + 5):
            error_output += str(i) + " " + line + "\n"
            i += 1
        Log.error("Renderer compilation error", error_output)
        compilation_failed.emit(error_output)
    else:
        compilation_successful.emit()
        renderer_compiled_successfully = true
        for client in connections.values():
            client.renderer_source = renderer_source
            client.load_renderer()


func generate_renderer() -> String:
    var temp = renderer_template
    
    var effect_source = ""
    var run_source = ""
    
    for effect in effects.values():
        effect_source += effect.generate_params_glsl() + "\n\n"
        effect_source += effect.generate_loader_glsl() + "\n\n"
        effect_source += effect.generate_exec_glsl() + "\n\n"
        run_source += effect.generate_call_glsl() + "\n"
    
    var rns = ""
    for line in run_source.split("\n"):
        rns += "    " + line + "\n"
    
    temp = temp.replace("// EFFECT REPLACE", effect_source).replace("// RUN REPLACE", rns).replace("// NOISE REPLACE", noise_source)
    return temp


func deinit():
    for conn in connections.values():
        conn.deinit()


func param_edit(track: TrackClip):
    if not renderer_compiled_successfully: return
    for target in track.targets:
        connections.get(target.path).param_edit()


func render(beats: float, delta: float):
    if not renderer_compiled_successfully: return
    for track in project.tracks:
        var has_clip = false
        if track.render_enable:
            for clip in track.clips:
                if clip.start <= beats and clip.end > beats:
                    render_clip(track, clip, (beats - clip.start)/(clip.end-clip.start), delta)
                    has_clip = true
        if not has_clip:
            for target in track.targets:
                var conn = connections.get(target.path)
                if conn == null or not conn.renderer_loaded: continue
                conn.no_clip()


func render_clip(track: TrackClip, clip: EffectClip, time: float, delta: float):
    if not renderer_compiled_successfully: return
    for target in track.targets:
        var conn: RenderConn = connections.get(target.path)
        if conn == null or not conn.renderer_loaded: continue
        conn.render_delta += delta
        if conn.render_delta >= 1.0/target.framerate:
            conn.render_clip(track, clip, time)
            conn.render_delta = 0
