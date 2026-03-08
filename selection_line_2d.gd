class_name SelectionLine2D
extends Line2D

const ACCELERATION = 800.0;
const DECAY = 16.0;
const DAMPENING = 30.0;
const DIRECT_INITIAL_SPEED = 20.0;
const RANDOM_INITIAL_SPEED = 1750.0;

var targets: Array[Vector2]
var velocities: Array[Vector2]

## Animates points towards targets.
func _process(delta: float) -> void:
	if not targets:
		return
	for i in points.size():
		var error = targets[i] - points[i]
		var error_length = error.length()
		if error_length < 1.0 and velocities[i].length_squared() < 4.0:
			continue

		#velocities[i] *= pow(0.00005, delta)
		velocities[i] *= 1.0 - DECAY * delta

		# Only apply dampening when we're moving away from target
		var err_length_diff = (error - delta * velocities[i]).length() - error_length
		if err_length_diff > 0.0:
			velocities[i] *= 1.0 - DAMPENING * delta

		velocities[i] += delta * ACCELERATION * sqrt(error.length()) * error.normalized()
		points[i] += delta * velocities[i]

func set_targets(targets: Array[Vector2]) -> void:
	# Initial velocities consist of vector towards targets and noise
	velocities.clear()
	for i in targets.size():
		var velocity = DIRECT_INITIAL_SPEED * (targets[i] - points[i])
		velocity.x += RANDOM_INITIAL_SPEED * (2.0 * randf() - 1.0) * (2.0 * randf() - 1.0)
		velocity.y += RANDOM_INITIAL_SPEED * (2.0 * randf() - 1.0) * (2.0 * randf() - 1.0)
		velocities.push_back(velocity)

	self.targets = targets
