class_name SelectionLine2D
extends Line2D

const RANDOMNESS = 0.5
const ANIMATION_DURATION = 0.3
const FADEOUT_DURATION = 0.4

var targets: Array[Vector2]
var origins: Array[Vector2]
var velocities: Array[Vector2]
var animation_t: float
var fadeout_t := -1.0
var original_alpha: float

func _ready() -> void:
	original_alpha = default_color.a

## Animates fadeout and points towards targets.
func _process(delta: float) -> void:
	if fadeout_t >= FADEOUT_DURATION:
		points = PackedVector2Array()
		default_color.a = original_alpha
		fadeout_t = -1.0
	if fadeout_t >= 0.0:
		default_color.a = original_alpha * (1.0 - sqrt(fadeout_t / FADEOUT_DURATION))
		fadeout_t += delta

	if not targets:
		return

	# Set line width relative to viewport size
	var viewport_size = get_viewport().size
	width = min(viewport_size.x, viewport_size.y) / 70.0

	animation_t += delta

	for i in points.size():
		var noisy_target = origins[i] + ANIMATION_DURATION * velocities[i]
		var t = clamp(animation_t / ANIMATION_DURATION, 0.0, 1.0)
		t = sqrt(t)  # Ease-out
		var p = origins[i].lerp(noisy_target, t)
		points[i] = p.lerp(targets[i], t)

	if animation_t >= ANIMATION_DURATION:
		targets = []

func set_targets(targets: Array[Vector2]) -> void:
	var viewport_size = get_viewport().size
	var viewport_scale = min(viewport_size.x, viewport_size.y)
	var randomness_scale = viewport_scale * RANDOMNESS

	origins.clear()
	velocities.clear()
	for i in targets.size():
		# Store origin
		origins.push_back(points[i])

		# Calculate noisy velocity towards target
		var relative = targets[i] - points[i]
		var velocity = relative / ANIMATION_DURATION
		velocity.x += randomness_scale * (2.0 * randf() - 1.0) * (2.0 * randf() - 1.0)
		velocity.y += randomness_scale * (2.0 * randf() - 1.0) * (2.0 * randf() - 1.0)
		velocities.push_back(velocity)

	self.targets = targets
	animation_t = 0.0

func fadeout() -> void:
	fadeout_t = 0.0
