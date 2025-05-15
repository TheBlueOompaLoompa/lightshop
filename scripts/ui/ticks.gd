extends PanelContainer

const BlankPanel = preload("res://blank_panel.tres")

signal retime(beats: float)

@export var view_beats: float = 0.0:
    set(v):
        view_beats = v
        update_positions()
        update_playhead_position()
@export var beats: float = 0.0:
    set(v):
        beats = v
        update_playhead_position()
@export var scale_px: float = 20.0:
    set(v):
        scale_px = v
        update_count()
@export var track_count = 0:
    set(count):
        track_count = count
        var line = playhead.get_node('Line')
        if track_count == 0:
            line.size.y = 0
        else:
            line.size.y = 4
            line.size.y += (100+6)*track_count

@onready var playhead = $"../Playhead"

var last_size = size.x

func _process(delta: float) -> void:
    if size.x != last_size:
        last_size = size.x
        update_count()

func update_count():
    var main_count = ceili(size.x / scale_px) + 1
    var tick_count = ceili(size.x / scale_px) + 1
    
    if $Ticks.get_child_count() > tick_count:
        for i in $Ticks.get_child_count() - tick_count:
            $Ticks.remove_child($Ticks.get_child(0))
    elif $Ticks.get_child_count() < tick_count:
        for i in tick_count - $Ticks.get_child_count():
            var panel = Panel.new()
            panel.add_theme_stylebox_override('panel', BlankPanel)
            $Ticks.add_child(panel)
            panel.size.y = size.y/2 - 4
            panel.size.x = 1
            
    if $Numbers.get_child_count() > main_count:
        for i in $Numbers.get_child_count() - main_count:
            $Numbers.remove_child($Numbers.get_child(0))
    elif $Numbers.get_child_count() < main_count:
        for i in main_count - $Numbers.get_child_count():
            var label = Label.new()
            $Numbers.add_child(label)
            label.position.y = size.y/2 - 8
    
    update_positions()

func update_positions():
    for i in $Ticks.get_child_count():
        $Ticks.get_child(i).position.x = scale_px * float(i) - fmod(view_beats * scale_px, scale_px)
    
    for i in $Numbers.get_child_count():
        $Numbers.get_child(i).text = str(floori(view_beats) + i)
        $Numbers.get_child(i).position.x = scale_px * float(i) - fmod(view_beats * scale_px, scale_px)

func update_playhead_position():
    playhead.position.x = (beats - view_beats) * scale_px
    playhead.get_node('Line').visible = not(playhead.position.x < 0 or playhead.position.x > size.x)
    playhead.position.x = maxf(minf(playhead.position.x, size.x), 0.0)

var mouse_down = false
func _on_gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("click"):
        mouse_down = true
    elif event.is_action_released("click"):
        mouse_down = false
    elif event is InputEventMouseMotion:
        emit_signal("retime", event.relative/scale_px)
