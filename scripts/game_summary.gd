class_name GameSummary
extends GridContainer

## This class is meant to be contained in its own GameOver scene,
## separate from the Game scene. It pulls stats from GlobalContext
## to display in the labels.

@onready var score: Label = $Score
@onready var word: Label = $Word


func _ready() -> void:
	score.text = str(Globals.score)
	word.text = Globals.word
