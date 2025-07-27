class_name TopBar
extends Node2D

var base_position: Vector2
var off_screen: Vector2

@onready var timer: CountdownBar = $Timer


func _ready() -> void:
	base_position = position
	off_screen = base_position


func _physics_process(delta: float) -> void:
	position = lerp(position, off_screen, 20 * delta)


func move_off_screen(offset: Vector2) -> void:
	off_screen = base_position - offset


func move_on_screen() -> void:
	off_screen = base_position


func pause_timer() -> void:
	timer.pause()


func resume_timer() -> void:
	timer.resume()


func restart_timer() -> void:
	timer.restart_timer()
