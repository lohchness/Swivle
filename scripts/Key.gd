class_name Key
extends Node2D

signal select_signal(number: int)
signal deselect_signal(number: int)
signal is_removed(number: int)

const TOP = 0
const EDGE = 1
const SIDE = 2
const FONT = 3

const SELECTED_PIXELS: int = 50 # amount of pixels to be raised when selected

var max_tilt: float = 0.15
var curr_tilt: float = 0

var number: int = 0
var selected: bool = false

var target_opacity: int
var base_position: Vector2
var shade_base_position: Vector2

var curr_scale: Vector2
var base_scale: Vector2
var zoom_in_scalar = 1.1

var letter_points: Dictionary[int, Array] = {
	1 : ["E", "A", "I", "O", "N", "R", "T", "L", "S", "U"],
	2 : ["D", "G"],
	3 : ["B", "C", "M", "P"],
	4 : ["F", "H", "V", "W", "Y"],
	5 : ["K"],
	8 : ["J", "X"],
	10 : ["Q", "Z"]
}

var colors: Array[Array] = [
	# top color,      edge color,      side color,      font color
	[Color("d9a066"), Color("ebc4af"), Color("8f563b"), Color("402b21")], # Brown
	[Color("ef5b5f"), Color("f69baf"), Color("ca3a59"), Color("ffdee5")], # Pink
	[Color("8fde5e"), Color("c6fe56"), Color("5bb84c"), Color("edecf2")], # Green
	[Color("597dce"), Color("080912"), Color("30346d"), Color("6dc2ca")], # Light Blue
	[Color("f3792c"), Color("fabe54"), Color("b0362d"), Color("faebc8")], # Orange
	[Color("72a3a7"), Color("1e2a4a"), Color("405a73"), Color("1e2a4a")], # Gray Blue
	[Color("d77bba"), Color("3c0452"), Color("8d2ba4"), Color("a211c4")], # Purple
	[Color("ffffff"), Color("404040"), Color("9f9f9f"), Color("847e87")], # White
	[Color("ac3232"), Color("721212"), Color("bf263c"), Color("db6c76")], # Red
]
var shade_color := Color("000000", .5) # Grayscale with alpha value 133

@onready var letter: Label = $Letter
@onready var score: Label = $Score
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D



func _ready() -> void:
	base_position = position
	shade_base_position = $keySprites/Shade.position
	target_opacity = modulate.a8
	base_scale = scale
	curr_scale = base_scale

	# Choose a colour
	var color: Array = colors.pick_random()
	$keySprites/Top.modulate = color[TOP]
	$keySprites/Edge.modulate = color[EDGE]
	$keySprites/Side.modulate = color[SIDE]
	$keySprites/Shade.modulate = shade_color
	letter.set("theme_override_colors/font_color", color[FONT])
	score.set("theme_override_colors/font_color", color[FONT])

func _physics_process(delta) -> void:
	if selected:
		position = lerp(position, base_position - Vector2(0, SELECTED_PIXELS), 25 * delta)
		# FIXME: Lerps to position slightly above shade_base_position
		$keySprites/Shade.position = lerp(
			$keySprites/Shade.position, shade_base_position + Vector2(0, 20), 25 * delta
		)
	else:
		position = lerp(position, base_position, 25 * delta)
		$keySprites/Shade.position = lerp(
			$keySprites/Shade.position,
			shade_base_position, 25 * delta
		)

	# Hover on mouse wiggle
	for i: Sprite2D in $keySprites.get_children():
		i.rotation = curr_tilt
	$Letter.rotation = curr_tilt
	$Score.rotation = curr_tilt * 2
	curr_tilt /= 2

	# TODO : Scale from center
	#scale = lerp(scale, curr_scale, 50 * delta)

	# Disappear and free on submit
	modulate.a8 = lerp(modulate.a8, target_opacity, 25 * delta)
	if (modulate.a8 == 0):
		queue_free()

func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	# Prevents from triggering twice in one frames
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		self.on_click()

func _on_area_2d_mouse_entered() -> void:
	wiggle()
	zoom_in()

func _on_area_2d_mouse_exited() -> void:
	zoom_out()

func on_click() -> void:
	if !selected:
		select()
	else:
		deselect()

## HELPERS, GETTERS, SETTERS

func select() -> void:
	select_signal.emit(number)
	selected = true

func deselect() -> void:
	deselect_signal.emit(number)
	selected = false

func get_letter() -> String:
	return letter.text

func set_letter(l : String) -> void:
	letter.text = l
	set_score()

func get_score() -> int:
	return int(score.text)

func set_score() -> void:
	for point in letter_points:
		if letter.text in letter_points[point]:
			score.text = str(point)

func set_base_position(p : Vector2) -> void:
	base_position = p

func set_number(i: int) -> void:
	number = i

func get_number() -> int:
	return number

func disappear() -> void:
	target_opacity = 0

func wiggle() -> void:
	curr_tilt = max_tilt

func zoom_in() -> void:
	curr_scale = base_scale * zoom_in_scalar

func zoom_out() -> void:
	curr_scale = base_scale
