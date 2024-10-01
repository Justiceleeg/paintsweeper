extends CanvasLayer

@export var empty_cursor: Texture = null

@export var base_window_size = Vector2.ZERO
@export var base_cursor_size = Vector2.ZERO

@onready var cursor: Node2D = $Cursor

func _ready() -> void:
	_update_cursor()
	Input.set_custom_mouse_cursor(empty_cursor, Input.CURSOR_ARROW)
	get_viewport().size_changed.connect(_update_cursor)

 
func _process(delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()
	
func _update_cursor() -> void:
	var current_window_size = get_viewport().get_visible_rect().size
	var scale_multiple = min(floor(current_window_size.x / base_window_size.x), floor(current_window_size.y / base_window_size.y))
