class_name Device extends Resource

static var CONTROL_PORT = 1335

@export var name: String
@export var address: String:
    set(v):
        address = v
        for target in targets.values():
            target.address = address
@export var targets: Dictionary[String, Target] = {}


signal remote_config(config: Dictionary)
signal connected
signal status_update(status: StreamPeerTCP.Status)

signal update_remote_config_called(device_name: String)

var control_peer = StreamPeerTCP.new()

func connect_control() -> Error:
    if control_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
        return OK
    control_peer = StreamPeerTCP.new()
    var addrs = IP.resolve_hostname_addresses(address, IP.TYPE_ANY)
    if addrs.size() < 1: return ERR_UNAVAILABLE
    return control_peer.connect_to_host(addrs[0], CONTROL_PORT)

func is_control_connected():
    return control_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED

var status = StreamPeerTCP.STATUS_NONE

func poll():
    control_peer.poll()
    if status != control_peer.get_status():
        status = control_peer.get_status()
        status_update.emit(status)
        if status == StreamPeerTCP.STATUS_CONNECTED:
            connected.emit()
        
    if control_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED and control_peer.get_available_bytes() > 0:
        var raw := PackedByteArray(control_peer.get_data(control_peer.get_available_bytes())[1])
        var string = raw.get_string_from_utf8()
        var data = JSON.parse_string(string)
        if data['msg'].keys().has('CONFIG'):
            remote_config.emit(data['msg']['CONFIG']['new_config'])

func put_msg(msg_type: String, data: Variant) -> Error:
    var payload = ('{"device_name": "", "msg": { "' + msg_type + '":' + JSON.stringify(data) + ' } }').to_multibyte_char_buffer("utf-8")
    return control_peer.put_data(payload)

func get_remote_config() -> Error:
    return put_msg('INTROSPECT', {})

func gen_outputs() -> Array[Dictionary]:
    var arr: Array[Dictionary] = []
    for target in targets.values():
        var dict: Dictionary
        if target.type == Target.Type.LINEAR:
            dict = {
                "name": target.name,
                "platform": { "LINEAR": { "format": Target.StripType.keys()[Target.StripType.Ws2811Rgb], "led_order": "BRG", "max_brightness": 255, "freq": 800_000, "dma": 10 } },
                "count": target.count,
                "output_pins": target.pins,
                "port": target.port
            }
        arr.append(dict)
    return arr

func update_remote_config() -> Error:
    var config = {
        "name": name,
        "outputs": gen_outputs(),
    }
    var res = put_msg('CONFIG', config)
    update_remote_config_called.emit(name)
    return res


func restart_output(output_name: String) -> Error:
    var dict = { "output_name": output_name }
    return put_msg('RESTART', dict)
