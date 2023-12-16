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
func _IsWithinArc(ang_deg : float, arc_deg : float) -> bool:
	return ang_deg >= arc_deg - HALF_ARC_DEGREES and ang_deg < arc_deg + HALF_ARC_DEGREES

func _GetFrameFromDeg(ang_deg : float) -> int:
	for i in range(1, 8):
		if _IsWithinArc(ang_deg, ARC_DEGREES * i):
			return i
	return 0

func _UpdateIndicator() -> void:
	if _indicator == null: return
	_indicator.frame = _GetFrameFromDeg(degrees)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_angle() -> float:
	if _indicator == null: return 0.0
	return deg_to_rad(ARC_DEGREES * _indicator.frame)

func normalize_angle(ang_deg : float) -> float:
	ang_deg = wrapf(ang_deg, 0.0, 360.0)
	return deg_to_rad(ARC_DEGREES * _GetFrameFromDeg(ang_deg))
