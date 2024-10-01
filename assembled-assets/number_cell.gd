class_name NumberCell
extends Node2D

@export var number: int

@onready var number_sprite: Sprite2D = $NumberSprite
@onready var dot_sprite: Sprite2D = $DotSprite

const SPRITE_SIZE = Vector2(128,128)

func _ready() -> void:
	new_cell(number)

func new_cell(num: int) -> void:
	var num_cells = [
		Vector2(1408, 512),
		Vector2(1536, 512),
		Vector2(1664, 512),
		Vector2(1792, 512),
		Vector2(1920, 512),
		Vector2(0, 640),
		Vector2(128, 640),
		Vector2(256, 640)
	]
	
	var color_cells = [
		Vector2(1920, 5248),
		Vector2(1920, 4736),
		Vector2(1920, 4992),
		Vector2(1920, 5376),
		Vector2(1920, 4608),
		Vector2(1920, 4480),
		Vector2(1920, 4352),
		Vector2(1920, 4224),
	]
	
	dot_sprite.region_rect = Rect2(color_cells[num-1], SPRITE_SIZE)
	number_sprite.region_rect = Rect2(num_cells[num-1], SPRITE_SIZE)
	
