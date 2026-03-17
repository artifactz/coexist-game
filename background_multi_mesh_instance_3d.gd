extends MultiMeshInstance3D
class_name BackgroundMultiMeshInstance3D

@export var instance_count: int = 24000

const HEARTBEAT_INTERVAL_SECONDS = 6.667

class Pulse:
	var color := Color(0.9, 0.071, 0.071)
	var start_z := 5.0
	var end_z := -15.0
	var duration := 2.0
	var age := 0.0

var material = preload("res://background_shader_material.tres")
var mesh := BoxMesh.new()
var transforms: Array = []
var pulses: Array = []
var heartbeat_time: float = HEARTBEAT_INTERVAL_SECONDS
var heartbeat_color := Color("305374ff")

func _ready() -> void:
	mesh.size = Vector3(1.0, 0.02, 0.02)
	mesh.material = material
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = instance_count
	multimesh.visible_instance_count = 0

func _process(delta: float) -> void:
	_update_pulses(delta)
	_update_heartbeat(delta)

func _update_pulses(delta: float) -> void:
	if not pulses:
		return

	while pulses[0].age >= pulses[0].duration:
		pulses.pop_front()
		if not pulses:
			material.set_shader_parameter("pulse_color", Color())
			return

	material.set_shader_parameter("pulse_color", pulses[0].color)
	var z = (1.0 - pulses[0].age) * pulses[0].start_z + pulses[0].age * pulses[0].end_z
	material.set_shader_parameter("pulse_z", z)
	pulses[0].age += delta

func _update_heartbeat(delta: float) -> void:
	if heartbeat_time >= HEARTBEAT_INTERVAL_SECONDS:
		heartbeat_time -= HEARTBEAT_INTERVAL_SECONDS
		if not pulses:
			add_pulse(heartbeat_color)
	heartbeat_time += delta

func add_pulse(color: Color, max_pulses := -1):
	if max_pulses > -1 and pulses.size() >= max_pulses:
		return
	var pulse = Pulse.new()
	pulse.color = color
	pulses.push_back(pulse)
	heartbeat_time = 0.0

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
