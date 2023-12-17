extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const OBS_ITCH_URI : String = "https://obsidianblk.itch.io/"
const COZY_ITCH_URI : String = "https://itch.io/jam/cozy-winter-jam-2023"


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Main Menu")
@export var option_menu : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_start = %BTN_Start
@onready var _btn_options = %BTN_Options

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_option_menu(o : StringName) -> void:
	if o != option_menu:
		option_menu = o
		_UpdateOptionsButton()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_UpdateOptionsButton()


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
func _UpdateOptionsButton() -> void:
	if _btn_options == null: return
	_btn_options.visible = option_menu != &""

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_start_pressed():
	request(&"start_game")


func _on_btn_options_pressed():
	if option_menu != &"":
		request(&"show_ui", {"ui_name":option_menu})


func _on_btn_quit_pressed():
	request(&"quit_application")


func _on_btnobs_logo_pressed() -> void:
	OS.shell_open(OBS_ITCH_URI)

func _on_btn_cozy_pressed() -> void:
	OS.shell_open(COZY_ITCH_URI)
