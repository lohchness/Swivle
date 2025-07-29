class_name Hand
extends TwoStateSwitch

signal key_selected(index: int)
signal check_words(word: String, score: int)
signal pivoted

const NUM_KEYS: int = 6

var keys: Array[Key]
var selected_keys: Array[int] = []

var x_offset: int = 25  # Initial position
var base_position: Vector2
var off_screen: Vector2  # Offset when game is over

@onready var winsize: Vector2 = get_viewport().size
@onready var key_scene: PackedScene = preload("res://scenes/key.tscn")


func _ready() -> void:
	super()
	# Initialize 6 Keys in Hand
	for i: int in range(NUM_KEYS):
		var newkey: Key = key_scene.instantiate()
		add_child(newkey)
		keys.append(newkey)

		# Update hand position (look below)
		var initial_position: Vector2 = Vector2(
			x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2
		)
		newkey.set_base_position(initial_position)
		newkey.position = initial_position  # Initialize position at game start

		newkey.set_letter(str(i))
		newkey.set_number(i)
		newkey.select_signal.connect(Callable(self, "key_select_signal"))
		newkey.deselect_signal.connect(Callable(self, "key_deselect_signal"))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pivot"):
		if can_pivot(selected_keys):
			pivot(selected_keys[0], selected_keys[1])

	if event.is_action_pressed("Submit"):
		selected_keys.sort()
		if can_submit(selected_keys):
			var str: String = get_hand_string(selected_keys.min(), selected_keys.max())
			var score: int = get_score()
			check_words.emit(str, score)

	if event.is_action_pressed("Release"):
		for i: Key in keys:
			i.deselect()

	if event.is_action_pressed("ONE"):
		keys[0].on_click()
	if event.is_action_pressed("TWO"):
		keys[1].on_click()
	if event.is_action_pressed("THREE"):
		keys[2].on_click()
	if event.is_action_pressed("FOUR"):
		keys[3].on_click()
	if event.is_action_pressed("FIVE"):
		keys[4].on_click()
	if event.is_action_pressed("SIX"):
		keys[5].on_click()


# Remove selected keys from game and generate new ones at the tail.
func valid_word() -> void:
	# Update Key array
	var tmpkeys: Array[Key] = []
	for i: int in range(len(keys)):
		if i not in selected_keys:
			tmpkeys.append(keys[i])

	for i: int in selected_keys:
		keys[i].disappear()

	keys = tmpkeys
	update_hand_numbers()
	update_hand_positions()

	selected_keys = []


func append_letters(letters: String) -> void:
	for i: String in letters:
		var newkey: Key = key_scene.instantiate()
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
	for i: int in selected_keys:
		keys[i].wiggle()


func key_select_signal(number: int) -> void:
	selected_keys.append(number)


func key_deselect_signal(number: int) -> void:
	selected_keys.erase(number)


func deselect_all() -> void:
	for i: Key in keys:
		i.deselect()


func set_hand_string(word: String) -> void:
	for i: int in range(len(word)):
		keys[i].set_letter(word[i])


func get_hand_string_all() -> String:
	var str: String = ""
	for i: Key in keys:
		str += i.get_letter()
	return str


func get_hand_string(from: int, to: int) -> String:
	var str: String = ""
	for i: int in range(from, to + 1):
		str += keys[i].get_letter()
	return str


func pivot(start: int, end: int) -> void:  # Indexes of keys. Start < End. Is 0-indexed.
	pivoted.emit()
	var tmp1: int = max(start, end)
	var tmp2: int = min(start, end)
	start = tmp2
	end = tmp1
	assert(len(keys) > end)

	while end - start > 0:
		var tmp: Key = keys[start]
		keys[start] = keys[end]
		keys[end] = tmp
		start += 1
		end -= 1

	update_hand_positions()
	update_hand_numbers()


func update_hand_positions() -> void:
	for i: int in range(len(keys)):
		keys[i].number = i
		keys[i].set_base_position(Vector2(x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2))


func update_hand_numbers() -> void:
	pass
	#for i in range(len(keys)):
	#keys[i].number = i


func is_consecutive(selected_keys: Array[int]) -> bool:
	for i: int in range(len(selected_keys) - 1):
		if selected_keys[i + 1] - selected_keys[i] != 1:
			return false
	return true


func can_submit(selected_keys: Array[int]) -> bool:
	return len(selected_keys) > 2 and is_consecutive(selected_keys)


func can_pivot(selected_keys: Array[int]) -> bool:
	return len(selected_keys) == 2


func get_score() -> int:
	var sum: int = 0
	for i: int in selected_keys:
		sum += keys[i].get_score()
	return sum
