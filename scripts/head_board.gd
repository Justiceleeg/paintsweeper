class_name HeadBoard
extends Node2D

@onready var face_button: Button = %FaceButton
@onready var time_text_layer: TileMapLayer = $TimeTextLayer
@onready var flag_count_text_layer: TileMapLayer = $FlagCountTextLayer
@onready var face_button_layer: TileMapLayer = $FaceButtonLayer

const NUMERIC_CELLS = {
	"0": Vector2i(10,1),
	"1": Vector2i(11,1),
	"2": Vector2i(12,1),
	"3": Vector2i(13,1),
	"4": Vector2i(14,1),
	"5": Vector2i(15,1),
	"6": Vector2i(0,2),
	"7": Vector2i(1,2),
	"8": Vector2i(2,2),
	"9": Vector2i(3,2),
}

func _ready() -> void:
	face_button.pressed.connect(_on_game_status_button_pressed)
	face_button.button_down.connect(_on_game_status_button_pressed_down)

func set_timer_count(timer_count:int) -> void:
	var timer_string = str(timer_count)
	if timer_string.length() < 3:
		timer_string = timer_string.lpad(3,"0")
	
	time_text_layer.set_cell(Vector2i.ZERO,0,NUMERIC_CELLS[timer_string[0]])
	time_text_layer.set_cell(Vector2i(1,0),0,NUMERIC_CELLS[timer_string[1]])
	time_text_layer.set_cell(Vector2i(2,0),0,NUMERIC_CELLS[timer_string[2]])

func set_flags_count(mines_count: int) -> void:
	var flags_count_string = str(mines_count)
	if flags_count_string.length() < 3:
		flags_count_string = flags_count_string.lpad(3,"0")
	
	flag_count_text_layer.set_cell(Vector2i.ZERO,0,NUMERIC_CELLS[flags_count_string[0]])
	flag_count_text_layer.set_cell(Vector2i(1,0),0,NUMERIC_CELLS[flags_count_string[1]])
	flag_count_text_layer.set_cell(Vector2i(2,0),0,NUMERIC_CELLS[flags_count_string[2]])

func game_lost() -> void:
	face_button_layer.set_cell(Vector2i.ZERO, 0, Vector2i.ZERO, 1)

func game_won() -> void:
	face_button_layer.set_cell(Vector2i.ZERO, 0, Vector2i.ZERO, 4)

func _on_game_status_button_pressed_down() -> void:
	face_button_layer.set_cell(Vector2i.ZERO, 0, Vector2i.ZERO, 3)

func _on_game_status_button_pressed() -> void:
	get_tree().reload_current_scene()


#const FACE_CELLS = {
	#"lose_face": Vector2i(10,1),
	#"neutral_face": Vector2i(11,1),
	#"neutral_face_pressed": Vector2i(12,1),
	#"win_face": Vector2i(13,1),
#}
