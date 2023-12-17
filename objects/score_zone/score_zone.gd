@tool
extends Node2D
class_name ScoreZone

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal triggered(score : int)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const TZ_THICKNESS : float = 2.0
const SCORE_ANIM_DURATION : float = 1.5
const SCORE_ANIM_SCALE : Vector2 = Vector2.ONE * 2.0
const SCORE_ANIM_RISE : Vector2 = Vector2.UP * 16.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Score Zone")
@export var radius : float = 16.0:						set = set_radius
@export_range(0.0, 180.0) var angle : float = 0.0:		set = set_angle
@export var score : int = 0:							set = set_score
@export var trigger_group : StringName = &""
@export var trigger_once : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _triggered : bool = false
var _animating : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _flag1: StaticBody2D = $Flag1
@onready var _flag2: StaticBody2D = $Flag2
@onready var _collision: CollisionPolygon2D = $TriggerArea/Collision
@onready var _lbl_score: Label = $LBLScore
@onready var _aplayer: AudioStreamPlayer2D = $APlayer

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_radius(r : float) -> void:
	if r > 0.0:
		radius = r
		_UpdateLayout()

func set_angle(a : float) -> void:
	angle = wrapf(a, 0.0, 180.0)
	_UpdateLayout()

func set_score(s : int) -> void:
	if s >= 0:
		score = s
		_UpdateScoreLabel()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateLayout()
	_UpdateScoreLabel()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Cart2Iso(ccoord : Vector2) -> Vector2:
	var iso : Vector2 = Vector2(
		ccoord.x - ccoord.y,
		(ccoord.x + ccoord.y) * 0.5
	)
	return iso

func _VecRadRot(rad : float, ang : float) -> Vector2:
	return (Vector2.RIGHT * rad).rotated(deg_to_rad(ang))

func _UpdateLayout() -> void:
	if _flag1 == null or _flag2 == null: return
	var collision_points : Array[Vector2] = []
	
	var pos : Vector2 = _VecRadRot(radius, angle)#(Vector2.RIGHT * radius).rotated(deg_to_rad(angle))
	_flag1.position = _Cart2Iso(pos)
	#collision_points.append(pos + (Vector2.RIGHT * TZ_THICKNESS).rotated(deg_to_rad(angle - 90.0)))
	#collision_points.append(pos + (Vector2.RIGHT * TZ_THICKNESS).rotated(deg_to_rad(angle + 90.0)))
	collision_points.append(_Cart2Iso(pos + _VecRadRot(TZ_THICKNESS, angle - 90.0)))
	collision_points.append(_Cart2Iso(pos + _VecRadRot(TZ_THICKNESS, angle + 90.0)))
	
	pos = pos.rotated(deg_to_rad(180.0))
	_flag2.position = _Cart2Iso(pos)
	collision_points.append(_Cart2Iso(pos + _VecRadRot(TZ_THICKNESS, angle + 90.0)))
	collision_points.append(_Cart2Iso(pos + _VecRadRot(TZ_THICKNESS, angle - 90.0)))
	
	_collision.polygon = collision_points

func _UpdateScoreLabel() -> void:
	if _lbl_score == null: return
	var font : Font = _lbl_score.get_theme_font("font", _lbl_score.theme_type_variation)
	var font_size : int = _lbl_score.get_theme_font_size("font_size", _lbl_score.theme_type_variation)
	var txt : String = "%d"%[score]
	var txt_size : Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	_lbl_score.text = txt
	_lbl_score.position = Vector2(-txt_size.x * 0.5, -txt_size.y)
	_lbl_score.modulate = Color.WHITE if score > 0 else Color.TRANSPARENT
	_lbl_score.scale = Vector2.ONE

func _AnimateScoreLabel() -> void:
	if _animating: return
	_animating = true
	
	var tween : Tween = create_tween()
	tween.tween_property(_lbl_score, "position", _lbl_score.position + SCORE_ANIM_RISE, SCORE_ANIM_DURATION)
	tween.parallel()
	tween.tween_property(_lbl_score, "scale", SCORE_ANIM_SCALE, SCORE_ANIM_DURATION)
	tween.parallel()
	tween.tween_property(_lbl_score, "modulate", Color.TRANSPARENT, SCORE_ANIM_DURATION)
	tween.tween_interval(0.5)
	
	await tween.finished
	_animating = false
	if trigger_once:
		score = 0
	else:
		_UpdateScoreLabel() # Repositions the label

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_trigger_area_body_entered(body: Node2D) -> void:
	if score <= 0 or _animating: return
	if _triggered and trigger_once: return
	if trigger_group != &"" and not body.is_in_group(trigger_group): return
	_triggered = true
	_AnimateScoreLabel()
	_aplayer.play()
	triggered.emit(score)
