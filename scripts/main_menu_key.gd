class_name MainMenuKey
extends Node2D

## Barebones copy of Key class.
## Intended for the Main Menu. Only has key and shade sprites.
## Can be selected, pivoted, and removed.

signal select_signal(number: int)
signal deselect_signal(number: int)

const SELECTED_PIXELS: int = 50  # amount of pixels to be raised when selected

var max_tilt: float = 0.15
var curr_tilt: float = 0

var number: int = 0
var selected: bool = false

var target_opacity: int
var base_position: Vector2
var shade_base_position: Vector2

var shade_color: Color = Color("000000", .5)

@onready var shade_sprite: Sprite2D = $Shade
@onready var key_sprite: Sprite2D = $Key


func _ready() -> void:
	base_position = position
	shade_base_position = $Shade.position
	target_opacity = modulate.a8
	shade_sprite.modulate = shade_color


func _physics_process(delta: float) -> void:
	if selected:
		position = lerp(position, base_position - Vector2(0, SELECTED_PIXELS), 25 * delta)
		shade_sprite.position = lerp(
			shade_sprite.position, shade_base_position + Vector2(0, 20), 25 * delta
		)
	else:
		position = lerp(position, base_position, 25 * delta)
		shade_sprite.position = lerp(shade_sprite.position, shade_base_position, 25 * delta)

	shade_sprite.rotation = curr_tilt
	key_sprite.rotation = curr_tilt
	curr_tilt /= 2

	# Disappear and free on submit
	modulate.a8 = lerp(modulate.a8, target_opacity, 25 * delta)
	if is_zero_approx(modulate.a8):
		queue_free()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		self.on_click()


func _on_area_2d_mouse_entered() -> void:
	wiggle()


func wiggle() -> void:
	curr_tilt = max_tilt


func on_click() -> void:
	if selected:
		deselect()
	else:
		select()


func select() -> void:
	select_signal.emit(number)
	selected = true


func deselect() -> void:
	deselect_signal.emit(number)
	selected = false
