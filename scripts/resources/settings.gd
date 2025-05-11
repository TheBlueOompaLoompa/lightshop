extends Resource
class_name Settings

@export var targets: Array[Target] = []:
    set(_v):
        emit_changed()
@export var ui_scale: float = 1:
    set(_v):
        emit_changed()

static var settings_file = "user://settings.res"

static func load_res():
    if FileAccess.file_exists(settings_file):
        return ResourceLoader.load(settings_file)
    else:
        var new = Settings.new()
        new.save_res()
        return new

func save_res():
    ResourceSaver.save(self, settings_file)
