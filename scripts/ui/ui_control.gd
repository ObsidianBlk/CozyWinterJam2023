extends Control
class_name UIControl


# --------------------------------------------------------------------------------------------------
# Signals
# --------------------------------------------------------------------------------------------------
signal requested(action : StringName, payload : Dictionary)
signal active()
signal deactive()

# --------------------------------------------------------------------------------------------------
# Export Variables
# --------------------------------------------------------------------------------------------------
@export_category("UI Control")
@export var hide_at_start : bool = true
@export var explicit_close_only : bool = false

# --------------------------------------------------------------------------------------------------
# Override Methods
# --------------------------------------------------------------------------------------------------
func _ready() -> void:
	if hide_at_start:
		visible = false

# --------------------------------------------------------------------------------------------------
# "Virtual" Methods
# --------------------------------------------------------------------------------------------------
func _Pre_Visible_Change():
	pass

func set_data(data : Dictionary) -> void:
	pass

# --------------------------------------------------------------------------------------------------
# Private Methods
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Public Methods
# --------------------------------------------------------------------------------------------------
func request(action : StringName, payload : Dictionary = {}) -> void:
	requested.emit(action, payload)

func show_ui() -> void:
	if not visible:
		_Pre_Visible_Change()
		visible = true
		active.emit()

func close_ui() -> void:
	if visible:
		_Pre_Visible_Change()
		visible = false
		deactive.emit()
