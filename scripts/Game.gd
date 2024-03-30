extends Node2D

const KEY = preload("res://scenes/key.tscn")
var keys : PackedScene
@onready var hand = $Hand
@onready var processor = $WordProcessor
@onready var moveCounter = $MoveCounter

var moves_left = 3

var text : String = ""

func _ready():
	text = processor.get_next_string(text)
	hand.set_hand_string(text)
	hand.check_words.connect(Callable(self, "check_word"))
	hand.pivoted.connect(Callable(self, "moved"))
	moveCounter.text = "Moves: " + str(moves_left)

func moved():
	moves_left -= 1
	moveCounter.text = "Moves: " + str(moves_left)

func add_moves(word : String):
	if len(word) == 6:
		moves_left += 3
	elif len(word) == 5 or len(word) == 4:
		moves_left += 2
	else:
		moves_left += 1
	moveCounter.text = "Moves: " + str(moves_left)

func check_word(word : String):
	var result = processor.all.find(word)
	if result == -1:
		hand.invalid_word()
	else:
		hand.valid_word()
		add_moves(word)
		#text = hand.get_hand_string_all()
		#hand.set_hand_string(processor.get_next_string(hand.get_hand_string_all()))
		hand.append_letters(processor.get_next_string(hand.get_hand_string_all()))
