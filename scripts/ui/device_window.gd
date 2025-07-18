class_name DeviceWindow extends Window

signal confirmed(device: Device)

@export var name_node: LineEdit
@export var address_node: LineEdit
@export var targets_node: VBoxContainer
@export var target_window: TargetWindow

@export var device = Device.new()
var id: int = -1

const DEVICE_TARGET_ROW = preload("uid://bxod3rujy6g4a")


func open(d: Device = Device.new(), i: int = -1):
    id = i
    device = d.duplicate(false)
    device.targets = device.targets.duplicate(true)
    name_node.text = device.name
    address_node.text = device.address
    update_targets()
    show()


func update_targets():
    for child in targets_node.get_children():
        child.queue_free()
    for target in device.targets.values():
        var row = DEVICE_TARGET_ROW.instantiate()
        row.label.text = target.name
        row.edit.connect(func():
            target_window.open(target)
            update_targets()
        )
        row.delete.connect(func():
            device.targets.erase(target.name)
            update_targets()
        )
        targets_node.add_child(row)


func _on_cancel_pressed() -> void:
    hide()


func _on_confirm_pressed() -> void:
    if len(name_node.text) < 1:
        return
    if len(address_node.text) < 1:
        return
    
    device.name = name_node.text
    device.address = address_node.text
    
    for target in device.targets.values():
        target.address = device.address
        target.path = device.name + '/' + target.name
    
    confirmed.emit(device, id)
    hide()


func _on_add_target_pressed() -> void:
    target_window.open()


func _on_target_window_confirm(target: Target) -> void:
    if target_window.id != -1:
        device.targets.erase(device.targets.values()[target_window.id].name)
    device.targets.set(target.name, target)
    update_targets()
