class_name EndGame
extends Node2D

## Scene displaying gameover stats and replay controls.
## Background sprites are meant to be the same as other scenes,
## but this endgame scene assumes the relevant children
## are in their correct position at scene ready. This is
## meant to be the new convention from here on.

signal restart_game

@onready var gamesummary: GameSummary = $GameSummary
@onready var quit_key: QuitControlKey = $QuitControlKey
@onready var restart_key: RestartControlKey = $RestartControlKey


func _ready() -> void:
	quit_key.connect("quit_pressed", Callable(self, "playpress"))
	restart_key.connect("restart_pressed", Callable(self, "restartpress"))
	#switch_all()


func restartpress() -> void:
	restart_game.emit()
	#switch_all()


func switch_all() -> void:
	quit_key.switch_position()
	restart_key.switch_position()
	gamesummary.switch_position()


func bulk_move_off_screen() -> void:
	quit_key.move_off_screen()
	restart_key.move_off_screen()
	gamesummary.move_off_screen()


func bulk_move_on_screen() -> void:
	quit_key.move_on_screen()
	restart_key.move_on_screen()
	gamesummary.move_on_screen()
