class_name SceneController

const SELECTION_ACTIVATE_SECONDS = 0.2
const SELECTION_DEACTIVATE_SECONDS = 0.2

## How much rotating the cubes affects background camera roll
const ROTATION_TO_CAMERA_ROLL_AMOUNT = 3.0

const CUBE_THROW_FORCE := 9.0
const CUBE_THROW_ROTATION_FORCE := 3.0
const CUBE_THROW_GRAVITY := 9.81
const CUBE_THROW_SECONDS := 0.667

signal confirm_finished
signal score_update
signal hearts_update

static var CubeScene = preload("res://cube_3x3x3.tscn")

var scene: Node3D
var camera: Camera3D
var background_scene: BackgroundNode3D
var background_multimesh: BackgroundMultiMeshInstance3D
var main_cube: Cube3x3x3 = null
var solution_cubes: Array[Cube3x3x3] = []  ## Solution slots.
var solution_positions: Array[Vector3] = []

enum TransitionDirection { Activating, Deactivating }
var selection_lights: Array[SpotLight3D] = []  ## Selection spotlight per slot.
var selection_transitions: Array[float] = []  ## Selection transition state [0..1] per slot.
var selection_transition_directions: Array[TransitionDirection] = []  ## Transition direction per slot.
var selection_index: int = -1

var correct_index: int
var throwing_timestamp := 0.0
var throw_velocity := Vector3()
var throw_rotation_velocity := Vector3()

func _init(scene: Node3D, background_scene: BackgroundNode3D):
	self.scene = scene
	var nodes = scene.get_children()
	var i = nodes.find_custom((func (node: Node3D): return node.get_class() == "Camera3D"))
	self.camera = nodes[i]

	self.background_scene = background_scene
	nodes = background_scene.get_children()
	i = nodes.find_custom((func (node: Node3D): return node.get_class() == "MultiMeshInstance3D"))
	self.background_multimesh = nodes[i]

	_setup_scene()
	reset_scene()

func _process(delta: float) -> void:
	_update_transitions(delta)
	_update_throw(delta)

## Handles transitions of emission colors and light intensities.
func _update_transitions(delta: float) -> void:
	for i in selection_lights.size():
		var update = false
		if i == selection_index:
			if selection_transitions[i] == 0.0:
				update = true
				selection_lights[i].visible = true
			selection_transition_directions[i] = TransitionDirection.Activating
			if selection_transitions[i] < 1.0:
				selection_transitions[i] += delta / SELECTION_ACTIVATE_SECONDS
				selection_transitions[i] = min(1.0, selection_transitions[i])
				update = true
		else:
			selection_transition_directions[i] = TransitionDirection.Deactivating
			if selection_transitions[i] > 0.0:
				selection_transitions[i] -= delta / SELECTION_DEACTIVATE_SECONDS
				if selection_transitions[i] <= 0.0:
					selection_transitions[i] = 0.0
					selection_lights[i].visible = false
				update = true

		if update:
			var t = selection_transitions[i]

			# Ease-out
			if selection_transition_directions[i] == TransitionDirection.Activating:
				t = sqrt(t)
			else:
				t = t * t

			solution_cubes[i].set_emission_intensity(t)
			selection_lights[i].light_energy = t

## Moves selected cube wrt. throw_velocity and applies gravity to throw_velocity.
func _update_throw(delta: float) -> void:
	if not throwing_timestamp:
		return

	solution_cubes[selection_index].position += delta * throw_velocity
	solution_cubes[selection_index].rotation += delta * throw_rotation_velocity
	throw_velocity.y -= delta * CUBE_THROW_GRAVITY

	if Time.get_unix_time_from_system() >= throwing_timestamp + CUBE_THROW_SECONDS:
		throwing_timestamp = 0.0
		continue_after_throw_animation()

func select_solution(index: int):
	selection_index = index
	if index > -1:
		var color = solution_cubes[index].color
		background_multimesh.add_pulse(color, 2)

## Rotates the main cube given a mouse offset.
func rotate_puzzle_from_mouse(offset: Vector2):
	var camera_ray = main_cube.global_position - camera.global_position
	_rotate_from_mouse(main_cube, camera_ray, offset)
	background_scene.camera_roll_speed_factor += ROTATION_TO_CAMERA_ROLL_AMOUNT * offset.length()

## Rotates the solution cubes given a mouse offset.
func rotate_solutions_from_mouse(offset: Vector2):
	var common_camera_ray = solution_cubes[1].global_position - camera.global_position
	for cube in solution_cubes:
		_rotate_from_mouse(cube, common_camera_ray, offset)
	background_scene.camera_roll_speed_factor += ROTATION_TO_CAMERA_ROLL_AMOUNT * offset.length()

## Sets main and solution cube layouts.
func set_layouts(puzzle: Array, solutions: Array):
	main_cube.set_layout(puzzle)
	for i in 3:
		solution_cubes[i].set_layout(solutions[i])

