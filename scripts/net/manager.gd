class_name NetworkManager extends Node

signal client_connected(peer_id)
signal client_disconnected(peer_id)
signal server_disconnected
signal shutdown_called

@export var settings: Settings ## Application Settings
@export var network_mode: NetworkSettings.NetworkMode
var peer_map: Dictionary[int, NetworkPeer] = {}

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_ok)
    multiplayer.connection_failed.connect(_on_connected_fail)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

## Start client or server
func start(
    mode: NetworkSettings.NetworkMode = settings.network_settings.default_network_mode,
    address: String = "0.0.0.0" if mode == NetworkSettings.NetworkMode.SERVER else "127.0.0.1",
    port: int = settings.network_settings.server_port
) -> Error:
    if settings == null:
        Log.error("Settings undefined in NetworkManager")
        return ERR_INVALID_DATA
    
    network_mode = mode
    
    if mode == NetworkSettings.NetworkMode.SERVER:
        var peer = ENetMultiplayerPeer.new()
        var error = peer.create_server(port, settings.network_settings.max_connections)
        if error:
            Log.error("NetworkManager Failed to create server", error_string(error))
            return error
        multiplayer.multiplayer_peer = peer
        Log.info("Server started", address, port)
        client_connected.emit(1)
    elif mode == NetworkSettings.NetworkMode.CLIENT:
        var peer = ENetMultiplayerPeer.new()
        var error = peer.create_client(address, port)
        if error:
            Log.error("NetworkManager Failed to connect to server", error_string(error))
            return error
        multiplayer.multiplayer_peer = peer
        Log.info("Client connected", address, port)
    return OK


## Stop or disconnect from server
func shutdown():
    shutdown_called.emit()
    multiplayer.multiplayer_peer = null
    peer_map.clear()


## Send local network peer info to other peers
func update_self_info():
    update_peer_info(settings.network_settings.network_peer)


## Send peer info out to all other clients
func update_peer_info(peer: NetworkPeer):
    _update_peer_info.rpc(peer)
@rpc("any_peer", "call_local", "reliable")
func _update_peer_info(peer: NetworkPeer):
    peer_map.set(multiplayer.get_remote_sender_id(), peer)


## Send local peer map to id
func send_peer_map(id: int):
    if multiplayer.get_unique_id() == 1 and id != 1:
        send_peer_map.rpc_id(id, peer_map)
@rpc("any_peer", "call_remote", "reliable")
func _send_peer_map(map: Dictionary[int, NetworkPeer]):
    for key in map.keys():
        peer_map.set(key, map.get(key))
    

func _on_peer_connected(id: int):
    # When a client connects, send them the current peer map (only finishes when called on the server)
    send_peer_map(id)


func _on_peer_disconnected(id: int):
    peer_map.erase(id)


func _on_connected_ok():
    pass


func _on_connected_fail():
    pass


func _on_server_disconnected():
    shutdown()
