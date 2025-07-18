extends Node

signal new_line(line: String)

var log_lines: Array[String] = []

func info(...args: Array) -> void:
    var text = gen_timestamp() + _pre_format(args)
    print_rich(text)
    new_line.emit(text)
    log_lines.append(text)


func error(...args: Array) -> void:
    var a = ['[b]ERROR:[/b]']
    a.append_array(args)
    var text = _pre_format(a)
    text = '[color=red]' + text + '[/color]'
    Log.info(text)


func _pre_format(args: Array) -> String:
    var out = ''
    for arg in args:
        out += str(arg) + ' '
    return out


func gen_timestamp() -> String:
    var total_secs: float = Time.get_ticks_msec() / 1000.0 
    var secs = int(total_secs) % 60
    var mins = int(floor(total_secs / 60.0))
    var hours = int(floor(total_secs / (60.0*60.0)))
    
    return "[color=gray]%s:%s:%s[/color] " % [hours, mins, secs]
