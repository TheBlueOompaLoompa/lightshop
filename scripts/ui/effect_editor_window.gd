extends Window
class_name EffectEditorWindow

@export var project: Project:
    set(v):
        $"Effect Editor".project = v
        project = v

@export var settings: Settings:
    set(v):
        settings = v
        settings.changed.connect(_on_settings_changed)
        $"Effect Editor".settings = v
        _on_settings_changed()

func _on_settings_changed():
    content_scale_factor = settings.ui_scale
