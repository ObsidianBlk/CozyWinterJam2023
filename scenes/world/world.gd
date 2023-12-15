extends Node2D


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

