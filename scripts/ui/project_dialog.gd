extends Window

@onready var name_input := $VBox/GridContainer/Name
@onready var tempo_input := $VBox/GridContainer/Tempo
@onready var time_input := $VBox/GridContainer/Time
@onready var offset_input := $VBox/GridContainer/Offset
@onready var file_dialog := $VBox/GridContainer/FileDialog
@onready var file_label := $VBox/GridContainer/BrowseBox/FileLabel
@onready var Db: DB = $"..".Db

func _on_visibility_changed() -> void:
    if visible:
        name_input.text = ''
        tempo_input.text = '120'
        time_input.text = '0'
        offset_input.text = '0'


func _on_cancel_pressed() -> void:
    hide()


func _on_confirm_pressed() -> void:
    var db = Db.getdb()
    
    var query = "SELECT * FROM projects WHERE name = ?;"
    db.query_with_bindings(query, [name_input.text])

    var name_good = name_input.text != '' and len(db.query_result) == 0
    var tempo = float(tempo_input.text)
    var time = float(time_input.text)
    var offset = float(offset_input.text)
    var file_good = FileAccess.file_exists(file_dialog.current_file)

    if file_good and name_good:
        var user_file = 'user://' + file_label.text
        var dir = DirAccess.open(file_dialog.current_dir)
        dir.copy(file_dialog.current_file, user_file)
        db.insert_row('projects', { 'name': name_input.text, 'tempo': tempo, 'time': time, 'offset': offset, 'song_file': user_file }) 

    Db.release()
    file_dialog.hide()


func _on_browse_pressed() -> void:
    file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
    file_label.text = path.split('/')[-1]
