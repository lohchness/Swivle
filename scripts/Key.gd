extends Node2D
class_name Key

@onready var letter = $Letter
@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D

signal select_signal(number : int)
signal deselect_signal(number : int)
signal is_removed(number : int)

var number : int = 0
var selected = false
const SELECTED_PIXELS = 50 # amount of pixels to be raised when selected

var target_opacity : int

var base_position

func _ready():
	base_position = position
	target_opacity = modulate.a8
	pass

func _physics_process(delta):
	if selected:
		position = lerp(position, base_position - Vector2(0, SELECTED_PIXELS), 25 * delta)
	else:	
		position = lerp(position, base_position, 25 * delta)
	
	modulate.a8 = lerp(modulate.a8, target_opacity, 25 * delta)
	if (modulate.a8 == 0):
		#print("here")
		#is_removed.emit(number)
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
	#print("Clicked on " + get_letter())	
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
	#modulate.a = lerp(modulate.a, 0, 25)
	#queue_free()
	#modulate.a8 = 50
	#modulate.a = 50
	target_opacity = 0
	pass
