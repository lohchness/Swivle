class_name RestartControlKey
extends ControlKey

signal restart_pressed

const TARGET: Vector2 = Vector2(576, 352)

var base_position: Vector2
var offset: Vector2


func _ready() -> void:
	super()
	# Assumes the restart key is off screen at scene ready.
	base_position = position
	offset = Vector2.ZERO


func _physics_process(delta: float) -> void:
	super(delta)
	position = lerp(position, base_position + offset, 20 * delta)


func game_over() -> void:
	offset = TARGET - base_position


func new_game() -> void:
	offset = Vector2.ZERO


func _on_texture_button_pressed() -> void:
	restart_pressed.emit()
