class_name PreviewAddOutputWindow extends Window

signal selected(target: Target)

@export var list: BaseSearchableList
@export var settings: Settings:
    set(v):
        settings = v
        settings.device_changed.connect(func(_device, _idx):
            update()    
        )
        update()


func update():
    if settings == null: return
    var targets: Array[Target] = []
    for device in settings.devices:
        for target in device.targets.values():
            targets.append(target)
    list.data = targets


func _on_close_requested() -> void:
    hide()


func _on_base_searchable_list_event(event_name: String, _id: int, data: Variant) -> void:
    if event_name == "selected_output":
        selected.emit(data)
        
