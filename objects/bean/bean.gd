extends CharacterBody2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const INPUT_FORWARD : int = 0
const INPUT_BACKWARD : int = 1
const INPUT_LEFT : int = 2
const INPUT_RIGHT : int = 3

const DIRECTION_THRESHOLD : float = 0.01

const SURFACE_SNOW : int = 0
const SURFACE_ICE : int = 1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Bean")
@export var max_speed : float = 96
@export var friction : float = 48
@export var turn_dps : float = 180.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _surface : int = SURFACE_SNOW
var _axii : Array[float] = [0.0, 0.0, 0.0, 0.0]
var _facing : float = 0.0 # Facing is an internal rotation value (in degrees).
var _speed : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _direction_indicator = $DirectionIndicator

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action("forward"):
		_axii[INPUT_FORWARD] = Input.get_action_strength("forward")
	elif event.is_action("backward"):
		_axii[INPUT_BACKWARD] = Input.get_action_strength("backward")
	elif event.is_action("left"):
		_axii[INPUT_LEFT] = Input.get_action_strength("left")
	elif event.is_action("right"):
		_axii[INPUT_RIGHT] = Input.get_action_strength("right")

func _physics_process(delta : float) -> void:
	_ProcessFacing(delta)
	_ProcessSpeed(delta)
	#var direction : Vector2 = Vector2(
		#_axii[INPUT_RIGHT] - _axii[INPUT_LEFT],
		#_axii[INPUT_BACKWARD] - _axii[INPUT_FORWARD]
	#)
	var direction : Vector2 = (Vector2.RIGHT * _speed).rotated(deg_to_rad(_facing))
	
	if direction.length() <= DIRECTION_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity = _Cart2Iso(direction * max_speed)
	
	move_and_slide()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessFacing(delta : float) -> void:
	var amount = _axii[INPUT_LEFT] - _axii[INPUT_RIGHT]
	if abs(amount) > 0.0:
		_facing = wrapf(_facing + (turn_dps * amount * delta), 0.0, 360.0)
		_direction_indicator.degrees = _facing

func _ProcessSpeed(delta : float) -> void:
	var amount = _axii[INPUT_BACKWARD] - _axii[INPUT_FORWARD]
	if abs(amount) <= DIRECTION_THRESHOLD:
		match _surface:
			SURFACE_ICE:
				_speed = max(0.0, _speed - (_GetSpeedNormal() * friction * delta))
			SURFACE_SNOW:
				_speed = 0.0
	else:
		_speed = max(-max_speed, min(max_speed, _speed + (amount * delta)))

func _GetSpeedNormal() -> float:
	# Should return -1.0 to 1.0
	return sign(_speed) * (_speed / max_speed)


func _Cart2Iso(ccoord : Vector2) -> Vector2:
	var iso : Vector2 = Vector2(
		ccoord.x - ccoord.y,
		(ccoord.x + ccoord.y) * 0.5
	)
	return iso
