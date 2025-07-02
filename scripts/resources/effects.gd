class_name Effects extends Resource

@export var list: Dictionary[int, Effect] = {}:
    set(v):
        list = v
        emit_changed()
@export var uid_count = 0


func s(key: int, value: Effect):
    list.set(key, value)


func g(key: int, default: Effect = null) -> Effect:
    return list.get(key, default)


func keys() -> Array[int]:
    return list.keys()


func values() -> Array[Effect]:
    return list.values()
    
    
func erase(key: int) -> bool:
    return list.erase(key)
