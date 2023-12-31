@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ARC_DEGREES : float = 45.0
const HALF_ARC_DEGREES : float = 22.5

const INDICATOR_RADIUS : float = 4.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Direction Indicator")
@export var indicator_color : Color = Color.RED:				set = set_indicator_color
@export var indicator_outline_color : Color = Color.WHITE:		set = set_indicator_outline_color
@export_range(0.0, 360.0) var degrees : float = 0.0:			set = set_degrees

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _indicator = $Sprite2D


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_indicator_color(c : Color) -> void:
	indicator_color = c
	queue_redraw()

func set_indicator_outline_color(c : Color) -> void:
	indicator_outline_color = c
	queue_redraw()

func set_degrees(d : float) -> void:
	if d < 0.0 or d > 360.0: return
	degrees = d
	_UpdateIndicator()
	queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateIndicator()

func _draw() -> void:
	var direction : Vector2 = (Vector2.RIGHT * 10.0).rotated(deg_to_rad(degrees))
	var pos : Vector2 = Iso.from_cartesian(direction)
	
	var ang : float = deg_to_rad(degrees)
	var hrad : float = INDICATOR_RADIUS * 0.5
	var points : Array[Vector2] = [
		Iso.from_cartesian((Vector2(-1, -1) * hrad).rotated(ang)) + pos,
		Iso.from_cartesian((Vector2.RIGHT * hrad).rotated(ang)) + pos,
		Iso.from_cartesian((Vector2(-1, 1) * hrad).rotated(ang)) + pos
	]
	
	draw_colored_polygon(points, indicator_color)
	draw_polyline(points, indicator_outline_color, 0.5)
	#draw_circle(pos, INDICATOR_RADIUS, indicator_color)

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
	return deg_to_rad(degrees)
	#if _indicator == null: return 0.0
	#return deg_to_rad(ARC_DEGREES * _indicator.frame)

func normalize_angle(ang_deg : float) -> float:
	ang_deg = wrapf(ang_deg, 0.0, 360.0)
	return deg_to_rad(ang_deg)
	#return deg_to_rad(ARC_DEGREES * _GetFrameFromDeg(ang_deg))
