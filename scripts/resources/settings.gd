extends Resource
class_name Settings

@export var targets: Array[Target] = []:
    set(v):
        targets = v
        emit_changed()
@export var ui_scale: float = 1.0:
    set(v):
        ui_scale = v
        emit_changed()
@export var invert_scroll: bool = false:
    set(v):
        invert_scroll = v
        emit_changed()
@export var look_speed: float = 1.0
@export var move_speed: float = 1.0

static var settings_file = "user://settings.tres"

static func load_res():
    if FileAccess.file_exists(settings_file):
        return ResourceLoader.load(settings_file)
    else:
        var new = Settings.new()
        new.save_res()
        return new

func save_res():
    ResourceSaver.save(self, settings_file)
