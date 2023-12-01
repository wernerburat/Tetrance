extends TileMap

var shapes: Array = Tetromino.shapes
var shapes_full := shapes.duplicate()

#UI vars
@onready var gameover_label : Label = $HUD/GameOverLabel
@onready var paused_label : Label = $HUD/PausedLabel
@onready var score_label : Label = $HUD/ScoreLabel
@onready var lines_label : Label = $HUD/LinesLabel
@onready var level_label : Label = $HUD/LevelLabel
@onready var start_btn : Button = $HUD/StartButton

#grid vars
const COLS : int = 10
const ROWS : int = 20

#movement vars
var cur_pos : Vector2i
var steps : Array
var speed : float
const start_pos := Vector2i(5, -2)
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const steps_req : int = 50
const ACCEL : float = 0.25
var is_soft_dropping : bool = false

#das vars
var das_started : bool = false
var das_moving : bool = false
var das_steps_req : int = 20

#game piece vars
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array

#game vars
var level : int = 1
var score : int
var lines : int = 0
const REWARD : int = 100
var game_running : bool

#tilemap vars
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

#layer vars
var board_layer : int = 0
var active_layer : int = 1
var board_top_layer : int = 2
var ghost_layer : int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	start_btn.pressed.connect(new_game)
	
func new_game():
	#reset vars
	das_started = false
	das_moving = false

	score = 0
	lines = 0
	level = 1
	update_score()
	update_level()
	update_lines()

	speed = 1.0
	game_running = true
	steps = [0, 0, 0] #0: left, 1:right, 2:down
	gameover_label.hide()
	paused_label.hide()
	clear_piece()
	clear_board()
	clear_panel()
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	create_piece()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_inputs()
	if game_running:
		#apply downward movement every frame
		steps[2] += speed
		#move the piece
		update_piece()
		update_ghost()

func update_piece():
	for i in range(steps.size()):
		if steps[i] >= steps_req:
			move_piece(directions[i])
			steps[i] = 0

func update_ghost():
	var ghost_pos = cur_pos
	while can_move(Vector2i.DOWN, ghost_pos):
		ghost_pos += Vector2i.DOWN

	clear_ghost_layer()
	draw_piece(active_piece, ghost_pos, piece_atlas, ghost_layer)

func handle_inputs():
	handle_game_inputs()
	
	if game_running:
		handle_translate_inputs()
		handle_rotate_inputs()

	
func handle_game_inputs():
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()
	if Input.is_action_just_pressed("Restart"):
		new_game()
	
func handle_translate_inputs():
	if Input.is_action_pressed("PieceDown"):
		is_soft_dropping = true
		steps[2] += 10
	else:
		is_soft_dropping = false

	if Input.is_action_pressed("PieceLeft"):
		handle_das_input(0)
	elif Input.is_action_pressed("PieceRight"):
		handle_das_input(1)
	else:
		reset_das()
		
var das_speed = 40

func handle_das_input(dir):
	if das_moving:
		steps[dir] += 40
	else:
		if !das_started:
			# das hasn't started, initial movement
			steps[dir] = steps_req
			das_started = true
		else:
			steps[dir] += 2
			if steps[dir] >= das_steps_req:
				das_moving = true

func reset_das():
	steps[0] = 0
	steps[1] = 0
	das_started = false
	das_moving = false
	
func handle_rotate_inputs():
	if Input.is_action_just_pressed("Piece180"):
		rotate_piece(1)
		rotate_piece(1)
	elif Input.is_action_just_pressed("RotateLeft"):
		rotate_piece(-1)
	elif Input.is_action_just_pressed("RotateRight"):
		rotate_piece(1)
		
	if Input.is_action_just_pressed("PieceHardDrop"):
		hard_drop()
		
func hard_drop():
	var cells = 0
	while(can_move(Vector2i.DOWN)):
		cells += 1
		move_piece(Vector2i.DOWN)
	lock_piece()
	score_hard_drop(cells)


