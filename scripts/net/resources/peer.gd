class_name NetworkPeer extends Resource

var uid: String

func _init(p_uid: String = "") -> void:
    if p_uid.is_empty():
        uid = uuid.v4()
