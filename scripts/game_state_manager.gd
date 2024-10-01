class_name GameStateManager
extends Node

@export var mines_grid: MinesGrid
@export var head_board: HeadBoard

@onready var timer: Timer = $Timer

var time_elapsed = 0

func _ready() -> void:
	mines_grid.game_lost.connect(_on_game_lost)
	mines_grid.game_won.connect(_on_game_won)
	mines_grid.flag_changed.connect(_on_flags_changed)
	timer.timeout.connect(_on_timer_timeout)
	head_board.set_flags_count(mines_grid.number_of_mines)
	head_board.set_timer_count(time_elapsed)

func _on_game_lost()-> void:
	timer.stop()
	head_board.game_lost()

func _on_game_won()-> void:
	timer.stop()
	head_board.game_won()

func _on_flags_changed(flags_count: int)-> void:
	head_board.set_flags_count(mines_grid.number_of_mines - flags_count)
	pass

func _on_timer_timeout() -> void:
	time_elapsed += 1
	head_board.set_timer_count(time_elapsed)
