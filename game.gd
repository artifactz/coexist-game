class_name Game

var layout: Array = []
var solutions: Array = []
var correct_index = -1
var selection_index = -1
var round_timestamp: float

var difficulty := 0.0
var score := 0.0
var n_correct := 0
var n_wrong := 0
var correct_streak := 0
var wrong_streak := 0

func setup_round():
	print("difficulty: ", difficulty)
	var component_size = int(3.0 + difficulty / 3.0)
	print("component_size: ", component_size)
	layout = CubeGenerator.generate_random_layout(component_size)

	var variation_difficulty = fmod(difficulty / 3.0, 1.0)
	print("variation_difficulty: ", variation_difficulty)
	var max_flips = ceil(lerp(0.3667, 0.1, variation_difficulty) * component_size)
	print("max_flips: ", max_flips)

	solutions = []
	correct_index = randi() % 3
	for i in 3:
		var solution_layout = CubeGenerator.invert_layout(layout)
		if i != correct_index:
			var high = ceil(lerp(1.0, 0.5, variation_difficulty) * max_flips)
			var low = max_flips - high
			var n_true: int
			var n_false: int
			if randi() % 2 == 0:
				n_true = high
				n_false = low
			else:
				n_false = high
				n_true = low
			print("n_true: ", n_true, " n_false: ", n_false)

			CubeGenerator.mutate_layout(solution_layout, n_true, n_false)
		solutions.push_back(solution_layout)
	print()

	round_timestamp = Time.get_unix_time_from_system()

## Updates score and difficulty state.
func confirm():
	var round_duration = Time.get_unix_time_from_system() - round_timestamp
	var speed_bonus = exp(-0.1 * round_duration)
	print("round_duration: ", round_duration)
	print("speed_bonus: ", speed_bonus)

	if selection_index == correct_index:
		n_correct += 1
		correct_streak += 1
		wrong_streak = 0
		var score_bump = pow(1.1, 1.0 + difficulty) * (correct_streak + speed_bonus)
		print("score+: ", score_bump)
		score += score_bump
		var difficulty_bump = 0.333 * correct_streak + speed_bonus
		print("difficulty+: ", difficulty_bump)
		difficulty = clamp(difficulty + difficulty_bump, 0.0, 30.0)

	else:
		n_wrong += 1
		wrong_streak += 1
		correct_streak = 0
		difficulty *= 0.6
