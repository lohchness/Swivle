class_name ControlKey
extends TwoStateSwitch

## Abstract class ControlKey
## This class is for control buttons, i.e. Play, Quit, Pause, Resume, Options.
## Will error if not implemented properly.
## Signals and functionality to be defined in child classes.

var max_tilt: float = 0.15
var curr_tilt: float = 0

@onready var button: TextureButton = $TextureButton


func _ready() -> void:
	super()
	button.focus_mode = 0


func _physics_process(delta: float) -> void:
	super(delta)
	button.rotation = curr_tilt
	curr_tilt /= 2


func _on_texture_button_mouse_entered() -> void:
	curr_tilt = max_tilt
