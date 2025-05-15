extends MarginContainer

signal OpenProject(project_name: String)

func _ready() -> void:
    list_projects()

func list_projects():
    var projects_dir = DirAccess.open('user://projects')
    var project_files = projects_dir.get_files()
    var projects: Array[Project] = []
    for file in project_files:
        var project: Project = ResourceLoader.load('user://projects/'+file)
        print(project.song_file)
        projects.append(project)
    
    const Project_Row = preload("res://scenes/ui/project_row.tscn")

    for child in $VBoxContainer/Scroll/List.get_children():
        child.queue_free()

    for project in projects:
        var row = Project_Row.instantiate()
        row.set_proj_name(project.name)
        row.open.connect(func(project_name):
            OpenProject.emit(project_name)
        )
        row.delete.connect(func(project_name):
            var prj: Project = ResourceLoader.load('user://projects/'+project_name+'.res')
            projects_dir.remove(project_name+'.res')
            DirAccess.remove_absolute(prj.song_file)
            
            list_projects()
        )
        $VBoxContainer/Scroll/List.add_child(row)

func _on_new_button_pressed() -> void:
    $ProjectDialog.show()


func _on_project_dialog_confirm() -> void:
    list_projects()
