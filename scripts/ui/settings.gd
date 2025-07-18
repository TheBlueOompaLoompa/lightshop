class_name SettingsTab extends MarginContainer

signal Changed

@export var settings: Settings

@export var targets_node: VBoxContainer
@export var beacons_node: VBoxContainer
@export var device_window: DeviceWindow
@onready var ui_scale_node = $Scroll/VBox/Grid/UIScale
@onready var invert_timeline_scroll = $"Scroll/VBox/Invert Timeline Scroll"
var target_row_prefab = preload("uid://dltmtfearhooo")
var beacon_row_prefab = preload("uid://dwakharxm746o")

const BEACON_MAGIC = [0x1, 0xed]

var beacon_peer = PacketPeerUDP.new()
var config_peer = PacketPeerUDP.new()


func _ready() -> void:
    beacon_peer.bind(1336, "0.0.0.0")
    #config_peer.bind(8238, "0.0.0.0")
    #config_peer.set_dest_address("127.0.0.1", 1335)
    #var payload = '{"INTROSPECT":{}}'.to_multibyte_char_buffer("ascii")
    #config_peer.put_packet(payload)
    #payload = '{"CONFIG":{"new_config":{"name":"hi", "outputs": []}}}'.to_multibyte_char_buffer("ascii")
    #config_peer.put_packet(payload)
    #payload = '{"INTROSPECT":{}}'.to_multibyte_char_buffer("ascii")
    #config_peer.put_packet(payload)


var beacons: Dictionary[String, int] = {}


func _process(_delta: float) -> void:
    if beacon_peer.get_available_packet_count() > 0:
        var beacon_buffer = beacon_peer.get_packet()
        var byte = 0
        if(beacon_buffer[0] == BEACON_MAGIC[0] and beacon_buffer[1] == BEACON_MAGIC[1]):
            var beacon_ip = beacon_peer.get_packet_ip()
            byte += 2
            var control_port = beacon_buffer.decode_u16(byte)
            var new_beacon = beacons.has(beacon_ip)
            beacons.set(beacon_ip, control_port)
            print(beacons)
            if new_beacon:
                for child in beacons_node.get_children():
                    child.queue_free()
                for ip in beacons:
                    var exists = false
                    for device in settings.devices:
                        exists = device.address == ip or exists
                    if exists: continue
                    var row: BeaconRow = beacon_row_prefab.instantiate()
                    row.ip_label.text = ip
                    row.add_device_pressed.connect(func():
                        var dev = Device.new()
                        dev.address = ip
                        device_window.open(dev)
                    )
                    beacons_node.add_child(row)
    if config_peer.get_available_packet_count() > 0:
        print(JSON.parse_string(config_peer.get_packet().get_string_from_ascii()))


func reset_ui():
    settings.save_res()
    Changed.emit()
    
    invert_timeline_scroll.button_pressed = settings.invert_scroll
    
    # Grid settings
    ui_scale_node.value = settings.ui_scale
    
    device_window.content_scale_factor = settings.ui_scale
    
    # Render Targets
    for child in targets_node.get_children():
        child.queue_free()
    
    for i in settings.devices.size():
        var row = target_row_prefab.instantiate()
        row.address = settings.devices[i].address
        row.set_target_name(settings.devices[i].name)
        row.set_target_id(i)
        
        row.edit.connect(func(id):
            device_window.open(settings.devices[i], id)
        )
        
        row.delete.connect(func(id):
            settings.devices.pop_at(id)
            reset_ui()   
        )
        
        targets_node.add_child(row)


func _on_add_render_target_pressed() -> void:
    device_window.open()


func _on_device_window_confirmed(device: Device, id: int) -> void:
    device.update_remote_config()
    if id < 0:
        settings.devices.push_back(device)
        settings.device_changed.emit(device, settings.devices.size() - 1)
    else:
        settings.devices[id] = device
        settings.device_changed.emit(device, id)
    reset_ui()


func _on_visibility_changed() -> void:
    if visible:
        settings = Settings.load_res()
        reset_ui()


func _on_ui_scale_value_changed(value: float) -> void:
    settings.ui_scale = value
    reset_ui()


func _on_invert_timeline_scroll_toggled(toggled_on: bool) -> void:
    settings.invert_scroll = toggled_on
    reset_ui()
