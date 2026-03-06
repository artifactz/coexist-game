class_name Game

var layout: Array = []
var solutions: Array = []
var correct_index = -1

func setup_round():
	layout = CubeGenerator.generate_random_layout()
	solutions = []
	correct_index = randi() % 3
	for i in 3:
		var solution_layout = CubeGenerator.invert_layout(layout)
		if i != correct_index:
			var n_true = randi() % 3
			var n_false
			if n_true == 0:
				n_false = 1 + randi() % 2
			elif n_true == 2:
				n_false = randi() % 2
			else:
				n_false = randi() % 3
			CubeGenerator.mutate_layout(solution_layout, n_true, n_false)
		solutions.push_back(solution_layout)
