extends PanelContainer
class_name ClipControl

signal save_clip
signal click
signal left_click
signal right_click

@export var clip: Clip:
    set(v):
        clip = v
        if not clip.changed.is_connected(update):
            clip.changed.connect(update)
        update()

var unselected_style = preload("uid://d0x2u5pjggxrk")
var selected_style = preload("uid://wasdno3fdw3c")

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
    add_theme_stylebox_override("panel", unselected_style)
    var context_menu = ContextMenu.new()
    context_menu.attach_to(self)
    context_menu.add_item("Save Clip", Callable(self, "_save_clip"), false, null)
    context_menu.connect_to(self)

func _save_clip():
    save_clip.emit()

func update():
    update_name()
    if clip.timing:
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        $LeftDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
        $RightDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
    else:
        mouse_filter = Control.MOUSE_FILTER_STOP
        $LeftDrag.mouse_filter = Control.MOUSE_FILTER_STOP
        $RightDrag.mouse_filter = Control.MOUSE_FILTER_STOP
    
    remove_theme_stylebox_override("panel")
    if clip.selected:
        add_theme_stylebox_override("panel", selected_style.duplicate(true))
    else:
        add_theme_stylebox_override("panel", unselected_style.duplicate(true))
    if clip is EffectClip:
        var style: StyleBoxFlat = get_theme_stylebox("panel")
        for effect in clip.effects:
            var e: Effect = effect
            for param in e.parameters:
                if param.data is Color:
                    style.bg_color = param.data
                    return
    
func update_name():
    $LabelContainerContainer/LabelContainer/Label.text = clip.name

var has_mouse = false
var left_drag_has_mouse = false
var right_drag_has_mouse = false
func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            if has_mouse:
                emit_signal("click")
            elif left_drag_has_mouse:
                emit_signal("left_click")
            elif right_drag_has_mouse:
                emit_signal("right_click")


func _on_mouse_entered():
    has_mouse = true


func _on_mouse_exited():
    has_mouse = false


func _on_left_drag_mouse_entered():
    left_drag_has_mouse = true


func _on_left_drag_mouse_exited():
    left_drag_has_mouse = false


func _on_right_drag_mouse_entered():
    right_drag_has_mouse = true


func _on_right_drag_mouse_exited():
    right_drag_has_mouse = false
