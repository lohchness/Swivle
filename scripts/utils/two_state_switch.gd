class_name TwoStateSwitch
extends Node2D

## This script condenses the behaviour of a lot of nodes in the project,
## which is buttons/texts/sprites that only move up or down.
##
## Every scene that inherits from this will have to define
## a target position, and an offset vector.
## The target position is the on-screen position.
## The offset vector is where it will go off-screen.

## Should the position in the editor be the initial position?
@export var use_editor_as_start: bool = false
## The position this should be when it is ON screen
@export var target_position: Vector2 = Vector2.ZERO
## The offset vector to move this OFF screen
@export var offset_vector: Vector2 = Vector2.ZERO
## Is the initial position ON screen?
@export var start_on_screen: bool = false

var on_screen_position: Vector2
var off_screen_position: Vector2
var move_to: Vector2
var is_on_screen: bool


func _ready() -> void:
	is_on_screen = start_on_screen

	if not use_editor_as_start:
		position = target_position
		if not start_on_screen:
			position += offset_vector
		on_screen_position = target_position
	move_to = position

	### FIXME Horrendous code
	#if use_editor_as_start and start_on_screen:
	#on_screen_position = position
	#off_screen_position = position + offset_vector
	#elif not use_editor_as_start and start_on_screen:
	#on_screen_position = target_position
	#off_screen_position = target_position + offset_vector

	#elif use_editor_as_start and not start_on_screen:
	#on_screen_position = position + offset_vector
	#off_screen_position = position
	#elif not use_editor_as_start and not start_on_screen:
	#on_screen_position = target_position + offset_vector
	#off_screen_position = target_position

	on_screen_position = position if use_editor_as_start else target_position
	off_screen_position = on_screen_position + offset_vector
	if not start_on_screen:
		var tmp: Vector2 = on_screen_position
		on_screen_position = off_screen_position
		off_screen_position = tmp


func _physics_process(delta: float) -> void:
	position = lerp(position, move_to, 20 * delta)


func move_on_screen() -> void:
	set_process_input(true)
	move_to = on_screen_position
	is_on_screen = true


func move_off_screen() -> void:
	set_process_input(false)
	move_to = off_screen_position
	is_on_screen = false


func switch_position() -> void:
	if is_on_screen:
		move_to = off_screen_position
	else:
		move_to = on_screen_position
	is_on_screen = !is_on_screen
