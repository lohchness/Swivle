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
@export var on_screen_in_editor: bool = false
## Enable ONLY IF on_screen_in_editor is true.
@export var should_start_off_screen: bool = false

var on_screen_position: Vector2
var off_screen_position: Vector2
var move_to: Vector2
var at_target_position: bool


func _ready() -> void:
	at_target_position = on_screen_in_editor

	### FIXME Horrendous code
	#if use_editor_as_start and on_screen_in_editor:
	#at_target_position = true
	#on_screen_position = position
	#off_screen_position = position + offset_vector
	#elif not use_editor_as_start and on_screen_in_editor:
	#at_target_position = true
	#on_screen_position = target_position
	#off_screen_position = target_position + offset_vector
#
	#elif use_editor_as_start and not on_screen_in_editor:
	#at_target_position = false
	#on_screen_position = position + offset_vector
	#off_screen_position = position
	#elif not use_editor_as_start and not on_screen_in_editor:
	#at_target_position = false
	#on_screen_position = target_position + offset_vector
	#off_screen_position = target_position

	if on_screen_in_editor:
		on_screen_position = position if use_editor_as_start else target_position
		off_screen_position = on_screen_position + offset_vector
		position = on_screen_position
	elif not on_screen_in_editor:
		off_screen_position = position if use_editor_as_start else target_position
		on_screen_position = off_screen_position + offset_vector
		position = off_screen_position

	if on_screen_in_editor and should_start_off_screen:
		at_target_position = false
		position = off_screen_position

	move_to = position


func _physics_process(delta: float) -> void:
	position = lerp(position, move_to, 20 * delta)


func move_on_screen() -> void:
	set_process_input(true)
	move_to = on_screen_position
	at_target_position = true


func move_off_screen() -> void:
	set_process_input(false)
	move_to = off_screen_position
	at_target_position = false


func switch_position() -> void:
	if at_target_position:
		move_off_screen()
	else:
		move_on_screen()
