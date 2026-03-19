extends Label3D

@export var counting_duration_seconds := 1.0
@export var last_count_delay_seconds := 0.2

var score := 0.0
var target_score := 0.0
var old_score := 0.0
var score_t := -1.0

func set_score(value: float) -> void:
	target_score = value
	old_score = score
	score_t = 0.0

func _process(delta: float) -> void:
	_update_transition(delta)
	_reset_padding()

func _update_transition(delta: float) -> void:
	if score_t == -1.0:
		return

	score_t += delta

	if score_t >= counting_duration_seconds + last_count_delay_seconds:
		score = target_score
		score_t = -1.0
	elif score_t >= counting_duration_seconds:
		score = target_score - 1.0
	elif score_t >= 0.0:
		var t = score_t / counting_duration_seconds
		t = pow(t, 0.25)
		score = lerp(old_score, target_score - 1.0, t)

	_update_text()

func _update_text() -> void:
	text = "Score: %d" % round(score)

## Repositions based on portrait/landscape mode.
func _reset_padding():
	var viewport_size = get_viewport().size
	position.x = -0.94 if viewport_size.y > viewport_size.x else -1.15
