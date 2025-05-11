extends Control

@onready var Db = $DB
@onready var project_tab = $Tabs/Project

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var user = DirAccess.open("user://")
    if not user.dir_exists("projects"):
        user.make_dir("projects")
    #setup_db()
    apply_settings()


func setup_db():
    var db = Db.db

    #db.create_table(Db.PROJECTS_TABLE, Project.INFO)

    Db.release()


func apply_settings():
    var settings: Settings = Settings.load_res()
    get_tree().root.content_scale_factor = settings.ui_scale


func _on_open_project(id: String) -> void:
    $Tabs.current_tab = 1
    project_tab.name = 'Project ' + id
