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
@export var max_snow_speed : float = 32
@export var max_ice_speed : float = 96
@export var snow_friction : float = 48
@export var ice_friction : float = 24
@export var turn_dps : float = 180.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _surface : int = SURFACE_SNOW
var _axii : Array[float] = [0.0, 0.0, 0.0, 0.0]
var _facing : float = 0.0 # Facing is an internal rotation value (in degrees).
var _push_facing : float = 0.0
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
	if event.is_action("backward"):
		_axii[INPUT_BACKWARD] = Input.get_action_strength("backward")
	if event.is_action("left"):
		_axii[INPUT_LEFT] = Input.get_action_strength("left")
	if event.is_action("right"):
		_axii[INPUT_RIGHT] = Input.get_action_strength("right")

func _physics_process(delta : float) -> void:
	_surface = Terrain.Get_Custom_Data_At(global_position, "type", _surface)
	_ProcessFacing(delta)
	_ProcessSpeed(delta)
	
	match _surface:
		SURFACE_ICE:
			_ProcessVelocityIce(delta)
		_:
			_ProcessVelocitySnow(delta)

#func _draw() -> void:
	#var direction : Vector2 = (Vector2.RIGHT * 10.0).rotated(deg_to_rad(_facing))
	#var pos : Vector2 = _Cart2Iso(direction)
	#draw_circle(pos, 4.0, Color.VIOLET)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessVelocitySnow(_delta : float) -> void:
	var direction : Vector2 = (Vector2.RIGHT * _speed).rotated(_direction_indicator.get_angle())
	
	if direction.length() <= DIRECTION_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity = _Cart2Iso(direction)
	move_and_slide()

func _ProcessVelocityIce(delta : float) -> void:
	var direction : Vector2 = (Vector2.RIGHT * _speed).rotated(_direction_indicator.normalize_angle(_push_facing))
	
	if direction.length() <= DIRECTION_THRESHOLD:
		velocity -= velocity.normalized() * ice_friction * delta
		if velocity.length() < 0.01:
			velocity = Vector2.ZERO
	else:
		var max_speed : float = _GetMaxSpeed()
		velocity += _Cart2Iso(direction * delta)
		if velocity.length_squared() > (max_speed * max_speed):
			velocity = velocity.normalized() * max_speed
	
	move_and_slide()

func _ProcessFacing(delta : float) -> void:
	var amount = _axii[INPUT_RIGHT] - _axii[INPUT_LEFT]
	if abs(amount) > 0.0:
		_facing = wrapf(_facing + (turn_dps * amount * delta), 0.0, 360.0)
		_direction_indicator.degrees = _facing

func _ProcessSpeed(delta : float) -> void:
	var amount = _axii[INPUT_FORWARD] - _axii[INPUT_BACKWARD]
	var max_speed : float = _GetMaxSpeed()
	if abs(amount) <= DIRECTION_THRESHOLD:
		_speed = 0.0
	else:
		_push_facing = _facing # this line is here as a cheat. _ProcessFacing() must be called first
		_speed = max(-max_speed, min(max_speed, _speed + amount))

func _GetMaxSpeed() -> float:
	return max_ice_speed if _surface == SURFACE_ICE else max_snow_speed

func _GetSpeedNormal() -> float:
	# Should return -1.0 to 1.0
	return sign(_speed) * (_speed / _GetMaxSpeed())


func _Cart2Iso(ccoord : Vector2) -> Vector2:
	var iso : Vector2 = Vector2(
		ccoord.x - ccoord.y,
		(ccoord.x + ccoord.y) * 0.5
	)
	return iso
