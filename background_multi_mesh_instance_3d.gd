extends MultiMeshInstance3D

@export var instance_count: int = 24000

var material = preload("res://background_shader_material.tres")
var mesh := BoxMesh.new()
var transforms: Array = []

func _ready():
	mesh.size = Vector3(1.0, 0.02, 0.02)
	mesh.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = instance_count
	multimesh.visible_instance_count = 0

func add_instance(transform: Transform3D):
	transforms.push_back(transform)
	multimesh.set_instance_transform(multimesh.visible_instance_count, transform)
	multimesh.visible_instance_count += 1

func update_transforms():
	var n = transforms.size()
	multimesh.visible_instance_count = n
	for i in n:
		multimesh.set_instance_transform(i, transforms[i])
	#print("Set ", n, " instances.")

func step(dz := 1.0, cutoff := 0.0):
	for i in transforms.size():
		var t = transforms[i]
		t.origin.z += dz
		transforms[i] = t
	var n_before = transforms.size()
	transforms = transforms.filter(func (t: Transform3D): return t.origin.z < cutoff)
	var n_after = transforms.size()
	#print("Removed ", (n_before - n_after), " instances.")
	update_transforms()
