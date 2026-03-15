class_name UIController

var scene_controller: SceneController
var selection_line: SelectionLine2D
var confirm_button: Button

func _init(scene_controller: SceneController, selection_line: SelectionLine2D, confirm_button: Button):
	self.scene_controller = scene_controller
	self.selection_line = selection_line
	self.confirm_button = confirm_button

func select_solution(index: int):
	if index == -1:
		selection_line.points = PackedVector2Array()
		confirm_button.disabled = true
		return

	var size = 0.8
	var dy = 0.1
	var dz = 0.3333
	var center = scene_controller.solution_cubes[index].global_position
	var targets: Array[Vector2] = [
		scene_controller.camera.unproject_position(center + Vector3(-size, size + dy, dz)),
		scene_controller.camera.unproject_position(center + Vector3(size, size + dy, dz)),
		scene_controller.camera.unproject_position(center + Vector3(size, -size + dy, dz)),
		scene_controller.camera.unproject_position(center + Vector3(-size, -size + dy, dz)),
	]

	if not selection_line.points:
		# Initialize 1st selection points as noisy targets
		var points = targets.duplicate()
		_randomize_vec2_array(points, 75.0)
		selection_line.points = PackedVector2Array(points)

	# Set animation targets
	selection_line.set_targets(targets)

	confirm_button.disabled = false

func _randomize_vec2_array(arr: Array[Vector2], scale: float):
	for i in arr.size():
		var dx = scale * (2 * randf() - 1) * (2 * randf() - 1)
		var dy = scale * (2 * randf() - 1) * (2 * randf() - 1)
		arr[i] += Vector2(dx, dy)
