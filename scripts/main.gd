extends Control

@onready var Db = $DB

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    setup_db()

func setup_db():
    var db = Db.db

    const projects_schema = preload("res://scripts/schema/project.gd").Schema

    db.create_table(Db.PROJECTS_TABLE, projects_schema.INFO)

    Db.release()
