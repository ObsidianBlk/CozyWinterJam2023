extends Resource
class_name ScoreboardEntry


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Scoreboard Entry")
@export var level_name : String = "":								set = set_level_name
@export var player_name : String = "":								set = set_player_name
@export var score : int = 0:										set = set_score
@export var timestamp : float = Time.get_unix_time_from_system():	set = set_timestamp


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_level_name(ln : String) -> void:
	level_name = ln
	changed.emit()

func set_player_name(pn : String) -> void:
	player_name = pn
	changed.emit()

func set_score(s : int) -> void:
	score = s
	changed.emit()

func set_timestamp(ts : float) -> void:
	timestamp = ts
	changed.emit()
