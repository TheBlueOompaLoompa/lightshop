extends MarginContainer

signal Changed

@export var settings: Settings

@onready var targets_node = $Main/ScrollContainer/Targets
@onready var target_window = $TargetWindow
var target_row_prefab = preload("res://scenes/ui/target_row.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    settings = Settings.load_res()
    
func reset_ui():
    settings.save_res()
    Changed.emit()
    for child in targets_node.get_children():
        child.queue_free()
    
    for i in settings.targets.size():
        var new_target = target_row_prefab.instantiate()
        new_target.set_target_name(settings.targets[i].name)
        new_target.set_target_id(i)
        
        new_target.edit.connect(func(id):
            var temp = Target.new()
            temp.name = settings.targets[i].name
            temp.address = settings.targets[i].address
            temp.type = settings.targets[i].type
            temp.leds = settings.targets[i].leds
            temp.points = PackedVector3Array(settings.targets[i].points)
            target_window.target = temp
            target_window.id = i
            target_window.show()
        )
        
        new_target.delete.connect(func(id):
            settings.targets.pop_at(id)
            reset_ui()   
        )
        
        targets_node.add_child(new_target)


func _on_add_render_target_pressed() -> void:
    $TargetWindow.show()


func _on_target_window_confirmed(target: Target, id: int) -> void:
    if id < 0:
        settings.targets.append(target)
    else:
        settings.targets[id] = target
    reset_ui()


func _on_visibility_changed() -> void:
    if visible:
        settings = Settings.load_res()
        reset_ui()
