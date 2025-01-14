extends Button
class_name Renderer

var client: PacketPeerUDP

var buf_size = 600
var led_count = 600

var gc := GPUComputer.new()

var conf_buf = PackedByteArray()
var start = Time.get_unix_time_from_system()

var started = false

func start_render():
    client = PacketPeerUDP.new()
    client.connect_to_host('192.168.1.3', 8080)
    
    gc.shader_file = load("res://scripts/shaders/renderer.glsl")
    gc._load_shader()
    var buf = PackedInt32Array()
    buf.resize(buf_size)
    
    conf_buf.resize(8)
    conf_buf.encode_float(0, 0.0)
    conf_buf.encode_float(4, led_count)
    
    gc._add_buffer(0, 0, buf.to_byte_array())
    gc._add_buffer(0, 1, conf_buf)
    gc._make_pipeline(Vector3i(led_count, 1, 1), true)
    gc._submit()
    started = true


func _process(_d):
    if not started:
        return
    gc._sync()
    var out = gc.output(0, 0)
    client.put_packet(gzip_encode(out))
    
    gc._update_buffer(out, 0, 0)
    conf_buf.encode_float(0, (Time.get_unix_time_from_system() - start) * 8)
    gc._update_buffer(conf_buf, 0, 1)
    gc._make_pipeline(Vector3i(led_count, 1, 1))
    gc._submit()

func gzip_encode(data):
    var compressor = StreamPeerGZIP.new()
    compressor.start_compression()
    compressor.put_data(data)
    compressor.finish()
    return compressor.get_data(compressor.get_available_bytes())[1]
