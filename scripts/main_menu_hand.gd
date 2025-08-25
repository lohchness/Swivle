class_name MainMenuHand
extends Node2D

## Special Main Menu Hand
## Barebones copy of Hand scene.
## Only contains word "Swivle". The keys are special drawn sprites.
## Can still select and destroy keys, but nothing happens.
## Hand is centered around the middle, so destroying keys will reposition the keys.
## Will add sound effects to this for testing, and will add to normal Hand once it feels good.

signal key_selected(index: int)
signal check_words(word: String, score: int)

const NUM_KEYS: int = 6

var keys: Array[Key]
var selected_keys: Array[int] = []

@onready var winsize: Vector2 = get_viewport().size
@onready var key_scene: PackedScene = preload("res://scenes/main_menu_key.tscn")


func _ready() -> void:
	return
	for i: int in range(NUM_KEYS):
		var newkey: Key = key_scene.instantiate()
		add_child(newkey)
		keys.append(newkey)

		# Add keys with initial position having a space between each other
		# Keys centered in middle

		var initial_position: Vector2
