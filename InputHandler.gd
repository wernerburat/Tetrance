extends Node

signal toggle_pause
signal new_game
signal rotate_piece
signal hold_piece

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func handle_game_inputs():
	if Input.is_action_just_pressed("Pause"):
		toggle_pause.emit()
	if Input.is_action_just_pressed("Restart"):
		new_game.emit()

func handle_rotate_inputs():
	if Input.is_action_just_pressed("Piece180"):
		rotate_piece.emit(1)
		rotate_piece.emit(1)
	elif Input.is_action_just_pressed("RotateLeft"):
		rotate_piece.emit(-1)
	elif Input.is_action_just_pressed("RotateRight"):
		rotate_piece.emit(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_game_inputs()
	handle_rotate_inputs()
	
	if Input.is_action_just_pressed("PieceHold"):
		hold_piece.emit()
