extends UIControl



# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _spin_master_volume : SpinBox = %SPIN_MasterVolume
@onready var _spin_music_volume : SpinBox = %SPIN_MusicVolume
@onready var _spin_sfx_volume : SpinBox = %SPIN_SFXVolume

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	GAS.volume_changed.connect(_on_gas_volume_changed)
	_spin_master_volume.value_changed.connect(_on_volume_value_changed.bind(GAS.BUS_MASTER))
	_spin_music_volume.value_changed.connect(_on_volume_value_changed.bind(GAS.BUS_MUSIC))
	_spin_sfx_volume.value_changed.connect(_on_volume_value_changed.bind(GAS.BUS_SFX))

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_back_pressed():
	request(&"close_ui")

func _on_gas_volume_changed(bus_name : StringName, value : float) -> void:
	match bus_name:
		GAS.BUS_MASTER:
			_spin_master_volume.value = value * 100.0
		GAS.BUS_MUSIC:
			_spin_music_volume.value = value * 100.0
		GAS.BUS_SFX:
			_spin_sfx_volume.value = value * 100.0

func _on_volume_value_changed(value : float, bus_name : StringName) -> void:
	GAS.set_volume(bus_name, value / 100.0)
