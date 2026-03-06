extends Node3D

var game: Game = Game.new()
var CubeScene = preload("res://cube_3x3x3.tscn")
var last_mouse_position = Vector2()
var is_mouse_pressed = false
var is_mouse_dragged = false
enum RotateMode { MainCube, SolutionCubes }
var rotate_mode: RotateMode
var main_cube: Node3D = null
var solution_cubes: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera3D.look_at(Vector3(0, 0, 0))

	game.setup_round()

	main_cube = CubeScene.instantiate()
	main_cube.layout = game.layout
	main_cube.color = Color("#4477AADA")
	main_cube.position = Vector3(0, 0.75, 0)
	main_cube.rotate_y(0.25 * PI)
	main_cube.rotate_x(0.15 * PI)
	add_child(main_cube)

	var rotations = canonic_rotations()
	var colors = ["#117733DA", "#DDCC77DA", "#CC6677DA"]
	for i in 3:
		var cube = CubeScene.instantiate()
		cube.layout = game.solutions[i]
		cube.color = Color(colors[i])
		cube.solution_index = i
		cube.position = Vector3(1.75 * (i - 1), -1, 0)
		var cube_rotation = rotations.pop_at(randi() % rotations.size())
		cube.rotate_x(cube_rotation[0])
		cube.rotate_y(cube_rotation[1])
		cube.rotate_z(cube_rotation[2])
		solution_cubes.push_back(cube)
		add_child(cube)

## Returns all permutations of [-0.5 PI, 0, 0.5 PI]³ except [0, 0, 0]
func canonic_rotations() -> Array:
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
		if event.is_pressed():
			last_mouse_position = event.position

			var mouse_position = get_viewport().get_mouse_position()
			var viewport_size = get_viewport().size
			var half_height = viewport_size.y / 2
			rotate_mode = RotateMode.MainCube if mouse_position.y < half_height else RotateMode.SolutionCubes
		elif not is_mouse_dragged:
			var collider = get_mouse_collision()
			if collider and collider.is_in_group("selectable"):
				print("selected", collider.solution_index)
				var cube_position = $Camera3D.unproject_position(collider.global_position)
				var size = 0.8
				var dy = 0.1
				var dz = 0.3333
				$UserInterface/Line2D.points = PackedVector2Array([
					$Camera3D.unproject_position(collider.global_position + Vector3(-size, size + dy, dz)),
					$Camera3D.unproject_position(collider.global_position + Vector3(size, size + dy, dz)),
					$Camera3D.unproject_position(collider.global_position + Vector3(size, -size + dy, dz)),
					$Camera3D.unproject_position(collider.global_position + Vector3(-size, -size + dy, dz)),
				])
				#var color: Color = solution_cubes[collider.solution_index].color
				#color.h = fmod(color.h + 0.5, 1)
				#$UserInterface/Line2D.default_color = color
				$UserInterface/Line2D.default_color = Color("66b3ff99")

		is_mouse_dragged = false
		is_mouse_pressed = event.is_pressed()

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

		is_mouse_dragged = true

func get_mouse_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = $Camera3D.project_ray_origin(mouse_pos)
	var dir = $Camera3D.project_ray_normal(mouse_pos)
	var end = origin + dir * 100.0

	var params = PhysicsRayQueryParameters3D.create(origin, end)
	var result = get_world_3d().direct_space_state.intersect_ray(params)

	if result:
		return result.get("collider")
