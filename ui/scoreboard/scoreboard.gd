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
var _focus_level : String = ""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_main_menu: Button = %BTNMainMenu
@onready var _btn_prev_level: Button = %BTNPrevLevel
@onready var _btn_next_level: Button = %BTNNextLevel

@onready var _lbl_level_name: Label = %LBLLevelName

@onready var _entries : Array[ScoreEntryControl] = [
	%Entry_01,
	%Entry_02,
	%Entry_03,
	%Entry_04,
	%Entry_05,
	%Entry_06,
	%Entry_07,
	%Entry_08,
	%Entry_09,
	%Entry_10
]

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
	if "scoreboard" in data:
		if data["scoreboard"] is ScoreboardData and data["scoreboard"] != _scoreboard:
			_scoreboard = data["scoreboard"]
	if "level" in data:
		if typeof(data["level"]) == TYPE_STRING:
			_focus_level = data["level"]
	_UpdateEntities()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectScoreboard() -> void:
	if _scoreboard == null: return

func _ConnectScoreboard() -> void:
	if _scoreboard == null: return

func _ShowLevelSelectors(show : bool = true) -> void:
	if _btn_prev_level != null:
		_btn_prev_level.visible = show
	if _btn_next_level != null:
		_btn_next_level.visible = show

func _ClearEntries() -> void:
	for idx : int in range(_entries.size()):
		if _entries[idx] == null: continue
		_entries[idx].player_name = ""
		_entries[idx].score = 0

func _UpdateEntities() -> void:
	_ClearEntries()
	_ShowLevelSelectors(false)
	_lbl_level_name.text = ""
	if _scoreboard == null: return # Nothing more to do if there's no scoreboard
	
	if _focus_level.is_empty() or not _scoreboard.has_level_entries(_focus_level):
		_focus_level = _scoreboard.get_level_name()
		if _focus_level.is_empty(): # There were no level entries at all in the scoreboard data.
			return
	
	if _scoreboard.level_count() > 1:
		_ShowLevelSelectors()
	
	_lbl_level_name.text = _focus_level
	var count : int = min(10, _scoreboard.level_entry_count(_focus_level))
	for i : int in range(count):
		var sbe : ScoreboardEntry = _scoreboard.get_level_entry(_focus_level, i)
		if sbe != null:
			_entries[i].player_name = sbe.player_name
			_entries[i].score = sbe.score

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_main_menu_pressed() -> void:
	request(&"close_all")
	request(&"show_ui", {"ui_name":&"MainMenu"})

func _on_btn_level_select_pressed() -> void:
	pass # Replace with function body.


func _on_btn_prev_level_pressed() -> void:
	if _scoreboard == null: return
	if _focus_level.is_empty():
		_focus_level = _scoreboard.get_level_name()
	else:
		_focus_level = _scoreboard.get_previous_level_name(_focus_level)
	_UpdateEntities()


func _on_btn_next_level_pressed() -> void:
	if _scoreboard == null: return
	if _focus_level.is_empty():
		_focus_level = _scoreboard.get_level_name()
	else:
		_focus_level = _scoreboard.get_next_level_name(_focus_level)
	_UpdateEntities()



