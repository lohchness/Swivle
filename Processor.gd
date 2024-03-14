extends Node2D

@onready var filtered_words = "res://assets/filtered.txt"
var all : Array
var threes : Array
var fours : Array
var fives : Array
var sixes : Array

func _ready():
	load_file()
	randomize()

func load_file():
	var f = FileAccess.open(filtered_words, FileAccess.READ)
	var count = 0
	while not f.eof_reached():
		var line = f.get_line().strip_edges()
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
	#print_debug(len(threes))
	#print_debug(len(fours))
	#print_debug(len(fives))
	#print_debug(len(sixes))

func get_next_string(letters):
	print("-----------------------")
	var remaining_letters = 6 - len(letters)
	var chosen : String = ""
	var another : String = ""
	
	if len(letters) == 0:
		chosen = all.pick_random()
		print("Chosen (no letters): " + chosen)
	else:
		print(str(remaining_letters) + " letters remaining! Choosing a word.")
		var filtered = all.filter(func(x): return len(x) <= remaining_letters)
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
			
	
	var rest = remaining_letters - len(chosen)
	var rest_str = ""
	if rest > 0: # Still letters remaining
		print(str(rest) + " letters remaining! Choosing another word.")
		another = all.pick_random()
		rest_str = pick_random_n(another, rest)
		print("Another: " + another)
		print("Randomized letters chosen from Another: " + rest_str)
	
	print(letters + " + " + chosen + " + " + rest_str)
	
	chosen = shuffle_string(chosen)
	print_debug(letters + chosen + rest_str)
	assert(len(letters + chosen + rest_str) == 6)
	
	return chosen + rest_str
	
	#return letters + chosen + rest_str 

func any(letters : String, word : String):
	for i in letters:
		if i in word:
			return true
	return false

func string_difference(word1 : String, word2 : String) -> String:
	# TODO : There may be more than one occurence, change it so that it only does it N times
	var newstr = ""
	for i in word2:
		if i not in word1:
			newstr += i
		else:
			pass
	return newstr
	
func pick_random_n(word : String, n : int):
	var newstr = ""
	for i in range(n):
		newstr += word[randi_range(0, len(word) - 1)]
	return newstr

func shuffle_string(s):
	var a = []
	for c in s: a.append(c)
	a.shuffle()
	return "".join(a)
