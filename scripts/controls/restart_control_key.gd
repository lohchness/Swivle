class_name RestartControlKey
extends ControlKey

signal restart_pressed


func _on_texture_button_pressed() -> void:
	restart_pressed.emit()
