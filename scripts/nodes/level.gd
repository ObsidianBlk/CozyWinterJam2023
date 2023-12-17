extends Node2D
class_name Level


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal score_changed(score : int)
signal timer_changed(secs_remaining : int)
signal level_name_changed(level_name : String)
signal level_complete(score : int)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const GROUP_SCORE_ZONE : StringName = &"ScoreZone"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Level")
@export var level_name : String = "":		set = set_level_name
@export var level_time_sec : int = 60:		set = set_level_time_sec

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _score : int = 0:		set = _set_score
var _timer : float = 0.0:	set = _set_timer

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_level_name(ln : String) -> void:
	level_name = ln
	level_name_changed.emit(level_name)

func set_level_time_sec(s : int) -> void:
	if s > 0:
		level_time_sec = s
		_timer = float(level_time_sec)

func _set_score(s : int) -> void:
	_score = s
	score_changed.emit(_score)

func _set_timer(t : float) -> void:
	_timer = t
	timer_changed.emit(floor(_timer))


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

func _process(delta: float) -> void:
	if _timer > 0.0:
		_timer = max(0.0, _timer - delta)
		if _timer <= 0.001:
			_timer = 0.0
			level_complete.emit(_score)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEmits() -> void:
	_timer = float(level_time_sec)
	score_changed.emit(_score)
	level_name_changed.emit(level_name)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_score() -> int:
	return _score

func reset() -> void:
	_score = 0

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_scorezone_triggered(score : int) -> void:
	if score <= 0: return
	_score += score
