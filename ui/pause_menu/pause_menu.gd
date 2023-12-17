extends UIControl

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_resume: Button = %BTNResume


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _Pre_Visible_Change():
	if visible == false:
		var focus : Callable = func():
			_btn_resume.grab_focus()
		focus.call_deferred()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_resume_pressed() -> void:
	request(&"unpause")

func _on_btn_quit_main_pressed() -> void:
	request(&"quit_to_main")

func _on_btn_quit_desktop_pressed() -> void:
	request(&"quit_application")

func _on_btn_options_pressed() -> void:
	request(&"show_ui", {"ui_name":&"OptionsMenu"})
