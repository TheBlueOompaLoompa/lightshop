class_name RenderConn extends PacketPeerUDP

@export var target: Target
@export var render_delta := 0.0
@export var renderer_source: String

var thread: Thread
var semaphore: Semaphore
var mutex: Mutex
var action_queue: Array = []

var track: TrackClip
var clip_changed = false
var clip: EffectClip:
    set(v):
        clip = v
        clip_changed = true
var time: float

func _init(p_target: Target):
    target = p_target

    thread = Thread.new()
    semaphore = Semaphore.new()
    mutex = Mutex.new()

    thread.start(_render_thread)

var loaded = false

func load_renderer():
    mutex.lock()
    action_queue.push_front([Action.LOAD_RENDERER])
    if loaded:
        action_queue.push_front([Action.UNLOAD_RENDERER])
    loaded = true
    mutex.unlock()
    semaphore.post()


func _render_thread():
    var rd := RenderingServer.create_local_rendering_device()
    
    mutex.lock()
    var layers = PackedByteArray()
    layers.resize(target.leds*4*4*target.gpu_layers)
    
    var shader: RID
    var layers_buffer: RID = rd.storage_buffer_create(layers.size(), layers)

    var nothing = PackedByteArray()
    nothing.resize(4*target.leds)
    nothing = nothing.compress(FileAccess.CompressionMode.COMPRESSION_GZIP)

    var const_bytes := PackedByteArray()
    var param_bytes := PackedByteArray()
    var effect_bytes := PackedByteArray()
    var out_bytes := PackedByteArray()
    const_bytes.resize(20)
    param_bytes.resize(1) # Buffer size cannot be zero
    effect_bytes.resize(1)
    out_bytes.resize(target.leds*4)
    var const_buf = rd.storage_buffer_create(20, const_bytes)
    var param_buf = rd.storage_buffer_create(1, param_bytes)
    var effect_buf = rd.storage_buffer_create(1, effect_bytes)
    var out_buf = rd.storage_buffer_create(target.leds*4, out_bytes)

    var layers_uniform := RDUniform.new()
    layers_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    layers_uniform.binding = 0
    layers_uniform.add_id(layers_buffer)
    var const_uniform := RDUniform.new()
    const_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    const_uniform.binding = 1
    const_uniform.add_id(const_buf)
    var effects_uniform := RDUniform.new()
    effects_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    effects_uniform.binding = 2
    effects_uniform.add_id(effect_buf)
    var params_uniform := RDUniform.new()
    params_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    params_uniform.binding = 3
    params_uniform.add_id(param_buf)
    var out_uniform := RDUniform.new()
    out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    out_uniform.binding = 4
    out_uniform.add_id(out_buf)
    var uniform_set = null
    var pipeline = null

    mutex.unlock()

    while true:
        semaphore.wait()
        mutex.lock()
        if len(action_queue) > 0:
            var action = action_queue.pop_back()
            if action[0] == Action.LOAD_RENDERER:
                var shader_source = RDShaderSource.new()
                shader_source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
                shader_source.set_stage_source(RenderingDevice.SHADER_STAGE_COMPUTE, renderer_source)
                var shader_spirv := rd.shader_compile_spirv_from_source(shader_source)
                if shader_spirv.compile_error_compute:
                    var lines = renderer_source.split("\n")
                    var error_lines = shader_spirv.compile_error_compute.split("\n")
                    var err_line_num = 0
                    for line in error_lines:
                        if line.begins_with("ERROR: "):
                            err_line_num = int(line.split(":")[2])
                            break
                    print(shader_spirv.compile_error_compute)
                    var i = err_line_num - 5
                    for line in lines.slice(err_line_num - 5, err_line_num + 5):
                        print(str(i) + " " + line)
                        i += 1
                shader = rd.shader_create_from_spirv(shader_spirv)
            elif action[0] == Action.UNLOAD_RENDERER:
                rd.free_rid(shader)
            if len(action_queue) > 0:
                mutex.unlock()
                continue
        if clip == null or clip.effects.size() == 0:
            put_packet(nothing)
            mutex.unlock()
            continue
        if clip_changed:
            clip_changed = false
            param_bytes.clear()

            layers.fill(0)
            rd.buffer_update(layers_buffer, 0, layers.size(), layers)
            layers_uniform.clear_ids()
            layers_uniform.add_id(layers_buffer)

            for effect in clip.effects:
                for param in effect.parameters:
                    if param.type == Parameter.Type.Color:
                        param_bytes.append_array(color_to_vec4bytes(param.data))
                    elif param.type == Parameter.Type.Int:
                        param_bytes.append_array(PackedInt32Array([param.data]).to_byte_array())
                    elif param.type == Parameter.Type.Float:
                        param_bytes.append_array(PackedFloat32Array([param.data]).to_byte_array())
                    elif param.type == Parameter.Type.Bool:
                        param_bytes.append_array(PackedInt32Array([param.data]).to_byte_array())
                    elif param.type == Parameter.Type.Curve:
                        param_bytes.append_array(PackedInt32Array([param.data.point_count]).to_byte_array())
                        for point in param.data.point_count:
                            param_bytes.append_array(PackedFloat32Array([param.data.get_point_position(point).x, param.data.get_point_position(point).y]).to_byte_array())
                        for point in param.data.point_count:
                            param_bytes.append_array(PackedFloat32Array([param.data.get_point_left_tangent(point), param.data.get_point_right_tangent(point)]).to_byte_array())

            params_uniform.clear_ids()
            rd.free_rid(param_buf)
            param_buf = rd.storage_buffer_create(param_bytes.size(), param_bytes)
            params_uniform.add_id(param_buf)
            
            effect_bytes.resize(clip.effects.size()*4)
            var offset = 0
            for effect in clip.effects:
                effect_bytes.encode_s32(offset, effect.uid)
                offset += 4
            
            effects_uniform.clear_ids()
            rd.free_rid(effect_buf)
            effect_buf = rd.storage_buffer_create(effect_bytes.size(), effect_bytes)
            effects_uniform.add_id(effect_buf)
            
            #if uniform_set is RID:
            #    rd.free_rid(uniform_set)
            #if pipeline is RID:
            #    rd.free_rid(pipeline)
        
        const_bytes.encode_float(0, time)
        const_bytes.encode_u32(4, target.leds)
        const_bytes.encode_u32(8, target.gpu_layers)
        const_bytes.encode_u32(12, clip.effects.size())
        const_bytes.encode_u32(16, target.type)
        rd.buffer_update(const_buf, 0, 20, const_bytes)    
        
        uniform_set = rd.uniform_set_create([layers_uniform, const_uniform, effects_uniform, params_uniform, out_uniform], shader, 0)
        pipeline = rd.compute_pipeline_create(shader)
        
        var compute_list := rd.compute_list_begin()
        rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
        rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
        rd.compute_list_dispatch(compute_list, target.leds, 1, 1)
        rd.compute_list_end()
        rd.submit()
        rd.sync()

        put_packet(rd.buffer_get_data(out_buf).compress(FileAccess.CompressionMode.COMPRESSION_GZIP))
        
        mutex.unlock()

func color_to_vec4bytes(color: Color) -> PackedByteArray:
    return PackedFloat32Array([color.r, color.g, color.b, color.a]).to_byte_array()


var was_null = false
func render_clip(t: TrackClip, c: EffectClip, ti: float):
    mutex.lock()
    track = t
    was_null = false
    if clip == null or clip.start != c.start:
        was_null = clip == null
        clip = c
        clip_changed = true
    time = ti
    mutex.unlock()
    if clip_changed and was_null or !was_null:
        semaphore.post()

func param_edit():
    mutex.lock()
    clip_changed = true
    mutex.unlock()
    semaphore.post()

func no_clip():
    if clip != null:
        mutex.lock()
        clip_changed = true
        clip = null
        mutex.unlock()
        semaphore.post()

func deinit():
    mutex.lock()
    thread.free()
    mutex.unlock()

enum Action {
    LOAD_RENDERER,
    UNLOAD_RENDERER
}
