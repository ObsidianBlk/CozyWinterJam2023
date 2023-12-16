extends Node2D
class_name Level


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal score_changed(score : int)
signal level_name_changed(level_name : String)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const GROUP_SCORE_ZONE : StringName = &"ScoreZone"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Level")
@export var level_name : String = "":		set = set_level_name

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _score : int = 0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_level_name(ln : String) -> void:
	level_name = ln
	level_name_changed.emit(level_name)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var szitems : Array[Node] = get_tree().get_nodes_in_group(GROUP_SCORE_ZONE)
	for sz : Node in szitems:
		if not sz is ScoreZone: continue
		if not sz.triggered.is_connected(_on_scorezone_triggered):
			sz.triggered.connect(_on_scorezone_triggered)
	_UpdateEmits.call_deferred()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEmits() -> void:
	score_changed.emit(_score)
	level_name_changed.emit(level_name)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_score() -> int:
	return _score

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_scorezone_triggered(score : int) -> void:
	if score <= 0: return
	_score += score
	score_changed.emit(_score)
