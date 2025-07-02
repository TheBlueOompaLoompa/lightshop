extends Control

signal moved(position: Vector2)
signal right_tan(value: float)
signal left_tan(value: float)
signal delete

@export var point_panel: Panel
@export var right_panel: Panel
@export var right_arm: Panel
@export var left_panel: Panel
@export var left_arm: Panel

const MOD = Color(1, 1, 1, .5)
const REGULAR = Color(1, 1, 1, 1)
var point_hover = false
@export var point_drag = false
var right_hover = false
@export var right_drag = false
var left_hover = false
@export var left_drag = false

func is_left_button_pressed(event: InputEvent) -> bool:
    return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
func is_left_button_released(event: InputEvent) -> bool:
    return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not(event.pressed)
func is_right_button_pressed(event: InputEvent) -> bool:
    return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed

func _on_point_mouse_entered() -> void:
    point_panel.modulate = MOD
    point_hover = true


func _on_point_mouse_exited() -> void:
    point_panel.modulate = REGULAR
    point_hover = false


func _on_point_gui_input(event:  InputEvent) -> void:
    if is_left_button_pressed(event) and point_hover:
        point_drag = true
    if is_left_button_released(event):
        point_drag = false
    if is_right_button_pressed(event):
        delete.emit()
    if point_drag and event is InputEventMouseMotion:
        position = event.global_position - get_parent().get_parent().global_position
        position.x = clampf(position.x, 0.0, get_parent().get_parent().size.x)
        position.y = clampf(position.y, 0.0, get_parent().get_parent().size.y)
        moved.emit(position)


func _on_right_control_point_mouse_entered() -> void:
    right_panel.modulate = MOD
    right_hover = true


func _on_right_control_point_mouse_exited() -> void:
    right_panel.modulate = REGULAR
    right_hover = false


func _on_right_control_point_gui_input(event:  InputEvent) -> void:
    if is_left_button_pressed(event) and right_hover:
        right_drag = true
    if is_left_button_released(event):
        right_drag = false
    if right_drag and event is InputEventMouseMotion:
        var angle = (event.global_position - global_position).angle()
        right_arm.rotation = angle
        var t = -tan(angle)
        right_tan.emit(t)
        
        if not Input.is_key_pressed(KEY_SHIFT):
            left_arm.rotation = angle + PI
            left_tan.emit(t)


func _on_left_control_point_mouse_entered() -> void:
    left_panel.modulate = MOD
    left_hover = true


func _on_left_control_point_mouse_exited() -> void:
    left_panel.modulate = REGULAR
    left_hover = false

func _on_left_control_point_gui_input(event:  InputEvent) -> void:
    if is_left_button_pressed(event) and left_hover:
        left_drag = true
    if is_left_button_released(event):
        left_drag = false
    if left_drag and event is InputEventMouseMotion:
        var angle = (event.global_position - global_position).angle()
        left_arm.rotation = angle
        var t = -tan(angle)
        left_tan.emit(t)
        
        if not Input.is_key_pressed(KEY_SHIFT):
            right_arm.rotation = angle + PI
            right_tan.emit(t)
