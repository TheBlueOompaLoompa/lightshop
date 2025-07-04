extends Node
class_name Renderer

@export var project: Project:
    set(v):
        project = v
        if project != null:
            _on_project_loaded()
@export var effects: Effects:
    set(v):
        effects = v
        if effects != null:
            _on_effects_changed()

var rd: RenderingDevice
var loaded_effects: Dictionary[String, RID]
var connections: Dictionary[String, RenderConn]
var renderer_template = ""

var renderer_source = ""
var noise_source = ""

func _init() -> void:
    rd = RenderingServer.create_local_rendering_device()
    var file = FileAccess.open("res://renderer.glsl", FileAccess.READ)
    renderer_template = file.get_as_text()
    file.close()
    file = FileAccess.open("res://FastNoiseLite.glsl", FileAccess.READ)
    noise_source = file.get_as_text()
    file.close()


func _on_project_loaded():
    renderer_source = generate_renderer()
    for track in project.tracks:
        for target in track.targets:
            if not connections.has(target.name):
                var client = RenderConn.new(target)
                client.renderer_source = renderer_source
                client.load_renderer()
                var split_addr = target.address.split(':')
                var addrs = IP.resolve_hostname_addresses("".join(split_addr.slice(0, -1)), IP.TYPE_ANY)
                if len(addrs) <= 0:
                    continue
                var addr = addrs[0]
                print("Connecting to ", addr, split_addr[split_addr.size()-1])
                client.connect_to_host(addr, int(split_addr[split_addr.size()-1]) if len(split_addr) > 0 else 8080)
                
                connections.set(target.name, client)


func _on_effects_changed():
    renderer_source = generate_renderer()
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
    
func has_effect(effect: Effect) -> bool:
    return loaded_effects.has(effect)
    
    
func deinit():
    for conn in connections.values():
        conn.deinit()


func param_edit(track: TrackClip):
    for target in track.targets:
        connections.get(target.name).param_edit()


func render(beats: float, delta: float):
    for track in project.tracks:
        var has_clip = false
        if track.render_enable:
            for clip in track.clips:
                if clip.start <= beats and clip.end > beats:
                    render_clip(track, clip, (beats - clip.start)/(clip.end-clip.start), delta)
                    has_clip = true
        if not has_clip:
            for target in track.targets:
                connections.get(target.name).no_clip()
#            for target in track.targets:
#                var empty = PackedByteArray()
#                empty.resize(target.leds*4)
#                connections.get(target.name).put_packet(gzip_encode(empty))


func color_to_u8vec4bytes(color: Color):
    return PackedByteArray([color.r8, color.g8, color.b8, color.a8])


func render_clip(track: TrackClip, clip: EffectClip, time: float, delta: float):
    for target in track.targets:
        var conn: RenderConn = connections.get(target.name)
        conn.render_delta += delta
        if conn.render_delta >= 1.0/target.framerate:
            conn.render_clip(track, clip, time)
            conn.render_delta = 0
