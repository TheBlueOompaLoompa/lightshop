extends MenuBar

signal file_pressed(text: String)

func _on_file_index_pressed(index):
    emit_signal("file_pressed", $Project.get_item_text(index))
