@tool
extends Node3D

var material = preload("res://cube_shader_material.tres")

@export var sub_cube_size := 0.3
@export var sub_cube_stride := 0.33333
@export var refresh := false : set = _refresh

var layout = []
var color = Color("#FF00FFDA")


func _refresh(value):
	refresh = false
	_generate()

func _generate():
	# Clear old cubes
	for c in get_children():
		c.queue_free()

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
				add_child(cube)

func set_layout(layout):
	var subcubes = get_children()
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
			set_layout(layout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
