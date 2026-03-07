class_name Game

signal scores_updated

var layout: Array = []
var solutions: Array = []
var correct_index = -1
var selection_index = -1
var n_correct = 0
var n_wrong = 0

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

func confirm():
	if selection_index == correct_index:
		n_correct += 1
	else:
		n_wrong += 1
	scores_updated.emit()
