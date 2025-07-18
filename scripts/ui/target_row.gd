extends PanelContainer

@export var status_panel: Panel

signal edit(id: int)
signal delete(id: int)

var timer = Timer.new()
var miss_count = 0
var hit_last = false

var dev := Device.new()

@export var address: String:
    set(v):
        address = v
        dev.address = address
        timer = Timer.new()
        timer.name = "Timer"
        timer.autostart = true
        timer.wait_time = 1
        dev.connect_control()
        var status = StreamPeerTCP.STATUS_CONNECTING
        while status == StreamPeerTCP.STATUS_CONNECTING:
            status = await dev.status_update
        
        timer.timeout.connect(func():
            if hit_last == false:
                miss_count+=1
            if miss_count >= 3:
                var style_box: StyleBoxFlat = status_panel.get_theme_stylebox("panel").duplicate(true)
                style_box.bg_color = Color.RED
                status_panel.remove_theme_stylebox_override("panel")
                status_panel.add_theme_stylebox_override("panel", style_box)
           
            if not dev.is_control_connected():
                dev.connect_control()
                await dev.connected
                return
            var query_res = dev.get_remote_config()
            if query_res != OK:
                print(query_res)
                return
            await dev.remote_config
            hit_last = true
            miss_count = 0
            var style_box: StyleBoxFlat = status_panel.get_theme_stylebox("panel").duplicate(true)
            style_box.bg_color = Color.GREEN
            status_panel.remove_theme_stylebox_override("panel")
            status_panel.add_theme_stylebox_override("panel", style_box)
        )
        if has_node("Timer"):
            get_node("Timer").queue_free()
        add_child(timer)
@export var editable = true:
    set(v):
        editable = v
        $Margin/TargetRow/HBoxContainer/Edit.visible = editable
var id = -1


func _process(_delta: float) -> void:
    if !timer.paused:
        dev.poll()
    

func set_target_name(text: String):
    name = text
    $Margin/TargetRow/Name.text = text

func set_target_id(num: int):
    id = num

func _on_edit_pressed() -> void:
    edit.emit(id)


func _on_delete_pressed() -> void:
    delete.emit(id)


func _on_visibility_changed() -> void:
    if is_visible_in_tree():
        timer.paused = false
    else:
        timer.paused = true
