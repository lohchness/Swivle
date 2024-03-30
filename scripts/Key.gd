extends Node2D
class_name Key

@onready var letter = $Letter
@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D

signal select_signal(number : int)
signal deselect_signal(number : int)
signal is_removed(number : int)

const TOP = 0
const EDGE = 1
const SIDE = 2
const FONT = 3
var colors = [
	# top color,      edge color,      side color,      font color
	[Color("d9a066"), Color("ebc4af"), Color("8f563b"), Color("402b21")],
	[Color("ef5b5f"), Color("f69baf"), Color("ca3a59"), Color("ffdee5")],
	[Color("8fde5e"), Color("c6fe56"), Color("5bb84c"), Color("edecf2")],
	[Color("597dce"), Color("080912"), Color("30346d"), Color("6dc2ca")],
	[Color("f3792c"), Color("fabe54"), Color("b0362d"), Color("faebc8")],
	[Color("72a3a7"), Color("1e2a4a"), Color("405a73"), Color("1e2a4a")]
]
var shade_color = Color("000000", .5) # Grayscale with alpha value 133

var max_tilt : float = 0.1
var curr_tilt : float = 0

var number : int = 0
var selected = false
const SELECTED_PIXELS = 50 # amount of pixels to be raised when selected

var target_opacity : int
var base_position
var shade_base_position

func _ready():
	base_position = position
	shade_base_position = $keySprites/Shade.position
	target_opacity = modulate.a8
	
	# Choose a colour
	var color = colors.pick_random()
	$keySprites/Top.modulate = color[TOP]
	$keySprites/Edge.modulate = color[EDGE]
	$keySprites/Side.modulate = color[SIDE]
	$keySprites/Shade.modulate = shade_color
	letter.set("theme_override_colors/font_color", color[FONT])
	
	pass

func _physics_process(delta):
	if selected:
		position = lerp(position, base_position - Vector2(0, SELECTED_PIXELS), 25 * delta)
		# hacky fix, whatever
		$keySprites/Shade.position = lerp($keySprites/Shade.position, shade_base_position + Vector2(0, 20), 25 * delta) 
	else:
		position = lerp(position, base_position, 25 * delta)
		$keySprites/Shade.position = lerp($keySprites/Shade.position, shade_base_position, 25 * delta)

	# Hover on mouse wiggle
	for i : Sprite2D in $keySprites.get_children():
		i.rotation = curr_tilt
	$Letter.rotation = curr_tilt
	curr_tilt /= 2
	
	# Disappear on submit
	modulate.a8 = lerp(modulate.a8, target_opacity, 25 * delta) 
	if (modulate.a8 == 0):
		queue_free()

func _on_area_2d_input_event(viewport, event, shape_idx):
	#if Input.is_action_just_pressed("Click") and not event.is_echo():
	#if event is InputEventKey and event.pressed:
	# Prevents from triggering twice in one frames
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		self.on_click()

func set_base_position(p : Vector2):
	base_position = p

func on_click():
	if !selected:
		select()
	else:
		deselect()

## GETTERS AND SETTERS ##

func get_letter() -> String:
	return letter.text

func set_letter(l : String) -> void:
	#assert(len(l) == 1)
	letter.text = l

func select():
	select_signal.emit(number)
	selected = true

func deselect():
	deselect_signal.emit(number)
	selected = false

func set_number(i : int):
	number = i

func get_number():
	return number

func disappear():
	target_opacity = 0
	pass

func _on_area_2d_mouse_entered():
	wiggle()

func wiggle():
	curr_tilt = max_tilt
	#if get_local_mouse_position().x > $keySprites.position.x:
		#curr_tilt = max_tilt
	#else:
		#curr_tilt = -max_tilt
