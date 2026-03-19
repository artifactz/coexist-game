extends ColorRect

func start_hurt_animation():
	color.a = 0.0
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color:a", 0.4, 0.025)
	tween.tween_property(self, "color:a", 0.0, 0.5).set_custom_interpolator(func (x): return sqrt(x))
	tween.tween_callback(func (): visible = false)