func toggle_pause():
	if game_running:
		game_running = false
		paused_label.show()
	else:
		game_running = true
		paused_label.hide()
	
func pick_piece():
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	return piece
	
func create_piece():
	#reset vars
	rotation_index = 0
	steps = [0, 0, 0]
	cur_pos = start_pos
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas)
	# show next piece
	draw_piece(next_piece_type[0], Vector2i(14,6), next_piece_atlas)

func clear_piece():
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)
		
func clear_ghost_layer():
	for i in range(ROWS + 2):
		for j in range(COLS + 1):
			erase_cell(ghost_layer, Vector2i(j, i))

func draw_piece(piece, pos, atlas, layer = active_layer):
	for i in piece:
		set_cell(layer, pos + i, tile_id, atlas)

func rotate_piece(rot):
	# rot: -1 = left, 1 = right
	if can_rotate(rot):
		clear_piece()
		rotation_index = (rotation_index + rot) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, cur_pos, piece_atlas)

func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas)
		if (dir == Vector2i.DOWN) and is_soft_dropping:
			score_soft_drop()
	else:
		if dir == Vector2i.DOWN:
			lock_piece()
			
func lock_piece():
	land_piece()
	check_rows()

	piece_type = next_piece_type
	piece_atlas = next_piece_atlas
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)

	clear_panel()
	create_piece()
	check_game_over()

func can_move(dir, pos = cur_pos):
	#check if there is space to move
	var cm = true
	for i in active_piece:
		if not is_free(i + pos + dir):
			cm = false
			break
	return cm

func can_rotate(rot):
	var cr = true
	var temp_rotation_index = (rotation_index + rot) % 4
	for i in piece_type[temp_rotation_index]:
		if not is_free(i + cur_pos):
			cr = false
			break
	return cr

func is_free(pos):
	var free = true
	if get_cell_source_id(board_layer, pos) != -1:
		free = false
	if get_cell_source_id(board_top_layer, pos) != -1:
		free = false
	return free
	
func land_piece():
	#remove each segment from active layer and move to board layer
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)
		set_cell(board_layer, cur_pos + i, tile_id, piece_atlas)

func clear_panel():
	for i in range(14, 19):
		for j in range(5, 9):
			erase_cell(active_layer, Vector2i(i, j))

func check_rows():
	var row : int = ROWS
	var lines_cleared : int = 0
	while row > 0:
		var count = 0
		for i in range(COLS):
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		# if row is full then erase it
		if count == COLS:
			shift_rows(row)
			lines_cleared += 1
		else:
			row -= 1
	
	score_line_clears(lines_cleared)

func score_soft_drop():
	#called on each cell while soft_dropping
	score += 1
	update_score()
	
func score_hard_drop(cells):
	#amount of cells dropped * 2
	cells = min(20, cells)
	score += cells * 2 
	update_score()
	
func score_line_clears(lines_cleared):
	const REWARDS = [0, 100, 300, 500, 800]
	score += REWARDS[lines_cleared] * level
	lines += lines_cleared
	update_score()
	update_lines()
	
func check_level():
	var new_level = roundi(lines / 10) + 1
	if new_level != level:
		level = new_level
		speed = level
		update_level()

func update_score():
	score_label.text = "SCORE " + str(score)
	check_level()
	
func update_lines():
	lines_label.text = "LINES " + str(lines)
	
func update_level():
	level_label.text = "LEVEL " + str(level)

func shift_rows(row):
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = get_cell_atlas_coords(board_layer, Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				erase_cell(board_layer, Vector2i(j + 1, i))
			else:
				set_cell(board_layer, Vector2i(j + 1, i), tile_id, atlas)

func clear_board():
	for i in range(-4, ROWS):
		for j in range(COLS):
			erase_cell(board_layer, Vector2i(j + 1, i + 1))

func check_game_over():
	for i in active_piece:
		if not is_free(i + cur_pos):
			land_piece()
			gameover_label.show()
			game_running = false
