class_name SceneController

static var CubeScene = preload("res://cube_3x3x3.tscn")

var scene: Node3D
var camera: Camera3D
var main_cube: Cube3x3x3 = null
var solution_cubes: Array[Cube3x3x3] = []

func _init(scene: Node3D):
	self.scene = scene
	var nodes = scene.get_children()
	var i = nodes.find_custom((func (node: Node3D): return node.get_class() == "Camera3D"))
	self.camera = nodes[i]
	_setup_scene()
	reset_scene()

## Rotates the main cube given a mouse offset.
func rotate_puzzle_from_mouse(offset: Vector2):
	var camera_ray = main_cube.global_position - camera.global_position
	_rotate_from_mouse(main_cube, camera_ray, offset)

## Rotates the solution cubes given a mouse offset.
func rotate_solutions_from_mouse(offset: Vector2):
	var common_camera_ray = solution_cubes[1].global_position - camera.global_position
	for cube in solution_cubes:
		_rotate_from_mouse(cube, common_camera_ray, offset)

## Sets main and solution cube layouts.
func set_layouts(puzzle: Array, solutions: Array):
	main_cube.set_layout(puzzle)
	for i in 3:
		solution_cubes[i].set_layout(solutions[i])

## Resets cube rotations.
func reset_scene():
	_set_euler_zyx(main_cube, Vector3(0.15 * PI, 0.25 * PI, 0.0))
	var rotations = _canonic_rotations()
	for i in 3:
		_set_euler_zyx(solution_cubes[i], rotations.pop_at(randi() % rotations.size()))

## Creates and assigns cubes.
func _setup_scene():
	main_cube = _create_cube(Color("#4477AADA"), Vector3(0, 0.75, 0))

	var colors = ["#117733DA", "#DDCC77DA", "#CC6677DA"]
	for i in 3:
		var cube = _create_cube(Color(colors[i]), Vector3(1.75 * (i - 1), -1, 0), i)
		solution_cubes.push_back(cube)

## Creates a cube instance and adds it to the scene.
func _create_cube(color: Color, position: Vector3, solution_index: int = -1) -> Cube3x3x3:
	var cube = CubeScene.instantiate()
	cube.color = color
	cube.position = position
	cube.solution_index = solution_index
	scene.add_child(cube)
	return cube

## Returns all permutations of [-0.5 PI, 0, 0.5 PI]³ except [0, 0, 0]
static func _canonic_rotations() -> Array:
	var rotations = []
	for x in 3:
		for y in 3:
			for z in 3:
				if x == 1 and y == 1 and z == 1:
					continue
				rotations.push_back(Vector3(
					0.5 * PI * (x - 1),
					0.5 * PI * (y - 1),
					0.5 * PI * (z - 1)
				))
	return rotations

## Sets axis rotations in Z, Y, X order.
static func _set_euler_zyx(node: Node3D, rotation: Vector3):
	node.rotation = Vector3(0.0, 0.0, 0.0)
	node.rotate_z(rotation[2])
	node.rotate_y(rotation[1])
	node.rotate_x(rotation[0])

## Rotates a node by a mouse offset. Calculates UP rotation axis automatically from the node's
## camera_ray.
static func _rotate_from_mouse(node: Node3D, camera_ray: Vector3, offset: Vector2):
	var v = Vector3(camera_ray)
	var tmp = v.y
	v.y = -v.z
	v.z = tmp
	node.rotate(v.normalized(), offset.x)
	node.rotate_x(offset.y)
