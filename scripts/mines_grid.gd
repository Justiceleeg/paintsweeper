class_name MinesGrid
extends Node2D

signal flag_changed(number_of_flags)
signal game_lost
signal game_won

@onready var vertical_lines_layer: TileMapLayer = $VerticalLinesLayer
@onready var horizontal_lines_layer: TileMapLayer = $HorizontalLinesLayer
# mines, empty cell decoration, numbers, default cells
@onready var cells: TileMapLayer = $Cells
# flags
@onready var top_layer: TileMapLayer = $TopLayer

@export var columns := 11
@export var rows := 11

@export var number_of_mines := 15

var cells_with_mines: Dictionary = {}
var cells_with_flags: Dictionary = {}
var uncleared_cells: Dictionary = {}
var is_first_move = true
var is_game_finished = false

func _ready() -> void:
	clear()
	
	init_cells()

	place_mines()

func clear() -> void:
	vertical_lines_layer.clear()
	horizontal_lines_layer.clear()
	cells.clear()

func init_cells() -> void:
	for r in rows:
		for c in columns:
			var cell_coord = Vector2i(r , c)
			_set_default_cell(cell_coord)
			uncleared_cells[str(cell_coord)] = true
	
	init_shadows()

func init_shadows() -> void:
	inner_shadows()
	# top row
	for c in columns:
		lighten_top(Vector2i(c,0))
		darken_top(Vector2i(c,columns))
	
	for r in rows:
		lighten_side(Vector2i(0,r))
		darken_side(Vector2i(rows,r))
		
func inner_shadows() -> void:
	for r in rows:
		for c in columns:
			var cell = Vector2i(r , c)
			var rand_num1 = randi_range(1,4)
			var rand_num2 = randi_range(1,4)
			horizontal_lines_layer.set_cell(cell, 1, Vector2i(11, 34 if rand_num1 == 1 else 35))
			vertical_lines_layer.set_cell(cell, 1, Vector2i(10, 34 if rand_num2 == 1 else 35))

func lighten_top(cell: Vector2i) -> void:
	var rand_num = randi_range(1,4)
	horizontal_lines_layer.set_cell(cell, 1, Vector2i(11, 46 if rand_num == 1 else 47))

func lighten_side(cell: Vector2i) -> void:
	var rand_num = randi_range(1,4)
	vertical_lines_layer.set_cell(cell, 1, Vector2i(10, 46 if rand_num == 1 else 47))

func darken_top(cell: Vector2i) -> void:
	var rand_num = randi_range(1,3)
	horizontal_lines_layer.set_cell(cell, 1, Vector2i(11, 33 if rand_num == 1 else 32))

func darken_side(cell: Vector2i) -> void:
	var rand_num = randi_range(1,3)
	vertical_lines_layer.set_cell(cell, 1, Vector2i(10, 33 if rand_num == 1 else 32))

func adjust_shadows(cell: Vector2i) -> void:
	var right_cell_source = cells.get_cell_source_id(cell+Vector2i(1,0))
	var left_cell_source = cells.get_cell_source_id(cell+Vector2i(-1,0))
	var top_cell_source = cells.get_cell_source_id(cell+Vector2i(0,-1))
	var bottom_cell_source = cells.get_cell_source_id(cell+Vector2i(0,1))
	
	#var is_default_cell = cell_source == 0
	
	if right_cell_source == 0:
		lighten_side(cell+Vector2i(1,0))
	else:
		vertical_lines_layer.erase_cell(cell+Vector2i(1,0))
	
	if left_cell_source == 0:
		darken_side(cell)
	else:
		vertical_lines_layer.erase_cell(cell)
		
	if bottom_cell_source == 0:
		lighten_top(cell+Vector2i(0, 1))
	else:
		horizontal_lines_layer.erase_cell(cell+Vector2i(0,1))
	
	if top_cell_source == 0:
		darken_top(cell)
	else:
		horizontal_lines_layer.erase_cell(cell)
	

func place_mines() -> void:
	for mine in number_of_mines:
		place_unique_mine()

func place_unique_mine() -> void:
	var cell_coord = Vector2i(randi_range(0, rows - 1),randi_range(0, columns - 1))
		
	while cells_with_mines.has(str(cell_coord)):
		cell_coord = Vector2i(randi_range(0, rows - 1),randi_range(0, columns - 1))
	
	cells_with_mines[str(cell_coord)] = true

func _input(event: InputEvent) -> void:
	if is_game_finished:
		return
	
	if event is not InputEventMouseButton || !event.pressed:
		return
	
	var clicked_cell_coord = top_layer.local_to_map(get_local_mouse_position())
	
	if event.button_index == 1:
		on_cell_clicked(clicked_cell_coord)
	elif event.button_index == 2:
		place_flag(clicked_cell_coord)

func on_cell_clicked(cell_coord: Vector2i) -> void:
	if cells_with_mines.has(str(cell_coord)):
		# make the first click safe
		if is_first_move:
			cells_with_mines.erase(str(cell_coord))
			place_unique_mine()
			handle_cells(cell_coord)
			return
		lose(cell_coord)
		return

	handle_cells(cell_coord)

