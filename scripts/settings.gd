extends Resource
class_name Settings

@export var targets: Array[Target] = []

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
