class_name QuitControlKey
extends ControlKey

signal quit_pressed


func _on_texture_button_pressed() -> void:
	quit_pressed.emit()
