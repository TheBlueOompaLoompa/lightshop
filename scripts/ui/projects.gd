extends MarginContainer

signal OpenProject(id: String)

@export var Db: DB

func _ready() -> void:
    list_projects()

func list_projects():
    var db = Db.getdb()

    var projects: Array[Dictionary] = db.select_rows(Db.PROJECTS_TABLE, '', ['name', 'song_file'])

    const Project_Row = preload("res://scenes/ui/project_row.tscn")

    for child in $VBoxContainer/Scroll/List.get_children():
        child.queue_free()

    for project in projects:
        var row = Project_Row.instantiate()
        row.set_proj_name(project.name)
        row.open.connect(func(id):
            OpenProject.emit(id)
        )
        row.delete.connect(func(id):
            print(project)
            if FileAccess.file_exists(project.get('song_file')):
                DirAccess.remove_absolute(project.get('song_file'))
            var query = "DELETE FROM projects WHERE name = ?;"
            var d = Db.getdb()
            d.query_with_bindings(query, [id])
            Db.release()
            
            list_projects()
        )
        $VBoxContainer/Scroll/List.add_child(row)

    Db.release()


func _on_new_button_pressed() -> void:
    $ProjectDialog.show()


func _on_project_dialog_confirm() -> void:
    list_projects()
