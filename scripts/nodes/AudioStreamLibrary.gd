extends Node
class_name AudioStreamLibrary

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal finished()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Audio Stream Library")
@export var player : AudioStreamPlayer2D = null:		set = set_player
@export var streams : Array[AudioStream] = []

@export_subgroup("Misc")
@export_range(-80.0, 24.0) var volume_db: = 0.0
@export_range(0.01, 4.0) var min_pitch : float = 1.0:	set = set_min_pitch
@export_range(0.01, 4.0) var max_pitch : float = 1.0:	set = set_max_pitch

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_player(ap : AudioStreamPlayer2D) -> void:
	if ap == player: return
	_DisconnectPlayer()
	player = ap
	_ConnectPlayer()

func set_min_pitch(p : float) -> void:
	if p >= 0.01 and p <= 4.0:
		min_pitch = p
		if min_pitch > max_pitch:
			min_pitch = max_pitch

func set_max_pitch(p : float) -> void:
	if p >= 0.01 and p <= 4.0:
		max_pitch = p
		if max_pitch < min_pitch:
			max_pitch = min_pitch

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectPlayer()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectPlayer() -> void:
	if player == null: return
	if player.finished.is_connected(_on_player_finished):
		player.finished.disconnect(_on_player_finished)

func _ConnectPlayer() -> void:
	if player == null: return
	if not player.finished.is_connected(_on_player_finished):
		player.finished.connect(_on_player_finished)

func _GetPitch() -> float:
	if abs(max_pitch - min_pitch) <= 0.001: return min_pitch
	var variance = max_pitch - min_pitch
	return min_pitch + randf_range(0.0, variance)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func play_random(force : bool = false) -> void:
	if player == null: return
	if streams.size() <= 0: return
	if player.playing and not force: return
	
	var idx = randi_range(0, streams.size() - 1)
	player.stop()
	player.stream = streams[idx]
	player.volume_db = volume_db
	player.pitch_scale = _GetPitch()
	player.play()

func stop() -> void:
	if player == null: return
	player.stop()

func is_playing() -> bool:
	if player == null: return false
	return player.playing

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_finished() -> void:
	finished.emit()


