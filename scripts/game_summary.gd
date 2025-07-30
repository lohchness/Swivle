class_name GameSummary
extends TwoStateSwitch

## This class is meant to be contained in its own GameOver scene,
## separate from the Game scene. It pulls stats from GlobalContext
## to display in the labels.

@onready var score: Label = $CenterContainer/GridContainer/Score
@onready var words: Label = $CenterContainer/GridContainer/Words


func _ready() -> void:
	super()
	score.text = str(Globals.score)
	#words.text = Globals.word
