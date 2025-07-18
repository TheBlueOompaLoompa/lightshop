class_name TargetWindow extends Window

signal confirm(target: Target)

@export var name_node: LineEdit
@export var port_node: SpinBox
@export var count_node: SpinBox
@export var pins_node: LineEdit
@export var framerate_node: SpinBox
@export var type_node: OptionButton
@export var calibration_node: Button
@export var target: Target

@export var id = -1

func open(t: Target = Target.new(), i = -1):
    id = i
    target = t.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
    name_node.text = target.name
    port_node.value = target.port
    count_node.value = target.count
    pins_node.text = ",".join(PackedStringArray(target.pins))
    framerate_node.value = target.framerate
    type_node.selected = target.type
    show()

func _on_type_item_selected(index: int) -> void:
    calibration_node.visible = index == Target.Type.SPATIAL

func _on_calibration_file_selected(path: String) -> void:
    var text = FileAccess.open(path, FileAccess.READ).get_as_text()
    var lines = text.replace('\r', '').split('\n')
    for line in lines:
        var vec_arr = line.split(';')
        if len(vec_arr) > 2:
            target.points.append(Vector3(float(vec_arr[0]), float(vec_arr[1]), float(vec_arr[2])))
    
    var lower_bound = target.points[0]
    var upper_bound = target.points[0]
    
    for point in target.points:
        if point.x < lower_bound.x: lower_bound.x = point.x
        if point.y < lower_bound.y: lower_bound.y = point.y
        if point.z < lower_bound.z: lower_bound.z = point.z
        if point.x > upper_bound.x: upper_bound.x = point.x
        if point.y > upper_bound.y: upper_bound.y = point.y
        if point.z > upper_bound.z: upper_bound.z = point.z
    
    var offset = upper_bound - lower_bound
    
    for i in target.points.size():
        target.points[i] = (target.points[i] - lower_bound) / offset

func _on_calibration_pressed() -> void:
    $CalibrationFileDialog.show()


func _on_cancel_pressed() -> void:
    hide()


func _on_confirm_pressed() -> void:
    target.name = name_node.text
    target.port = int(port_node.value)
    target.count = int(count_node.value)
    if pins_node.text.length() >= 1:
        target.pins = []
        for pin_str in pins_node.text.split(','):
            target.pins.append(int(pin_str))
    else:
        return
    target.framerate = framerate_node.value
    target.type = type_node.selected as Target.Type
    
    if target.name.length() < 1:
        return
    if target.count < 1:
        return
    if target.framerate < 1:
        return
    if target.type == Target.Type.SPATIAL and target.points.size() != target.count:
        return
    
    confirm.emit(target)
    hide()
