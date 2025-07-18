extends Resource
class_name Target

@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var address: String:
    set(v):
        address = v        
        emit_changed()
@export var path: String:
    set(v):
        path = v        
        emit_changed()
@export var port: int:
    set(v):
        port = v        
        emit_changed()
@export_range(1, 999999) var count: int:
    set(v):
        count = v
        emit_changed()
@export var type: Type:
    set(v):
        type = v
        emit_changed()
@export var strip_type: StripType:
    set(v):
        strip_type = v
        emit_changed()
@export var pins: Array[int]:
    set(v):
        pins = v
        emit_changed()
@export var points: PackedVector3Array:
    set(v):
        points = v
        emit_changed()
@export var gpu_layers: int = 4:
    set(v):
        gpu_layers = v
        emit_changed()
@export var framerate: float = 30:
    set(v):
        framerate = v
        emit_changed()
@export var renderer_source: String:
    set(v):
        renderer_source = v
        emit_changed()


enum Type {
    LINEAR,
    SPATIAL,
    BINARY,
    POSITION,
    ROTATION,
}

enum StripType {
    Sk6812Rgbw,
    Sk6812Rbgw,
    Sk6812Gbrw,
    Sk6812Grbw,
    Sk6812Brgw,
    Sk6812Bgrw,
    Ws2811Rgb,
    Ws2811Rbg,
    Ws2811Grb,
    Ws2811Gbr,
    Ws2811Brg,
    Ws2811Bgr,
    Ws2812,
    Sk6812,
    Sk6812W,
}
