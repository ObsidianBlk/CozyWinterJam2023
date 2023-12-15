@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ARC_DEGREES : float = 45.0
const HALF_ARC_DEGREES : float = 22.5

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Direction Indicator")
@export_range(0.0, 360.0) var degrees : float = 0.0:			set = set_degrees


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _indicator = $Sprite2D


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_degrees(d : float) -> void:
	if d < 0.0 or d > 360.0: return
	degrees = d
	_UpdateIndicator()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateIndicator()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsWithinArc(deg : float) -> bool:
	return degrees >= deg - HALF_ARC_DEGREES and degrees < deg + HALF_ARC_DEGREES

func _UpdateIndicator() -> void:
	if _indicator == null: return
	var frame : int = 0

	for i in range(1, 7):
		if _IsWithinArc(ARC_DEGREES * i):
			frame = i
			break
	_indicator.frame = frame
