extends Node2D

var keys : Array[Key]
const key = preload("res://scenes/key.tscn")
@onready var winsize = get_viewport().size
var x_offset = 25

signal key_selected(index: int)
signal check_words(word : String)
signal pivoted

var selected_keys = []

const NUM_KEYS = 6

func _ready():
	# Initialize 6 Keys in Hand
	for i in range(NUM_KEYS):
		var newkey = key.instantiate()
		add_child(newkey)
		keys.append(newkey)
		# Update hand position (look below)
		newkey.set_base_position(Vector2(x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2))
		newkey.set_letter(str(i))
		newkey.set_number(i)
		newkey.select_signal.connect(Callable(self, "key_select_signal"))
		newkey.deselect_signal.connect(Callable(self, "key_deselect_signal"))


func _process(delta):	
	if Input.is_action_just_pressed("Pivot"):
		if can_pivot(selected_keys):
			pivot(selected_keys[0], selected_keys[1])
	if Input.is_action_just_pressed("Submit"):
		selected_keys.sort()
		if can_submit(selected_keys):
			var str = get_hand_string(selected_keys.min(), selected_keys.max())
			print("Submitting " + str)
			check_words.emit(str)
	if Input.is_action_just_pressed("Release"):
		for i in keys:
			i.deselect()
	
	pass


# Remove selected keys from game and generate new ones at the tail.
func valid_word():
	print("Valid word!")

	## Update Key array
	var tmpkeys : Array[Key] = []
	for i in range(len(keys)): 
		if i not in selected_keys:
			tmpkeys.append(keys[i])
			print("Adding number " + str(i) + "to new keys array" )
	
	print("Selected keys:")
	print(selected_keys)
	
	#print(selected_keys)
	for i in selected_keys:
		keys[i].disappear()
	#
	keys = tmpkeys
	update_hand_numbers()
	update_hand_positions()
	print("Length of new keys array: " + str(len(keys)))

	selected_keys = []

func append_letters(letters : String):
	for i in letters:
		var newkey = key.instantiate()
		add_child(newkey)
		keys.append(newkey)
		newkey.position = Vector2(x_offset + winsize.x, winsize.y / 2)
		newkey.set_letter(str(i))
		#newkey.set_number(i)
		newkey.select_signal.connect(Callable(self, "key_select_signal"))
		newkey.deselect_signal.connect(Callable(self, "key_deselect_signal"))
	update_hand_numbers()
	update_hand_positions()

# Invalid word
func invalid_word():
	print("Invalid word! Try again")
	for i in selected_keys:
		keys[i].wiggle()

func key_select_signal(number : int):
	#print("Selected number " + str(number))
	selected_keys.append(number)
	pass

func key_deselect_signal(number : int):
	#print("Deselected number " + str(number))
	selected_keys.erase(number)
	pass

func set_hand_string(word : String):
	for i in range(len(word)):
		keys[i].set_letter(word[i])

func get_hand_string_all() -> String:
	var str = ""
	for i in keys:
		str += i.get_letter()
	return str

func get_hand_string(from : int, to : int) -> String:
	var str = ""
	for i in range(from, to + 1):
		str += keys[i].get_letter()
	return str

func pivot(start : int, end : int): # Indexes of keys. Start < End. Is 0-indexed.
	pivoted.emit()
	var tmp1 = max(start, end)
	var tmp2 = min(start, end)
	start = tmp2
	end = tmp1
	#print("Pivoting " + str(start) + " to " + str(end))
	#print("Keys has length " + str(len(keys)))
	assert(len(keys) > end)
	
	# Basic swap
	while (end - start > 0):
		var tmp = keys[start]
		keys[start] = keys[end]
		keys[end] = tmp
		start += 1
		end -= 1
	update_hand_positions()
	update_hand_numbers()

func update_hand_positions():
	for i in range(len(keys)):
		#print(i)
		keys[i].set_base_position(Vector2(x_offset + (i * winsize.x / NUM_KEYS), winsize.y / 2))

func update_hand_numbers():
	for i in range(len(keys)):
		keys[i].number = i

func is_consecutive(selected_keys):
	for i in range(len(selected_keys) - 1):
		if selected_keys[i + 1] - selected_keys[i] != 1:
			return false
	return true

func can_submit(selected_keys) -> bool:
	return len(selected_keys) > 2 and is_consecutive(selected_keys)

func can_pivot(selected_keys):
	return len(selected_keys) == 2