func handle_cells(cell_coord: Vector2i, cells_checked_recursively: Array[Vector2i] = []) -> void:
	#var tile_data = cells.get_cell_tile_data(cell_coord)
	var cell_atlas_coord = cells.get_cell_atlas_coords(cell_coord)
	
	#if tile_data == null:
		#return
	
	# don't handle cells that have been handled
	if !(cell_atlas_coord == Vector2i.ZERO):
		return
	
	# don't handle cells that are mines
	var cell_has_mine = cells_with_mines.has(str(cell_coord));
	if cell_has_mine:
		return
	
	var mine_count = get_surrounding_cells_mine_count(cell_coord)
	
	if mine_count == 0:
		_set_clear_cell(cell_coord)
		var surrounding_cells = _get_all_surrounding_cells(cell_coord)
		for cell in surrounding_cells:
			handle_surrounding_cell(cell, cells_checked_recursively)
	else:
		_set_mine_number_cell(cell_coord, mine_count)
	
	recover_flag(cell_coord)
	
	uncleared_cells.erase(str(cell_coord))
	adjust_shadows(cell_coord)
	
	is_first_move = false
	
	if uncleared_cells.keys().size() == number_of_mines:
		win()

func handle_surrounding_cell(cell_coord: Vector2i, cells_checked_recursively: Array[Vector2i]):
	if cells_checked_recursively.has(cell_coord):
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord, cells_checked_recursively)

func get_surrounding_cells_mine_count(cell_coord: Vector2i) -> int:
	var mine_count := 0
	var surrounding_cells = _get_all_surrounding_cells(cell_coord)
	for cell in surrounding_cells:
		var cell_atlas_coord = cells.get_cell_atlas_coords(cell_coord)
		if cell_atlas_coord == Vector2i.ZERO and cells_with_mines.has(str(cell)):
			mine_count += 1
	
	return mine_count
	

func lose(cell_coord: Vector2i) -> void:
	game_lost.emit()
	is_game_finished = true
	
	for cell in cells_with_mines:
		if !cells_with_flags.has(str(cell)):
			_set_mine_cell(_str_to_vector2i(cell))
	
	for cell in cells_with_flags:
		if !cells_with_mines.has(str(cell)):
			_set_flag_cell(_str_to_vector2i(cell), true)

	_set_mine_cell(cell_coord, true)

func place_flag(cell_coord: Vector2i) -> void:
	var cell_source = cells.get_cell_source_id(cell_coord)
	var flag_source = top_layer.get_cell_source_id(cell_coord)

	var is_default_cell = cell_source == 0
	var is_flag_cell = flag_source == 1
	
	if is_default_cell and not is_flag_cell and cells_with_flags.keys().size() < number_of_mines:
		_set_flag_cell(cell_coord)
		cells_with_flags[str(cell_coord)] = true
		flag_changed.emit(cells_with_flags.keys().size())
	
	if is_flag_cell:
		_set_default_cell(cell_coord)
		cells_with_flags.erase(str(cell_coord))
		top_layer.erase_cell(cell_coord)
		flag_changed.emit(cells_with_flags.keys().size())

func recover_flag(cell_coord:Vector2i) -> void:
	if cells_with_flags.has(str(cell_coord)):
		cells_with_flags.erase(str(cell_coord))
		top_layer.erase_cell(cell_coord)
		flag_changed.emit(cells_with_flags.keys().size())
		
func win():
	is_game_finished = true
	game_won.emit()

#func vector2i_to_str(vec: Vector2i) -> String:
	#return str(vec).replace(" ", "")
#
func _str_to_vector2i(str: String) -> Vector2i:
	var split_str = str.split(", ")
	return Vector2i(int(split_str[0]), int(split_str[1]))

func _get_all_surrounding_cells(cell_coord: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for x in range(cell_coord.x - 1, cell_coord.x + 2):
		for y in range(cell_coord.y - 1, cell_coord.y + 2):
			if x == cell_coord.x and y == cell_coord.y:
				continue
			if x not in range(0, rows) or y not in range(0, columns):
				continue
			result.append(Vector2i(x,y))
	return result

func _set_flag_cell(cell_coord:Vector2i, is_wrong: bool = false) -> void:
	top_layer.set_cell(cell_coord, 1, Vector2.ZERO, 2 if is_wrong else 1)

func _set_mine_cell(cell_coord:Vector2i, is_red: bool = false) -> void:
	top_layer.set_cell(cell_coord, 0, Vector2.ZERO, 2 if is_red else 1)

func _set_mine_number_cell(cell_coord:Vector2i, mine_number: int) -> void:
	cells.set_cell(cell_coord, 3, Vector2.ZERO, mine_number)

func _set_default_cell(cell_coord:Vector2i) -> void:
	cells.set_cell(cell_coord,0, Vector2.ZERO, 1)
	
func _set_clear_cell(cell_coord:Vector2i) -> void:
	cells.set_cell(cell_coord, 2, Vector2i(randi_range(36,39), 0))
	
	var flag_cell_data = top_layer.get_cell_tile_data(cell_coord)
	if flag_cell_data:
		top_layer.erase_cell(cell_coord)
