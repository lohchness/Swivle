extends Node2D

var base_position: Vector2
var off_screen: Vector2


func _ready() -> void:
	base_position = position
	off_screen = base_position


func _process(delta) -> void:
	position = lerp(position, off_screen, 20 * delta)


func game_over() -> void:
	off_screen = base_position - Vector2(0, 500)
	$Timer.game_over()


func new_game() -> void:
	off_screen = base_position
	$Timer.new_game()
