extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const UI_MAINMENU : StringName = &"MainMenu"
const UI_LEVELSELECT : StringName = &"LevelSelectMenu"


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _scoreboard : ScoreboardData = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_main_menu = %BTNMainMenu


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _Pre_Visible_Change():
	if visible == false:
		var focus : Callable = func():
			_btn_main_menu.grab_focus()
		focus.call_deferred()

func set_data(data : Dictionary) -> void:
	if not "scoreboard" in data or not data["scoreboard"] is ScoreboardData: return
	if data["scoreboard"] == _scoreboard: return

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectScoreboard() -> void:
	if _scoreboard == null: return

func _ConnectScoreboard() -> void:
	if _scoreboard == null: return

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
