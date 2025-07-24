class_name Hand
extends Node2D

signal key_selected(index: int)
signal check_words(word: String, score: int)
signal pivoted

const NUM_KEYS: int = 6

var keys: Array[Key]
var selected_keys: Array[int] = []

var x_offset = 25 # Initial position
var base_position: Vector2
var off_screen: Vector2 # Offset when game is over

@onready var winsize = get_viewport().size
@onready var key_scene = preload("res://scenes/key.tscn")

func _ready() -> void:
	# Initialize 6 Keys in Hand
	for i in range(NUM_KEYS):
		var newkey = key_scene.instantiate()
		add_child(newkey)
		keys.append(newkey)
		# Update hand position (look below)
		newkey.set_base_position(Vector2(x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2))
		newkey.set_letter(str(i))
		newkey.set_number(i)
		newkey.select_signal.connect(Callable(self, "key_select_signal"))
		newkey.deselect_signal.connect(Callable(self, "key_deselect_signal"))

	base_position = position
	off_screen = base_position


func _process(delta) -> void:
	if Input.is_action_just_pressed("Pivot"):
		if can_pivot(selected_keys):
			pivot(selected_keys[0], selected_keys[1])

	if Input.is_action_just_pressed("Submit"):
		selected_keys.sort()
		if can_submit(selected_keys):
			var str = get_hand_string(selected_keys.min(), selected_keys.max())
			var score = get_score()
			check_words.emit(str, score)

	if Input.is_action_just_pressed("Release"):
		for i in keys:
			i.deselect()

	if Input.is_action_just_pressed("ONE"):
		keys[0].on_click()
	if Input.is_action_just_pressed("TWO"):
		keys[1].on_click()
	if Input.is_action_just_pressed("THREE"):
		keys[2].on_click()
	if Input.is_action_just_pressed("FOUR"):
		keys[3].on_click()
	if Input.is_action_just_pressed("FIVE"):
		keys[4].on_click()
	if Input.is_action_just_pressed("SIX"):
		keys[5].on_click()

	position = lerp(position, off_screen, 20 * delta)

# Remove selected keys from game and generate new ones at the tail.
func valid_word() -> void:
	# Update Key array
	var tmpkeys: Array[Key] = []
	for i in range(len(keys)):
		if i not in selected_keys:
			tmpkeys.append(keys[i])

	for i in selected_keys:
		keys[i].disappear()

	keys = tmpkeys
	update_hand_numbers()
	update_hand_positions()

	selected_keys = []

func append_letters(letters : String) -> void:
	for i in letters:
		var newkey = key_scene.instantiate()
		add_child(newkey)
		keys.append(newkey)
		newkey.position = Vector2(x_offset + winsize.x, winsize.y / 2)
		newkey.set_letter(str(i))
		newkey.select_signal.connect(Callable(self, "key_select_signal"))
		newkey.deselect_signal.connect(Callable(self, "key_deselect_signal"))

	update_hand_numbers()
	update_hand_positions()

# Invalid word
func invalid_word() -> void:
	for i in selected_keys:
		keys[i].wiggle()

func key_select_signal(number: int) -> void:
	selected_keys.append(number)

func key_deselect_signal(number: int) -> void:
	selected_keys.erase(number)

func deselect_all() -> void:
	for i in keys:
		i.deselect()

func set_hand_string(word: String) -> void:
	for i in range(len(word)):
		keys[i].set_letter(word[i])

func get_hand_string_all() -> String:
	var str = ""
	for i in keys:
		str += i.get_letter()
	return str

func get_hand_string(from: int, to: int) -> String:
	var str = ""
	for i in range(from, to + 1):
		str += keys[i].get_letter()
	return str

func pivot(start: int, end: int) -> void: # Indexes of keys. Start < End. Is 0-indexed.
	pivoted.emit()
	var tmp1 = max(start, end)
	var tmp2 = min(start, end)
	start = tmp2
	end = tmp1
	assert(len(keys) > end)

	while (end - start > 0):
		var tmp = keys[start]
		keys[start] = keys[end]
		keys[end] = tmp
		start += 1
		end -= 1

	update_hand_positions()
	update_hand_numbers()

func update_hand_positions() -> void:
	for i in range(len(keys)):
		keys[i].number = i
		keys[i].set_base_position(Vector2(x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2))

func update_hand_numbers() -> void:
	pass
	#for i in range(len(keys)):
		#keys[i].number = i

func is_consecutive(selected_keys) -> bool:
	for i in range(len(selected_keys) - 1):
		if selected_keys[i + 1] - selected_keys[i] != 1:
			return false
	return true

func can_submit(selected_keys) -> bool:
	return len(selected_keys) > 2 and is_consecutive(selected_keys)

func can_pivot(selected_keys) -> bool:
	return len(selected_keys) == 2

func get_score() -> int:
	var sum = 0
	for i in selected_keys:
		sum += keys[i].get_score()
	return sum

func game_over() -> void:
	#set_process(false)
	off_screen = base_position - Vector2(0, 500)

	#for key in keys:
		#key.set_physics_process(false)

func new_game() -> void:
	off_screen = base_position
