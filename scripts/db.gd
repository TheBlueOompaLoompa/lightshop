extends Node
class_name DB

@export var db_name: String = 'unamed db'
@export var verbosity_level: SQLite.VerbosityLevel = SQLite.VerbosityLevel.NORMAL

var db: SQLite
var mutex: Mutex = Mutex.new()
var setup = false

const PROJECTS_TABLE = 'projects'

func getdb() -> SQLite:
    mutex.lock()
    db = SQLite.new()
    db.foreign_keys = true
    db.path = 'user://' + db_name
    db.verbosity_level = verbosity_level
    db.open_db()
    
    return db

func release():
    db.close_db()
    mutex.unlock()

func _ready() -> void:
    getdb()

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        db.close_db()
        get_tree().quit() # default behavior
