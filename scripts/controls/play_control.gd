class_name PlayControlKey
extends ControlKey

signal play_pressed

const TARGET: Vector2 = Vector2(455, 337)

var base_position: Vector2
var offset: Vector2


func _ready() -> void:
	super()
	# Assumes play/resume is off screen at scene ready.
	base_position = position
	offset = Vector2.ZERO


func _physics_process(delta: float) -> void:
	super(delta)
	position = lerp(position, base_position + offset, 20 * delta)


func move_on_screen() -> void:
	offset = TARGET - base_position


func move_off_screen() -> void:
	offset = Vector2.ZERO


func _on_texture_button_pressed() -> void:
	play_pressed.emit()
