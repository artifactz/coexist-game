extends Control

@export var minimum_font_size := 10

func _ready():
	# Set font size relative to viewport height
	var line_height = max(minimum_font_size, get_viewport().size.y / 26.0)
	theme.default_font_size = line_height
	$MarginContainer.add_theme_constant_override("margin_bottom", line_height)
