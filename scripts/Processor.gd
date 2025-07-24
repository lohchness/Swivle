class_name Processor
extends Node2D

const NUM_KEYS = 6

var all : Array[String]
var threes : Array[String]
var fours : Array[String]
var fives : Array[String]
var sixes : Array[String]

@onready var filtered_words = "res://assets/filtered.txt"

func _ready():
	load_file()
	randomize()

func load_file():
	var f: FileAccess = FileAccess.open(filtered_words, FileAccess.READ)
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		all.append(line)
		match len(line):
			3:
				threes.append(line)
			4:
				fours.append(line)
			5:
				fives.append(line)
			6:
				sixes.append(line)
	f.close()

func get_next_string(letters):
	print("-----------------------")
	var remaining_letters: int = NUM_KEYS - len(letters)
	var chosen: String = ""
	var another: String = ""

	if len(letters) == 0:
		chosen = all.pick_random()
		print("Chosen (no letters): " + chosen)
	else:
		print(str(remaining_letters) + " letters remaining! Choosing a word.")
		var filtered: Array[String] = all.filter(func(x): return len(x) <= remaining_letters)
		if randi_range(0, 1):
			# Random word
			chosen = filtered.pick_random()
			print("Chosen Random Word (no shared): " + chosen)
		else:
			# Random word with at least one shared letter.
			var filtered_more = filtered.filter(func(x): return any(letters, x))
			var word = filtered_more.pick_random()
			print("Chosen Random Word (shared letter): " + word)
			chosen = string_difference(letters, word)
			print("Chosen Word After Diff: " + chosen)


	var rest: int = remaining_letters - len(chosen)
	var rest_str: String = ""
	if rest > 0: # Still letters remaining
		print(str(rest) + " letters remaining!.")
		another = all.pick_random()
		print("Picked: " + another)

		rest_str = pick_random_n(another, rest)
		print(": " + rest_str)

	print(letters + " + " + chosen + " + " + rest_str)

	chosen = shuffle_string(chosen)
	print_debug(letters + chosen + rest_str)
	assert(len(letters + chosen + rest_str) == NUM_KEYS)

	return chosen + rest_str

func any(letters : String, word : String):
	for i in letters:
		if i in word:
			return true
	return false

func string_difference(word1 : String, word2 : String) -> String:
	# TODO : There may be more than one occurence, change it so that it only does it N times
	var newstr: String = ""
	for i in word2:
		if i not in word1:
			newstr += i
		else:
			pass
	return newstr

func pick_random_n(word : String, n : int):
	var newstr: String = ""
	for i in range(n):
		newstr += word[randi_range(0, len(word) - 1)]
	return newstr

func shuffle_string(s):
	var a: Array[String] = []
	for c in s: a.append(c)
	a.shuffle()
	return "".join(a)
