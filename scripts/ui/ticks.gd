extends PanelContainer

const BlankPanel = preload("res://blank_panel.tres")

signal retime(beats: float)
signal playhead_scroll(beats: float)

@export var view_beats: float = 0.0:
    set(v):
        view_beats = v
        update_positions()
        update_playhead_position()
@export var beats: float = 0.0:
    set(v):
        beats = v
        update_playhead_position()
@export var division: float = 2.0:
    set(v):
        division = v
        update_count()
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

func _process(_delta: float) -> void:
    if size.x != last_size:
        last_size = size.x
        update_count()

func update_count():
    var main_count = (ceili(size.x / scale_px) + 1)
    var tick_count = (ceili(size.x / scale_px) + 1) * division
    
    if $Ticks.get_child_count() > tick_count:
        for i in $Ticks.get_child_count() - tick_count:
            $Ticks.remove_child($Ticks.get_child(0))
    elif $Ticks.get_child_count() < tick_count:
        for i in tick_count - $Ticks.get_child_count():
            var panel = Panel.new()
            panel.add_theme_stylebox_override('panel', BlankPanel)
            $Ticks.add_child(panel)
    for i in $Ticks.get_child_count():
        var panel = $Ticks.get_child(i)
        panel.size.y = size.y/2 - 4
        if int(i) % max(int(division), 1) != 0:
            panel.size.y /= 2
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
        var child = $Ticks.get_child(i)
        child.position.x = scale_px * float(i)
        child.position.x /= maxf(division, 1.0)
        child.position.x -= fmod(view_beats * scale_px, scale_px)
        child.size.y = size.y/2 - 4
        if int(i) % max(int(division), 1) != 0:
            child.size.y /= 2
    
    for i in $Numbers.get_child_count():
        $Numbers.get_child(i).text = str(floori(view_beats) + i)
        $Numbers.get_child(i).position.x = scale_px * float(i) - fmod(view_beats * scale_px, scale_px)

func update_playhead_position():
    playhead.position.x = (beats - view_beats) * scale_px
    playhead.get_node('Line').visible = not(playhead.position.x < 0 or playhead.position.x > size.x)
    playhead.position.x = maxf(minf(playhead.position.x, size.x), 0.0)

    if playhead.position.x >= size.x:
        emit_signal("playhead_scroll", playhead.position.x/scale_px/2)


var mouse_in = false
var lock_mouse = false
func _input(event: InputEvent) -> void:
    if not (mouse_in or lock_mouse): return
    var mouse_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
    if mouse_down and mouse_in:
        lock_mouse = true
    elif not mouse_down:
        lock_mouse = false
    if event is InputEventMouseMotion and lock_mouse:
        var scaled_beats = (event.position.x - global_position.x)/scale_px + view_beats
        var clampped = minf(maxf(scaled_beats, 0.0), size.x/scale_px+view_beats)
        var snap = snappedf(clampped, 1/division)
        emit_signal("retime", snap)
        

func _on_mouse_entered() -> void:
    mouse_in = true

func _on_mouse_exited() -> void:
    mouse_in = false
