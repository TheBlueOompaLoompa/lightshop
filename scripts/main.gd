extends Control

@onready var project_tab = $Tabs/Project
@onready var settings_tab = $Tabs/Settings

@export var settings: Settings:
    set(v):
        settings = v
        if settings_tab != null:
            settings_tab.settings = settings
        if project_tab != null:
            project_tab.settings = settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var effects_exists = FileAccess.file_exists("user://effects.tres")
    if effects_exists:
        project_tab.effects = ResourceLoader.load("user://effects.tres")
    else:
        project_tab.effects = Effects.new()
        print(ResourceSaver.save(project_tab.effects, "user://effects.tres"))
    project_tab.effects.changed.connect(func():
        ResourceSaver.save(project_tab.effects, "user://effects.tres")
    )
    Input.use_accumulated_input = false
    $Tabs.set_tab_disabled(1, true)
    apply_settings()


func apply_settings():
    settings = Settings.load_res()
    get_tree().root.content_scale_factor = settings.ui_scale


func _on_open_project(project_name: String) -> void:
    $Tabs.current_tab = 1
    project_tab.name = 'Project ' + project_name
    $Tabs.set_tab_disabled(1, false)
