class_name PlayControlKey
extends ControlKey

signal play_pressed


func _on_texture_button_pressed() -> void:
	play_pressed.emit()
