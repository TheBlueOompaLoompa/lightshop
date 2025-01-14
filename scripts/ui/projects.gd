extends MarginContainer

@export var Db: DB

func _ready() -> void:
    list_projects()

func list_projects():
    var db = Db.getdb()

    var projects: Array = db.select_rows(Db.PROJECTS_TABLE, '', ['name'])

    const Project_Row = preload("res://scenes/ui/project_row.tscn")

    for project in projects:
        var row = Project_Row.instantiate()
        row.set_proj_name(project.name)
        row.open.connect(func(id):
            print(id)
        )
        row.delete.connect(func(id):
            print(id)
        )
        $Scroll/List.add_child(row)

    Db.release()


func _on_new_button_pressed() -> void:
    $ProjectDialog.show()
