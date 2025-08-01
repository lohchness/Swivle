extends Node2D

var game_state: Globals.State
var total_score: int = 0
var text: String = ""

@onready var hand: Hand = $Hand
@onready var processor: Processor = $WordProcessor
@onready var topbar: TopBar = $TopBar
@onready var score_counter: Label = $TopBar/ScoreWindow/ScoreCounter
@onready var timer: CountdownBar = $TopBar/Timer
@onready var restart_key: RestartControlKey = $RestartControlKey
@onready var resume_key: PlayControlKey = $PlayControlKey
@onready var quit_key: QuitControlKey = $QuitControlKey
@onready var end_game: EndGame = $EndGame


func _ready() -> void:
	new_game()

	hand.check_words.connect(Callable(check_word))
	timer.gameover.connect(Callable(game_over))
	restart_key.restart_pressed.connect(Callable(restart))
	resume_key.play_pressed.connect(Callable(resume_game))
	quit_key.quit_pressed.connect(Callable(quit_game))
	end_game.restart_game.connect(Callable(restart))

	score_counter.text = str(total_score)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_END"):
		match game_state:
			Globals.State.RUNNING:
				game_over()
			Globals.State.GAMEOVER:
				restart()

	if event.is_action_pressed("Pause"):
		match game_state:
			Globals.State.RUNNING:
				pause_game()
			Globals.State.PAUSED:
				resume_game()


func new_game() -> void:
	game_state = Globals.State.RUNNING
	text = processor.get_next_string("")
	hand.set_hand_string(text)
	set_score(0)


func check_word(word: String, score: int) -> void:
	var result: int = processor.all.find(word)
	if result == -1:
		hand.invalid_submission()
	else:  # Correct word
		hand.valid_submission()
		add_score(score)
		hand.add_new_letters(processor.get_next_string(hand.get_hand_as_string()))

		timer.add_time(len(word))


func pause_game() -> void:
	game_state = Globals.State.PAUSED

	hand.move_off_screen()
	topbar.move_off_screen()
	topbar.pause_timer()

	restart_key.move_on_screen()
	resume_key.move_on_screen()
	quit_key.move_on_screen()


func resume_game() -> void:
	game_state = Globals.State.RUNNING

	hand.move_on_screen()
	topbar.move_on_screen()
	topbar.resume_timer()

	restart_key.move_off_screen()
	resume_key.move_off_screen()
	quit_key.move_off_screen()


func game_over() -> void:
	game_state = Globals.State.GAMEOVER

	# Push stats to globals
	Globals.score = total_score
	Globals.word = processor.chosen_word

	hand.move_off_screen()
	topbar.move_off_screen()
	topbar.pause_timer()

	end_game.bulk_move_on_screen()


func restart() -> void:
	game_state = Globals.State.RUNNING
	new_game()

	hand.move_on_screen()
	hand.deselect_all()
	topbar.move_on_screen()
	topbar.restart_timer()

	restart_key.move_off_screen()
	resume_key.move_off_screen()
	quit_key.move_off_screen()

	end_game.bulk_move_off_screen()


func quit_game() -> void:
	# TODO: Quit key leads to start menu
	return


func add_score(score: int) -> void:
	total_score += score
	score_counter.text = str(total_score)


func set_score(score: int) -> void:
	total_score = score
	score_counter.text = str(total_score)
