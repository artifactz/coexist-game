@tool
class_name Cube3x3x3
extends Node3D

static var material_template = preload("res://cube_shader_material.tres")

@export var sub_cube_size := 0.3
@export var sub_cube_stride := 0.33333
@export var refresh := false : set = _refresh

var color = Color("#FF00FFDA")
var emission = Color("#000000FF")
var solution_index = -1
var root: Node3D  # ClickableSolution (StaticBody3D) if selectable, Node3D otherwise
var material: ShaderMaterial


func _refresh(_value):
	refresh = false
	_generate()

func _generate():
	# Clear scene
	for c in get_children():
		if not c.get_class() == "AudioStreamPlayer":
			c.queue_free()

	if solution_index == -1:
		# Create regular node to contain subcubes
		root = Node3D.new()
		add_child(root)
	else:
		# Create collision parent and collider shape
		root = ClickableSolution.new(solution_index)
		add_child(root)

	# Create material
	material = material_template.duplicate()
	material.set_shader_parameter("albedo", color)
	material.set_shader_parameter("cube_size", Vector3(sub_cube_size, sub_cube_size, sub_cube_size))

	# Create new cubes
	for x in 3:
		for y in 3:
			for z in 3:
				var cube := MeshInstance3D.new()
				cube.name = "Cube_%d_%d_%d" % [x, y, z]
				cube.mesh = BoxMesh.new()
				cube.mesh.size = Vector3(sub_cube_size, sub_cube_size, sub_cube_size)
				cube.position = Vector3(
					(x - 1) * sub_cube_stride,
					(y - 1) * sub_cube_stride,
					(z - 1) * sub_cube_stride
				)
				cube.material_override = material
				root.add_child(cube)

	# Add collider shape after sub-cubes, so 1st sub-cube has index 0
	if solution_index > -1:
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		var size = 3 * sub_cube_stride - (sub_cube_stride - sub_cube_size)
		box.size = Vector3(size, size, size)
		shape.shape = box
		root.add_child(shape)

func set_layout(layout: Array):
	var subcubes = root.get_children()
	var i = 0
	for x in 3:
		for y in 3:
			for z in 3:
				subcubes[i].visible = layout[x][y][z]
				i += 1

func set_emission_intensity(ratio: float):
	material.set_shader_parameter(
		"emission",
		Color(emission.r * ratio, emission.g * ratio, emission.b * ratio, 1.0)
	)

## Overrides material alpha without changing color member (to be able to restore later).
func set_alpha(alpha: float):
	var c = Color(color)
	c.a = alpha
	material.set_shader_parameter("albedo", c)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		_generate()

## Starts transition animation.
func fly_in() -> void:
	$AudioStreamPlayer.restore()

	var tween = get_tree().create_tween()
	tween.set_parallel()
	var subcubes = root.get_children()
	for i in subcubes.size():
		var c = subcubes[i]
		if not c.visible:
			continue
		var x = c.position.x
		c.position.x = 30.0 * _random_sign(x) + 10.0 * randf() - 5.0
		tween.tween_property(c, "position:x", x, 0.5).set_custom_interpolator(
			func (x): return sqrt(x)
		).set_delay(0.05 * i)
		tween.tween_callback($AudioStreamPlayer.play).set_delay(0.05 * i + 0.5)

## Sign function, but returns a random sign at 0.
func _random_sign(value: float) -> float:
	if value < 0.0:
		return -1.0
	if value > 0.0:
		return 1.0
	return -1.0 if randf() < 0.5 else 1.0
