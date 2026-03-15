extends Node3D

var game: Game = Game.new()
var scene_controller: SceneController
var ui_controller: UIController
var is_mouse_pressed = false
var is_mouse_dragged = false
enum RotateMode { MainCube, SolutionCubes }
var rotate_mode: RotateMode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var confirm_button = $UserInterface/ConfirmButton
	confirm_button.disabled = true
	confirm_button.pressed.connect(on_confirm_clicked)

	game.scores_updated.connect(update_scores)
	game.setup_round()

	scene_controller = SceneController.new($SubViewportContainer/SubViewport/Node)
	scene_controller.set_layouts(game.layout, game.solutions)

	ui_controller = UIController.new(
		scene_controller,
		$UserInterface/SelectionLine2D,
		confirm_button
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scene_controller._process(delta)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var mouse_position = get_viewport().get_mouse_position()
			var viewport_size = get_viewport().size
			var half_height = viewport_size.y / 2
			rotate_mode = RotateMode.MainCube if mouse_position.y < half_height else RotateMode.SolutionCubes
		elif not is_mouse_dragged:
			var collider = get_mouse_collision()
			if collider and collider.is_in_group("selectable"):
				select_solution(collider.solution_index)

		is_mouse_dragged = false
		is_mouse_pressed = event.is_pressed()

	elif event is InputEventMouseMotion and is_mouse_pressed:
		var viewport_size = get_viewport().size
		var input_scale = 12.0 / viewport_size.x

		if rotate_mode == RotateMode.MainCube:
			scene_controller.rotate_puzzle_from_mouse(input_scale * event.screen_relative)
		else:
			scene_controller.rotate_solutions_from_mouse(input_scale * event.screen_relative)

		is_mouse_dragged = true

func get_mouse_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = $SubViewportContainer/SubViewport/Node/Camera3D.project_ray_origin(mouse_pos)
	var dir = $SubViewportContainer/SubViewport/Node/Camera3D.project_ray_normal(mouse_pos)
	var end = origin + dir * 100.0

	var params = PhysicsRayQueryParameters3D.create(origin, end)
	var result = $SubViewportContainer/SubViewport.find_world_3d().direct_space_state.intersect_ray(params)

	if result:
		return result.get("collider")

func on_confirm_clicked():
	game.confirm()
	game.setup_round()
	scene_controller.set_layouts(game.layout, game.solutions)
	scene_controller.reset_scene()
	select_solution(-1)

func select_solution(index: int):
	game.selection_index = index
	scene_controller.select_solution(index)
	ui_controller.select_solution(index)

func update_scores():
	$UserInterface/CorrectLabel.text = "Correct: %s" % game.n_correct
	$UserInterface/WrongLabel.text = "Wrong: %s" % game.n_wrong
