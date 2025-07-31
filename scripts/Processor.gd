class_name Processor
extends Node2D

const NUM_KEYS: int = 6

var all: Array[String]
var threes: Array[String]
var fours: Array[String]
var fives: Array[String]
var sixes: Array[String]

var counted_words: Array[Dictionary]

var chosen_word: String = ""
var s: String = ""

@onready var filtered_words: String = "res://assets/filtered.txt"


func _ready() -> void:
	load_file()
	randomize()
	#var t: int = Time.get_ticks_msec()
	#s = get_new_string("ZZ")
	#print(s)
	#print(Time.get_ticks_msec() - t)
	## 220 ms with letter_combinations having duplicate combinations
	## eg combinations("ZZ") -> "Z", "Z", "ZZ"
	## 150 ms after making letter_combinations into a dictionary
	## 120 ms after removing .keys() from is_subdict()
	## When letters="Z" it cuts down to 60ms (only 1 iteration instead of 2)


func get_new_string(letters: String) -> String:
	assert(len(letters) <= 3)
	if len(letters) == 0:
		var s: String = sixes.pick_random()
		chosen_word = s
		return s

	## Find word that contains remaining letters

	## 120 ms
	var filters: Array[String] = filter_words_by_letters(letters)
	print(len(filters))

	## 0-1 ms
	var r: String = filters.pick_random()
	print(r)
	var chosen: String = string_difference(letters, r)

	if len(letters) + len(chosen) < 6:
		return chosen + pick_random_n(all.pick_random(), 6 - len(letters) + len(chosen))

	return chosen


## Filters all words for words that contain existing letters.
func filter_words_by_letters(letters: String) -> Array[String]:
	# Make list of letter combinations
	# Convert into list of letter combination dicts
	# Iterate through list of letter combination dicts as i
	# 	Iterate through counted words as j
	#		If i is (exact?) subdict of j
	#			Add full word to list if not added yet

	var filtered: Dictionary[String, int] = {}  # Ensure unique entries
	var combination_dict_list: Array[Dictionary] = []

	## 0-1 ms
	for i: int in range(len(letters)):
		for j: Array in combinations(letters, i + 1):
			combination_dict_list.append(count_letters("".join(j)))

	## 120 ms
	var t: int = Time.get_ticks_msec()
	print(len(combination_dict_list))
	for i: int in range(len(counted_words)):
		for j: Dictionary in combination_dict_list:
			if is_exact_subdict(counted_words[i], j):
				filtered[all[i]] = 0
	print(Time.get_ticks_msec() - t)

	return filtered.keys()


func is_exact_subdict(superset: Dictionary[String, int], subset: Dictionary[String, int]) -> bool:
	## <= operator               +10ms
	## removing superset.keys()  -40ms
	return subset.keys().all(
		func(x: String) -> bool: return x in superset and subset[x] == superset[x]
	)


func combinations(word: String, num: int) -> Array[Array]:
	if num == 0:
		return [[]]

	#var letter_combinations: Array[Array] = []
	var letter_combinations: Dictionary[Array, int] = {}
	for i: int in range(len(word)):
		var c: String = word[i]
		var rest: String = word.substr(i + 1)
		for more: Array[Array] in combinations(rest, num - 1):
			more.append_array([c])
			letter_combinations[more] = 0

	return letter_combinations.keys()


# TODO Update word choice algorithm
## @deprecated: Use new method
func get_next_string(letters: String) -> String:
	print("-----------------------")
	var remaining_letters: int = NUM_KEYS - len(letters)
	var chosen: String = ""
	var another: String = ""

	if len(letters) == 0:
		chosen = all.pick_random()
		print("Chosen (no letters): " + chosen)
	else:
		print(str(remaining_letters) + " letters remaining! Choosing a word.")
		var filtered: Array = all.filter(
			func(x: String) -> bool: return len(x) <= remaining_letters
		)
		if randi_range(0, 1):
			# Random word
			chosen = filtered.pick_random()
			print("Chosen Random Word (no shared): " + chosen)
		else:
			# Random word with at least one shared letter.
			var filtered_more: Array[String] = filtered.filter(
				func(x: String) -> bool: return any(letters, x)
			)
			var word: String = filtered_more.pick_random()
			print("Chosen Random Word (shared letter): " + word)
			chosen = string_difference(letters, word)
			print("Chosen Word After Diff: " + chosen)

	var rest: int = remaining_letters - len(chosen)
	var rest_str: String = ""
	if rest > 0:  # Still letters remaining
		print(str(rest) + " letters remaining!.")
		another = all.pick_random()
		print("Picked: " + another)

		rest_str = pick_random_n(another, rest)
		print(": " + rest_str)

	print(letters + " + " + chosen + " + " + rest_str)

	# For game summary
	chosen_word = chosen

	chosen = shuffle_string(chosen)
	print_debug(letters + chosen + rest_str)
	assert(len(letters + chosen + rest_str) == NUM_KEYS)

	return chosen + rest_str


func load_file() -> void:
	var f: FileAccess = FileAccess.open(filtered_words, FileAccess.READ)
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		all.append(line)
		counted_words.append(count_letters(line))
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


## Returns true if at least one letter in letters
## occurs in word.
func any(letters: String, word: String) -> bool:
	for i: String in letters:
		if i in word:
			return true
	return false


## Returns the difference between current and to_add.
## If current was "H" and to_add was "KHETH", this would return
## "KETH".
func string_difference(current: String, to_add: String) -> String:
	var remainder: String = ""

	var letters_count: Dictionary[String, int] = count_letters(current)

	for letter: String in to_add:
		if letter not in letters_count:
			remainder += letter
		else:
			if letters_count[letter] > 0:
				letters_count[letter] -= 1
			else:
				remainder += letter

	return remainder


func pick_random_n(word: String, n: int) -> String:
	var newstr: String = ""
	for i: int in range(n):
		newstr += word[randi_range(0, len(word) - 1)]
	return newstr


func shuffle_string(s: String) -> String:
	var a: Array[String] = []
	for c: String in s:
		a.append(c)
	a.shuffle()
	return "".join(a)


func count_letters(s: String) -> Dictionary[String, int]:
	var counts: Dictionary[String, int]
	for c: String in s:
		counts[c] = counts.get(c, 0) + 1
	return counts