## Schedules a chain of animations depending on whether the correct solution was selected.
## Emits confirm_finished signal eventually.
func start_confirm_animation(correct_index: int):
	self.correct_index = correct_index

	# Move selected cube to right before it slides into position
	var tween = scene.create_tween()
	var target_transform = solution_cubes[selection_index].transform.interpolate_with(main_cube.transform, 0.95)
	tween.tween_property(solution_cubes[selection_index], "transform", target_transform, 0.9).set_custom_interpolator(func (x: float): return sqrt(x))

	if selection_index == correct_index:
		# Slide selected cube into position to reveal that solution is correct
		tween.tween_property(solution_cubes[selection_index], "transform", main_cube.transform, 0.28).set_trans(Tween.TRANS_CIRC).set_delay(0.075)

		# Fade out incorrect solutions
		tween.set_parallel()
		for i in 3:
			if i == selection_index:
				continue
			tween.tween_method(solution_cubes[i].set_alpha, solution_cubes[i].color.a, 0.0, 0.5)

		# Signal that score can be updated now
		tween.tween_callback(score_update.emit)

		# Fade out main cube and correct solution cube
		tween.set_parallel(false)
		tween.tween_method(main_cube.set_alpha, main_cube.color.a, 0.0, 0.5).set_delay(0.5)
		tween.parallel()
		tween.tween_method(solution_cubes[selection_index].set_alpha, solution_cubes[selection_index].color.a, 0.0, 0.5).set_delay(0.5)
		tween.tween_callback(confirm_finished.emit)

	else:
		# Determine throw velocities
		var angle = 0.15 * PI + 0.05 * (2.0 * randf() - 1.0)
		var vel = Vector3(cos(angle), sin(angle), 0.0)
		if randf() < 0.5:
			vel.x *= -1.0
		var rot_vel = Vector3(
			PI * (2 * randf() - 1.0),
			PI * (2 * randf() - 1.0),
			PI * (2 * randf() - 1.0)
		)
		tween.tween_callback(func ():
			# Enable "throw physics"
			throw_velocity = CUBE_THROW_FORCE * vel
			throw_rotation_velocity = CUBE_THROW_ROTATION_FORCE * rot_vel
			throwing_timestamp = Time.get_unix_time_from_system()
		)

		# Signal that hearts can be updated now
		tween.tween_callback(hearts_update.emit)

func continue_after_throw_animation():
	scene.create_tween().tween_method(solution_cubes[selection_index].set_alpha, solution_cubes[selection_index].color.a, 0.0, 0.5)

	var index = _get_remaining_index(correct_index, selection_index)
	scene.create_tween().tween_method(solution_cubes[index].set_alpha, solution_cubes[index].color.a, 0.0, 0.5)

	var tween = scene.create_tween()
	var target_transform = solution_cubes[correct_index].transform.interpolate_with(main_cube.transform, 0.95)
	tween.tween_property(solution_cubes[correct_index], "transform", target_transform, 0.9).set_custom_interpolator(func (x: float): return sqrt(x))
	tween.tween_property(solution_cubes[correct_index], "transform", main_cube.transform, 0.28).set_trans(Tween.TRANS_CIRC).set_delay(0.075)

	tween.tween_method(solution_cubes[correct_index].set_alpha, solution_cubes[correct_index].color.a, 0.0, 0.5).set_delay(0.5)
	tween.parallel()
	tween.tween_method(main_cube.set_alpha, main_cube.color.a, 0.0, 0.5).set_delay(0.5)
	tween.tween_callback(confirm_finished.emit)

static func _get_remaining_index(a: int, b: int) -> int:
	var a_ = min(a, b)
	var b_ = max(a, b)
	if a_ == 0 and b_ == 1:
		return 2
	if a_ == 0 and b_ == 2:
		return 1
	assert(a_ == 1 and b_ == 2)
	return 0

func fadein_cubes():
	var tween = scene.create_tween()
	tween.set_parallel()
	tween.tween_method(main_cube.set_alpha, 0.0, main_cube.color.a, 0.5)
	for i in 3:
		tween.tween_method(solution_cubes[i].set_alpha, 0.0, solution_cubes[i].color.a, 0.5)

## Resets cube rotations.
func reset_scene():
	selection_index = -1
	_set_euler_zyx(main_cube, Vector3(0.15 * PI, 0.25 * PI, 0.0))
	var rotations = _canonic_rotations()
	for i in 3:
		_set_euler_zyx(solution_cubes[i], rotations.pop_at(randi() % rotations.size()))
		solution_cubes[i].position = solution_positions[i]

func _setup_scene():
	_setup_camera()
	_setup_cubes()

## Creates and assigns cubes.
func _setup_cubes():
	main_cube = _create_cube(Color("#4477AADA"), Vector3(0, 1.0, 0))
	main_cube.set_alpha(0.0)

	var colors = [Color("#117733DA"), Color("#DDCC77DA"), Color("#CC6677DA")]
	var emissions = [Color("#003314FF"), Color("#473F17FF"), Color("#571816FF")]
	for i in 3:
		var x = 1.75 * (i - 1)
		var pos = Vector3(x, -1.15, 0)
		solution_positions.push_back(pos)
		var cube = _create_cube(colors[i], pos, i)
		cube.emission = emissions[i]
		cube.set_alpha(0.0)
		solution_cubes.push_back(cube)

		var light = _create_spotlight(Vector3(x, 0, 0))
		selection_lights.push_back(light)
		selection_transitions.push_back(0.0)
		selection_transition_directions.push_back(TransitionDirection.Activating)

func _setup_camera():
	camera.look_at(Vector3(0, 0, 0))

## Creates a cube instance and adds it to the scene.
func _create_cube(color: Color, position: Vector3, solution_index: int = -1) -> Cube3x3x3:
	var cube = CubeScene.instantiate()
	cube.color = color
	cube.position = position
	cube.solution_index = solution_index
	scene.add_child(cube)
	return cube

## Creates a spotlight instance and adds it to the scene.
func _create_spotlight(position: Vector3) -> SpotLight3D:
	var light = SpotLight3D.new()
	light.position = position
	light.rotation.x = -0.5 * PI
	light.visible = false
	scene.add_child(light)
	return light

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
