class_name Computer

var rd: RenderingDevice
var shaders: Dictionary[String, RID] = {}
var target_buffers: Dictionary[Target, Array]

func _init() -> void:
    rd = RenderingServer.create_local_rendering_device()

func add_render_target(target: Target):
    var buffers = []
    for i in target.gpu_layers:
        if target.type == Target.Type.LINEAR:
            var input = PackedFloat32Array()
            input.resize(target.leds)
            var input_bytes := input.to_byte_array()
            var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
        elif target.type == Target.Type.SPATIAL:
            pass # TODO: Implement spatial target buffer
        elif target.type == Target.Type.BINARY:
            pass # TODO: Implement binary target buffer
        elif target.type == Target.Type.MOTION:
            pass # TODO: Implement motion target buffer
    
    target_buffers.set(target, buffers)
