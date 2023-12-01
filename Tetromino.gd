extends Node

class_name Tetromino

static var shapes = [
		[	
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],
			[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
		],
		[	
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
		],
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
		],
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
		],
		[
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
		],
		[
			[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
		],
		[
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
		]
	]

var active_piece : Array
var piece_type
var next_piece_type
var rotation_index : int = 0
