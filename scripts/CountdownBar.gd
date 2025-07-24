class_name CountdownBar
extends Sprite2D

signal gameover

const START_RATE: int = 10
var curr_rate: int

var percentage: float = 1.0
var target_percentage: float

var thresh_1: float = .10
var thresh_1_rate: float = 3
var thresh_2: float = .25
var thresh_2_rate: float = 5  # 7
var thresh_3: float = .35
var thresh_3_rate: float = 8  # 10

var add_progress: float = .2

@onready var bar: Sprite2D = $TimerBar


func _ready() -> void:
	curr_rate = START_RATE
	target_percentage = percentage


func _physics_process(delta: float) -> void:
	percentage -= curr_rate * delta / 100

	# Percentage
	if percentage < 0:
		percentage = 0
		gameover.emit()
	if percentage > 1:
		percentage = 1

	update_rate()

	target_percentage = lerp(target_percentage, percentage, 25 * delta)
	bar.set_scale(Vector2(target_percentage, 1))
	#bar.set_scale(Vector2(percentage, 1))


func update_rate() -> void:
	# Rate
	if percentage < thresh_1 && curr_rate > thresh_1_rate:
		change_rate(thresh_1_rate)
	if percentage < thresh_2 && curr_rate > thresh_2_rate:
		change_rate(thresh_2_rate)
	if percentage < thresh_3 && curr_rate > thresh_3_rate:
		change_rate(thresh_3_rate)

	# Original rate
	if percentage > thresh_3 && curr_rate < START_RATE:
		change_rate(START_RATE)


func add_time(num_letters: int) -> void:
	percentage += add_progress * num_letters

	update_rate()


func change_rate(to: int) -> void:
	curr_rate = to


func game_over() -> void:
	curr_rate = 0
	set_physics_process(false)


func new_game() -> void:
	curr_rate = START_RATE
	percentage = 1.0
	target_percentage = percentage
	set_physics_process(true)


func pause() -> void:
	curr_rate = 0
	set_physics_process(false)


func unpause() -> void:
	curr_rate = START_RATE
	set_physics_process(true)
	update_rate()
