@tool
class_name Cube3x3x3
extends Node3D

var material = preload("res://cube_shader_material.tres")

@export var sub_cube_size := 0.3
@export var sub_cube_stride := 0.33333
@export var refresh := false : set = _refresh

var layout = []
var color = Color("#FF00FFDA")
var solution_index = -1
var root: Node3D = self  # changes if selectable


func _refresh(_value):
	refresh = false
	_generate()

func _generate():
	# Clear scene
	for c in get_children():
		c.queue_free()

	# Create collision parent and collider shape
	if solution_index > -1:
		root = ClickableSolution.new(solution_index)
		root.add_to_group("selectable")
		add_child(root)

	# Create material
	var mat: ShaderMaterial = material.duplicate()
	mat.set_shader_parameter("albedo", color)
	mat.set_shader_parameter("cube_size", Vector3(sub_cube_size, sub_cube_size, sub_cube_size))

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
				cube.mesh.surface_set_material(0, mat)
				root.add_child(cube)

	# Add collider shape after sub-cubes, so 1st sub-cube has index 0
	if solution_index > -1:
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		var size = 3 * sub_cube_stride - (sub_cube_stride - sub_cube_size)
		box.size = Vector3(size, size, size)
		shape.shape = box
		root.add_child(shape)


func set_layout():
	var subcubes = root.get_children()
	var i = 0
	for x in 3:
		for y in 3:
			for z in 3:
				subcubes[i].visible = layout[x][y][z]
				i += 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		_generate()
		if layout.size() > 0:
			set_layout()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
