extends Node2D

@onready var white_accent: Sprite2D = $WhiteAccent
@onready var bg: Sprite2D = $BG
@onready var diminish_accent: Sprite2D = $DiminishAccent
@onready var diminish_variance: Sprite2D = $DiminishVariance
@onready var pink_variance: Sprite2D = $PinkVariance

const SPRITE_SIZE = Vector2(128,128)

func _ready() -> void:
	var white_accent_choices = [Vector2(4352,1152), Vector2(4352,896), Vector2(4736,1152), Vector2(4608,1152), Vector2(4480,1152), Vector2(4480,896), Vector2(4864,896)]
	var white_num = randi_range(0, 6)
	white_accent.region_rect = Rect2(white_accent_choices[white_num], SPRITE_SIZE)
	
	var diminish_accent_choices = [Vector2(0,5120), Vector2(128,5120)]
	var diminish_num = randi_range(0,1)
	diminish_accent.region_rect = Rect2(diminish_accent_choices[diminish_num], SPRITE_SIZE)
	
	var diminish_variance_choices = Vector2(5248,1024)
	var diminish_v_num = randi_range(0, 5)
	if diminish_v_num == 5:
		diminish_variance.region_rect = Rect2(Vector2(3840, 3072), SPRITE_SIZE)
	else:
		diminish_variance.region_rect = Rect2(diminish_variance_choices+ Vector2(128 * diminish_v_num, 0), SPRITE_SIZE)
	
	var pink_variance_choices = Vector2(5120,1664)
	var pink_v_num = randi_range(0, 6)
	pink_variance.region_rect = Rect2(pink_variance_choices+ Vector2(128 * pink_v_num, 0), SPRITE_SIZE)
