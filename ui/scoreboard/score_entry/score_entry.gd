@tool
extends MarginContainer
class_name ScoreEntryControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_PLAYER_NAME : String = "Skater X"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Score Entry")
@export var index : int = 0:					set = set_index
@export var player_name : String = "":			set = set_player_name
@export var score : int = 0:					set = set_score


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lbl_index: Label = %LBL_Index
@onready var _lbl_player: Label = %LBL_Player
@onready var _lbl_score: Label = %LBL_Score


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_index(idx : int) -> void:
	if idx >= 0:
		index = idx
		_UpdateLabels()

func set_player_name(pn : String) -> void:
	player_name = pn
	_UpdateLabels()

func set_score(s : int) -> void:
	if s >= 0:
		score = s
		_UpdateLabels()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateLabels()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateLabels() -> void:
	if _lbl_index != null:
		_lbl_index.text = "%d"%[index + 1]
	if _lbl_player != null:
		_lbl_player.text = player_name if not player_name.is_empty() else DEFAULT_PLAYER_NAME
	if _lbl_score != null:
		_lbl_score.text = "%d"%[score]
