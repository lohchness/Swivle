class_name TopBar
extends TwoStateSwitch

var base_position: Vector2
var off_screen: Vector2

@onready var timer: CountdownBar = $Timer


func pause_timer() -> void:
	timer.pause()


func resume_timer() -> void:
	timer.resume()


func restart_timer() -> void:
	timer.restart_timer()
