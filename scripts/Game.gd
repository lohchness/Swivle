extends Node2D

enum State {GAMEOVER, PAUSED, MAINMENU, RUNNING}

var total_score: int = 0
var text: String = ""

var game_state: State = State.RUNNING

@onready var hand: Hand = $Hand
@onready var processor: Processor = $WordProcessor
@onready var scoreCounter: Label = $TopBar/ScoreCounter
@onready var timer: CountdownBar = $TopBar/Timer

func _ready() -> void:
	new_game()
	hand.check_words.connect(Callable(self, "check_word"))
	hand.pivoted.connect(Callable(self, "moved"))
	scoreCounter.text = str(total_score)
	timer.gameover.connect(Callable(self, "game_over"))

func _process(delta) -> void:
	match game_state:
		State.RUNNING:
			if Input.is_action_just_pressed("DEBUG_END"):
				game_over()
		State.GAMEOVER:
			if Input.is_action_just_pressed("DEBUG_END"):
				restart()

func new_game() -> void:
	text = processor.get_next_string("")
	hand.set_hand_string(text)
	set_score(0)

func add_score(score : int) -> void:
	total_score += score
	scoreCounter.text = str(total_score)

func set_score(score : int) -> void:
	total_score = score
	scoreCounter.text = str(total_score)

func check_word(word : String, score : int) -> void:
	var result = processor.all.find(word)
	if result == -1:
		hand.invalid_word()
	else: # Correct word
		hand.valid_word()
		add_score(score)
		hand.append_letters(processor.get_next_string(hand.get_hand_string_all()))

		timer.add_time(len(word))

func game_over() -> void:
	game_state = State.GAMEOVER
	hand.game_over()
	$TopBar.game_over()

func restart() -> void:
	game_state = State.RUNNING
	new_game()
	hand.new_game()
	hand.deselect_all()
	$TopBar.new_game()
