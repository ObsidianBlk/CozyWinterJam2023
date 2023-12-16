extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const INITIAL_MUSIC_TRACK : AudioStream = preload("res://assets/music/Christmas synths.ogg")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("World")
@export_file() var initial_level : String = ""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_level : Level = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ui : UIRoot = %UI
@onready var _music_player: AudioStreamPlayer = %MusicPlayer


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()
	_music_player.stream = INITIAL_MUSIC_TRACK
	_music_player.play()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SwapActiveLevel(new_level : Level) -> void:
	if _active_level != null:
		remove_child(_active_level)
	_active_level = new_level
	if _active_level != null:
		add_child(_active_level)


func _LoadLevel(level_path : String) -> int:
	var PackedLevel : PackedScene = load(level_path)
	if PackedLevel == null:
		return ERR_FILE_CANT_READ
	var level : Node = PackedLevel.instantiate()
	if not level is Level:
		level.queue_free()
		return ERR_INVALID_DECLARATION
	
	_SwapActiveLevel(level)
	return OK

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_requested(action : StringName, payload : Dictionary):
	match action:
		&"start_game":
			if initial_level.is_empty(): return
			if _LoadLevel(initial_level) == OK:
				_ui.close_all()
		&"quit_application":
			get_tree().quit()

