extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const OBS_ITCH_URI : String = "https://obsidianblk.itch.io/"
const COZY_ITCH_URI : String = "https://itch.io/jam/cozy-winter-jam-2023"

const SETTINGS_SECTION : String = "Game"
const SETTINGS_KEY_PLAYERNAME : String = "Player_Name"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Main Menu")
@export var option_menu : StringName = &"":			set = set_option_menu
@export var scoreboard_menu : StringName = &"":		set = set_scoreboard_menu

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ignore_player_name_changed : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_start: Button = %BTN_Start
@onready var _btn_options: Button = %BTN_Options
@onready var _btn_scoreboard: Button = %BTN_Scoreboard
@onready var _lbl_version: Label = %LBL_Version

@onready var _edit_player_name: LineEdit = %EDIT_PlayerName

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_option_menu(o : StringName) -> void:
	if o != option_menu:
		option_menu = o
		_UpdateAvailableButtons()

func set_scoreboard_menu(s : StringName) -> void:
	if s != scoreboard_menu:
		scoreboard_menu = s
		_UpdateAvailableButtons()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_UpdateVersion()
	Settings.reset.connect(_on_settings_reset)
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_removed.connect(_on_settings_value_removed)
	Settings.value_changed.connect(_on_settings_value_changed)
	_UpdateAvailableButtons()


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _Pre_Visible_Change():
	if visible == false:
		var focus : Callable = func():
			_btn_start.grab_focus()
		focus.call_deferred()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateAvailableButtons() -> void:
	if _btn_options != null:
		_btn_options.visible = option_menu != &""
	if _btn_scoreboard != null:
		_btn_scoreboard.visible = scoreboard_menu != &""

func _UpdateVersion() -> void:
	if _lbl_version != null:
		_lbl_version.text = ProjectSettings.get_setting("application/config/version", "UNKNOWN")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_start_pressed():
	request(&"start_game")

func _on_btn_scoreboard_pressed() -> void:
	request(&"show_ui", {"ui_name":scoreboard_menu})

func _on_btn_options_pressed():
	if option_menu != &"":
		request(&"show_ui", {"ui_name":option_menu})

func _on_btn_quit_pressed():
	request(&"quit_application")

func _on_btnobs_logo_pressed() -> void:
	OS.shell_open(OBS_ITCH_URI)

func _on_btn_cozy_pressed() -> void:
	OS.shell_open(COZY_ITCH_URI)


func _on_settings_reset() -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_PLAYERNAME, Settings.DEFAULT_PLAYER_NAME)

func _on_settings_loaded() -> void:
	_edit_player_name.text = Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY_PLAYERNAME, Settings.DEFAULT_PLAYER_NAME)

func _on_settings_value_removed(section : String, key : String) -> void:
	if section != SETTINGS_SECTION: return
	if key != SETTINGS_KEY_PLAYERNAME: return
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_PLAYERNAME, Settings.DEFAULT_PLAYER_NAME)
	Settings.save()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section != SETTINGS_SECTION: return
	if key != SETTINGS_KEY_PLAYERNAME: return
	if not _ignore_player_name_changed:
		_edit_player_name.text = value


func _on_edit_player_name_text_changed(new_text: String) -> void:
	_ignore_player_name_changed = true
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_PLAYERNAME, new_text)
	_ignore_player_name_changed = false


func _on_edit_player_name_text_submitted(new_text: String) -> void:
	_ignore_player_name_changed = true
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_PLAYERNAME, new_text)
	_ignore_player_name_changed = false
	Settings.save()

