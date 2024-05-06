extends Node2D

var base_position
var off_screen

func _ready():
	base_position = position
	off_screen = base_position

func _process(delta):
	position = lerp(position, off_screen, 20 * delta)

func game_over():
	off_screen = base_position - Vector2(0, 500)
	$Timer.game_over()
