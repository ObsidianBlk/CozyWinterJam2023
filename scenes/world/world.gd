extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SCOREBOARD_RESOURCE_PATH : String = "user://scoreboard.res"

const INITIAL_MUSIC_TRACK : AudioStream = preload("res://assets/music/Christmas synths.ogg")

const BLUR_IN_SIZE : float = 10.0
const BLUR_OUT_SIZE : float = 0.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("World")
@export_file() var initial_level : String = ""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_level : Level = null
var _transitioning : bool = false

var _scoreboard : ScoreboardData = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ui : UIRoot = %UI
@onready var _music_player: AudioStreamPlayer = %MusicPlayer
@onready var _hud: HUDControl = %HUD

@onready var _circle_blur: ColorRect = $Effects/CircleBlur
@onready var _background: TextureRect = $Backgrounds/Background


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	get_tree().paused = true
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()
	_InitScoreboard()
	_music_player.stream = INITIAL_MUSIC_TRACK
	_music_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if _transitioning: return
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			if _active_level == null:
				get_tree().quit()
			else:
				_on_requested(&"unpause")
		else:
			_on_requested(&"pause")

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _InitScoreboard() -> void:
	if not ResourceLoader.exists(SCOREBOARD_RESOURCE_PATH):
		_scoreboard = ScoreboardData.new()
		_SaveScoreboard()
	else:
		_scoreboard = ResourceLoader.load(SCOREBOARD_RESOURCE_PATH)
		if _scoreboard == null:
			printerr("ERROR: Failed to load scoreboard file!")
			_scoreboard = ScoreboardData.new()
			_SaveScoreboard()

func _SaveScoreboard() -> void:
	if _scoreboard == null: return
	if ResourceSaver.save(_scoreboard, SCOREBOARD_RESOURCE_PATH) != OK:
		printerr("ERROR: Failed to save scoreboard file!")

func _DropActiveLevel() -> void:
	if _active_level == null: return
	if _active_level.level_name_changed.is_connected(_hud.set_level_name):
		_active_level.level_name_changed.disconnect(_hud.set_level_name)
	if _active_level.score_changed.is_connected(_hud.set_score):
		_active_level.score_changed.disconnect(_hud.set_score)
	if _active_level.timer_changed.is_connected(_hud.set_sec_remaining):
		_active_level.timer_changed.disconnect(_hud.set_sec_remaining)
	if _active_level.level_complete.is_connected(_on_level_complete):
		_active_level.level_complete.disconnect(_on_level_complete)
	remove_child(_active_level)

func _SwapActiveLevel(new_level : Level) -> void:
	_DropActiveLevel()
	_active_level = new_level
	if _active_level != null:
		add_child(_active_level)
		if not _active_level.level_name_changed.is_connected(_hud.set_level_name):
			_active_level.level_name_changed.connect(_hud.set_level_name)
		if not _active_level.score_changed.is_connected(_hud.set_score):
			_active_level.score_changed.connect(_hud.set_score)
		if not _active_level.timer_changed.is_connected(_hud.set_sec_remaining):
			_active_level.timer_changed.connect(_hud.set_sec_remaining)
		if not _active_level.level_complete.is_connected(_on_level_complete):
			_active_level.level_complete.connect(_on_level_complete)

func _LoadLevel(level_path : String) -> int:
	var PackedLevel : PackedScene = load(level_path)
	if PackedLevel == null:
		return ERR_FILE_CANT_READ
	var level : Node = PackedLevel.instantiate()
	if not level is Level:
		level.queue_free()
		return ERR_INVALID_DECLARATION
	
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	_SwapActiveLevel(level)
	return OK

func _TransitionLevel(level_path : String) -> void:
	await _BlurTo(BLUR_IN_SIZE, 0.5)
	if _LoadLevel(level_path) == OK:
		_ui.close_all()
		await _BackgroundModulate(Color.TRANSPARENT, 0.5)
		_hud.visible = true
		get_tree().paused = false
	else:
		await _BackgroundModulate(Color.WHITE, 0.5)
	await _BlurTo(BLUR_OUT_SIZE, 0.5)

func _EndGame(ui_name : StringName) -> void:
	if _transitioning: return
	await _BlurTo(BLUR_IN_SIZE, 0.5)
	await _BackgroundModulate(Color.WHITE, 0.5)
	_DropActiveLevel()
	_hud.visible = false
	get_tree().paused = true
	await _BlurTo(BLUR_OUT_SIZE, 0.5)
	_ui.show_ui(ui_name)
	

func _BlurActive() -> bool:
	if _circle_blur == null: return false
	return _circle_blur.material.get_shader_param("size") > 0.0

func _BackgroundModulate(mod : Color, duration : float) -> void:
	if _background == null or _transitioning: return
	_transitioning = true
	
	var tween : Tween = create_tween()
	tween.tween_property(_background, "modulate", mod, duration)
	await tween.finished
	_transitioning = false

func _BlurTo(size : float, duration : float) -> void:
	if _circle_blur == null or _transitioning: return
	_transitioning = true
	
	var tween : Tween = create_tween()
	tween.tween_property(_circle_blur.material, "shader_parameter/size", size, duration)
	await tween.finished
	_transitioning = false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_level_complete(score : int) -> void:
	if _active_level == null: return
	if score > 0:
		var score_entry : ScoreboardEntry = ScoreboardEntry.new()
		score_entry.level_name = _active_level.level_name
		score_entry.player_name = "Player" # TODO: Change this, obviously!
		score_entry.score = score
		_scoreboard.add_entry(score_entry)
		_SaveScoreboard()
	_EndGame(&"MainMenu")

func _on_requested(action : StringName, payload : Dictionary = {}):
	if _transitioning: return
	match action:
		&"start_game":
			if initial_level.is_empty(): return
			_TransitionLevel(initial_level)
		&"transition_level":
			if "level_path" in payload and typeof(payload["level_path"]) == TYPE_STRING:
				_TransitionLevel(payload["level_path"])
		&"pause":
			if get_tree().paused == false:
				get_tree().paused = true
				_BlurTo(BLUR_IN_SIZE, 0.25)
				_ui.show_ui(&"PauseMenu")
		&"unpause":
			if get_tree().paused == true and _active_level != null:
				_ui.close_all()
				_BlurTo(BLUR_OUT_SIZE, 0.25)
				get_tree().paused = false
		&"quit_to_main":
			_ui.close_all()
			_EndGame(&"MainMenu")
		&"quit_application":
			get_tree().quit()

