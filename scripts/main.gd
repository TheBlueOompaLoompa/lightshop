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
    var user = DirAccess.open("user://")
    if not user.dir_exists("projects"):
        user.make_dir("projects")
    apply_settings()


func apply_settings():
    settings = Settings.load_res()
    get_tree().root.content_scale_factor = settings.ui_scale


func _on_open_project(project_name: String) -> void:
    $Tabs.current_tab = 1
    project_tab.name = 'Project ' + project_name
