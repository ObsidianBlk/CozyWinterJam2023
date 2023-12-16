extends Control
class_name HUDControl
#NOTE: This is NOT a UIControl. There's no need for it to be, but it is still UI.

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("HUD")
@export var level_name : String = "":			set = set_level_name
@export var score : int = 0:					set = set_score
@export var sec_remaining : float = 0.0:		set = set_sec_remaining

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lbl_score_value: Label = %LBLScoreValue
@onready var _lbl_timer_value: Label = %LBLTimerValue
@onready var _lbl_level_name: Label = %LBLLevelName


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_level_name(ln : String) -> void:
	level_name = ln
	_UpdateHUD()

func set_score(s : int) -> void:
	if s >= 0:
		score = s
		_UpdateHUD()

func set_sec_remaining(sr : float) -> void:
	if sr >= 0.0:
		sec_remaining = sr
		_UpdateHUD()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateHUD()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SecToTimeString(sec : float) -> String:
	var res : String = ""
	var hours : int = floor(sec / 3600.0)
	if hours > 0:
		res = "%02d:"%[hours]
	sec -= hours * 3600
	var min : int = floor(sec / 60.0)
	sec -= min * 60
	sec = floor(sec)
	return "%s%02d:%02d"%[res, min, sec]

func _UpdateHUD() -> void:
	if _lbl_level_name != null:
		_lbl_level_name.text = level_name
	if _lbl_score_value != null:
		_lbl_score_value.text = "%d"%[score]
	if _lbl_timer_value != null:
		_lbl_timer_value.text = _SecToTimeString(sec_remaining)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



