extends Node2D

enum State { GAMEOVER, PAUSED, MAINMENU, RUNNING }

var game_state: State = State.RUNNING
var total_score: int = 0
var text: String = ""

@onready var hand: Hand = $Hand
@onready var processor: Processor = $WordProcessor
@onready var score_counter: Label = $TopBar/ScoreWindow/ScoreCounter
@onready var timer: CountdownBar = $TopBar/Timer
@onready var restart_key: RestartControlKey = $RestartControlKey


func _ready() -> void:
	new_game()
	hand.check_words.connect(Callable(self, "check_word"))
	hand.pivoted.connect(Callable(self, "moved"))
	score_counter.text = str(total_score)
	timer.gameover.connect(Callable(self, "game_over"))
	restart_key.restart_pressed.connect(Callable(self, "restart"))


func _physics_process(_delta: float) -> void:
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


func add_score(score: int) -> void:
	total_score += score
	score_counter.text = str(total_score)


func set_score(score: int) -> void:
	total_score = score
	score_counter.text = str(total_score)


func check_word(word: String, score: int) -> void:
	var result: int = processor.all.find(word)
	if result == -1:
		hand.invalid_word()
	else:  # Correct word
		hand.valid_word()
		add_score(score)
		hand.append_letters(processor.get_next_string(hand.get_hand_string_all()))

		timer.add_time(len(word))


func game_over() -> void:
	game_state = State.GAMEOVER
	hand.game_over()
	$TopBar.game_over()
	restart_key.game_over()


func restart() -> void:
	game_state = State.RUNNING
	new_game()
	hand.new_game()
	hand.deselect_all()
	$TopBar.new_game()
	restart_key.new_game()
