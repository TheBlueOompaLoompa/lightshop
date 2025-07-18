class_name NetworkSettings extends Resource

signal default_mode_changed
signal known_servers_changed
signal server_port_changed
signal max_connections_changed

## Will the app be the one hosting the project, or connecting as a client into a server's project 
@export var default_network_mode := NetworkMode.SERVER:
    set(v):
        default_network_mode = v
        default_mode_changed.emit()
## Servers that the user saved
@export var known_servers: Array[KnownServer] = []:
    set(v):
        known_servers = v
        known_servers_changed.emit()
@export var server_port: int = DEFAULT_PORT:
    set(v):
        server_port = v
        server_port_changed.emit()
@export var max_connections: int = 10:
    set(v):
        max_connections = v
        max_connections_changed.emit()
@export var network_peer := NetworkPeer.new()

static var DEFAULT_PORT = 5136

enum NetworkMode {
    SERVER,
    CLIENT
}
