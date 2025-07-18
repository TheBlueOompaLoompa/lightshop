class_name BaseSearchableList extends Control

signal event(event_name: String, id: int, data: Variant)

@export var search_box: LineEdit
@export var row_scene: PackedScene
@export var data: Array[Variant]:
    set(v):
        data = v
        update()

func _ready():
    search_box.text_changed.connect(update)


func update(_a: String = ""):
    for child in get_children():
        child.queue_free()
    
    search()
    var i = 0
    for item in data:
        var row = row_scene.instantiate()
        row.id = i
        row.data = item
        add_child(row)


func search():
    var search_text = search_box.text
    data.sort_custom(func(a, b): return a.name.similarity(search_text) > b.name.similarity(search_text))
