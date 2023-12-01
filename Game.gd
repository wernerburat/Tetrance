extends Node

var game_running : bool

func _ready():
	init_game_vars()

func init_game_vars():
	game_running = true
	
func is_game_running():
	return game_running

func _on_input_handler_toggle_pause():
	game_running = !game_running
