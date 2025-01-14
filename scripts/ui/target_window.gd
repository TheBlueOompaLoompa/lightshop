extends Window

signal confirmed(target: Target)

@onready var name_node = $Vertical/Grid/Name
@onready var address_node = $Vertical/Grid/Address
@onready var type_node = $Vertical/Grid/Type
@onready var calibration_node = $Vertical/Calibration
@onready var led_count_node = $Vertical/Grid/LedCount

@export var target = Target.new()
@export var id = -1

func _on_visibility_changed():
    if visible:
        reset_content()


func reset_content():
    name_node.text = target.name
    address_node.text = target.address
    type_node.selected = target.type
    led_count_node.value = target.leds
    calibration_node.visible = target.type == 1


func _on_type_item_selected(index: int) -> void:
    calibration_node.visible = index == 1


func _on_cancel_pressed() -> void:
    hide()
    reset_content()
    target = Target.new()
    id = -1


func _on_confirm_pressed() -> void:
    if len(name_node.text) < 1:
        return
    if len(address_node.text) < 1:
        return
    if type_node.selected == 1 and target.points.size() < 1:
        return
    if led_count_node.value < 1:
        return
    
    target.name = name_node.text
    target.address = address_node.text
    target.type = type_node.selected
    target.leds = led_count_node.value
    
    confirmed.emit(target, id)
    hide()
    reset_content()
    target = Target.new()
    id = -1


func _on_calibration_file_selected(path: String) -> void:
    var text = FileAccess.open(path, FileAccess.READ).get_as_text()
    var lines = text.replace('\r', '').split('\n')
    for line in lines:
        var vec_arr = line.split(';')
        if len(vec_arr) > 2:
            target.points.append(Vector3(float(vec_arr[0]), float(vec_arr[1]), float(vec_arr[2])))


func _on_calibration_pressed() -> void:
    $CalibrationFileDialog.show()
