extends Node3D

var CubeScene = preload("res://cube_3x3x3.tscn")
var last_mouse_position = Vector2()
var is_mouse_pressed = false
enum RotateMode { MainCube, SolutionCubes }
var rotate_mode: RotateMode
var main_cube: Node3D = null
var solution_cubes: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera3D.look_at(Vector3(0, 0, 0))

	main_cube = CubeScene.instantiate()
	var layout = CubeGenerator.generate_random_layout()
	main_cube.layout = layout
	main_cube.position = Vector3(0, 0.75, 0)
	main_cube.rotate_y(0.25 * PI)
	main_cube.rotate_x(0.15 * PI)
	add_child(main_cube)

	var rotations = canonic_rotations()
	var colors = ["#117733", "#DDCC77", "#CC6677"]
	for i in 3:
		var solution_layout = CubeGenerator.invert_layout(layout)
		if i > 0:
			var n_true = randi() % 3
			var n_false
			if n_true == 0:
				n_false = 1 + randi() % 2
			elif n_true == 2:
				n_false = randi() % 2
			else:
				n_false = randi() % 3
			CubeGenerator.mutate_layout(solution_layout, n_true, n_false)
		var cube = CubeScene.instantiate()
		cube.layout = solution_layout
		cube.color = colors[i]
		cube.position = Vector3(1.75 * (i - 1), -1, 0)
		var rotation = rotations.pop_at(randi() % rotations.size())
		cube.rotate_x(rotation[0])
		cube.rotate_y(rotation[1])
		cube.rotate_z(rotation[2])
		solution_cubes.push_back(cube)
		add_child(cube)

func canonic_rotations() -> Array:
	# Returns all permutations of [-0.5 PI, 0, 0.5 PI]³ except [0, 0, 0]
	var rotations = []
	for x in 3:
		for y in 3:
			for z in 3:
				if x == 1 and y == 1 and z == 1:
					continue
				rotations.push_back([
					0.5 * PI * (x - 1),
					0.5 * PI * (y - 1),
					0.5 * PI * (z - 1)
				])
	return rotations

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		is_mouse_pressed = event.is_pressed()
		if event.is_pressed():
			last_mouse_position = event.position

			var mouse_position = get_viewport().get_mouse_position()
			var viewport_size = get_viewport().size
			var half_height = viewport_size.y / 2
			rotate_mode = RotateMode.MainCube if mouse_position.y < half_height else RotateMode.SolutionCubes

	elif event is InputEventMouseMotion and is_mouse_pressed:
		var delta = event.position - last_mouse_position
		last_mouse_position = event.position

		if rotate_mode == RotateMode.MainCube:
			main_cube.rotate_y(delta.x * 0.01)
			main_cube.rotate_x(delta.y * 0.01)
		else:
			for cube in solution_cubes:
				cube.rotate_y(delta.x * 0.01)
				cube.rotate_x(delta.y * 0.01)
