extends Node2D

const KEY = preload("res://scenes/key.tscn")
var keys : PackedScene
@onready var hand = $Hand
@onready var processor = $WordProcessor
@onready var scoreCounter = $TopBar/ScoreCounter
@onready var timer = $TopBar/Timer

var total_score = 0

var text : String = ""

enum {GAMEOVER, PAUSED, MAINMENU, RUNNING}
var gameState = RUNNING

func _ready():
	new_game()
	hand.check_words.connect(Callable(self, "check_word"))
	hand.pivoted.connect(Callable(self, "moved"))
	scoreCounter.text = str(total_score)
	timer.gameover.connect(Callable(self, "game_over"))

func _process(delta):
	
	match gameState:
		RUNNING:
			if Input.is_action_just_pressed("DEBUG_END"):
				game_over()
		GAMEOVER:
			if Input.is_action_just_pressed("DEBUG_END"):
				restart()

func new_game():
	text = processor.get_next_string("")
	hand.set_hand_string(text)
	set_score(0)

func add_score(score : int):
	total_score += score
	scoreCounter.text = str(total_score)

func set_score(score : int):
	total_score = score
	scoreCounter.text = str(total_score)

func check_word(word : String, score : int):
	var result = processor.all.find(word)
	if result == -1:
		hand.invalid_word()
	else: # Correct word
		hand.valid_word()
		add_score(score)
		hand.append_letters(processor.get_next_string(hand.get_hand_string_all()))
		
		timer.add_time(len(word))

func game_over():
	gameState = GAMEOVER
	hand.game_over()
	$TopBar.game_over()
	pass

func restart():
	gameState = RUNNING
	new_game()
	hand.new_game()
	hand.deselect_all()
	$TopBar.new_game()
