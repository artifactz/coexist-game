extends Node3D

const DETAILS_PANEL_BEGIN_Y = 1.0
const DETAILS_PANEL_END_Y = 1.3

var speedbonus_label_width: float
var streakbonus_label_width: float
var labels: Array[Label3D] = []
var streak_labels: Array[Label3D]
var speed_labels: Array[Label3D]

func _ready() -> void:
	streak_labels = [$StreakbonusLabel3D, $StreakbonusValueLabel3D, $StreakbonusPlusLabel3D]
	speed_labels = [$SpeedbonusLabel3D, $SpeedbonusValueLabel3D, $SpeedbonusPlusLabel3D]
	speedbonus_label_width = _get_label3d_width($SpeedbonusLabel3D)
	streakbonus_label_width = _get_label3d_width($StreakbonusLabel3D)
	labels.assign(get_children().filter(func (c): return c.get_class() == "Label3D"))

func show_score_details(score_details: ScoreDetails):
	_arrange(score_details.streak_bonus, score_details.speed_bonus)
	_animate(score_details.streak_bonus, score_details.speed_bonus)

func _arrange(streakbonus: int, speedbonus: int, padding := 0.025):
	$StreakbonusValueLabel3D.position.x = -streakbonus_label_width - padding
	$StreakbonusValueLabel3D.text = str(streakbonus)
	var streakbonus_value_width = _get_label3d_width($StreakbonusValueLabel3D)
	$StreakbonusPlusLabel3D.position.x = $StreakbonusValueLabel3D.position.x - streakbonus_value_width - padding

	$SpeedbonusValueLabel3D.position.x = -speedbonus_label_width - padding
	$SpeedbonusValueLabel3D.text = str(speedbonus)
	var speedbonus_value_width = _get_label3d_width($SpeedbonusValueLabel3D)
	$SpeedbonusPlusLabel3D.position.x = $SpeedbonusValueLabel3D.position.x - speedbonus_value_width - padding

func _get_label3d_width(label3d: Label3D):
	return label3d.font.get_string_size(
		label3d.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		label3d.font_size
	).x * label3d.pixel_size

func _animate(streakbonus: int, speedbonus: int):
	visible = true

	var tween1 = get_tree().create_tween()
	tween1.set_parallel()
	for label in labels:
		label.modulate.a = 0.0

		# Don't show "+0 bonus" lines
		label.visible = (streakbonus > 0 and label in streak_labels) or (speedbonus > 0 and label in speed_labels)

		tween1.tween_property(label, "modulate:a", 1.0, 0.667)
		tween1.tween_property(label, "outline_modulate", 1.0, 0.667)
		tween1.tween_property(label, "modulate:a", 0.0, 0.667).set_delay(1.333)
		tween1.tween_property(label, "outline_modulate:a", 0.0, 0.667).set_delay(1.333)

	tween1.set_parallel(false)
	tween1.tween_callback(func (): visible = false)

	var tween2 = get_tree().create_tween()
	position.y = DETAILS_PANEL_BEGIN_Y
	const interval_bound := 1.2 ## Curvature. Max: PI/2
	const y_max := tan(interval_bound)

	var transition := func (x):
		var scaled_x = 2.0 * x - 1.0
		var interval_x = interval_bound * scaled_x
		return scaled_x * scaled_x * tan(interval_x) / y_max

	tween2.tween_property(self, "position:y", DETAILS_PANEL_END_Y, 2.0) \
		.set_custom_interpolator(transition)
