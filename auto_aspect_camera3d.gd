class_name AutoAspectCamera3D
extends Camera3D

func _process(_delta):
	var viewport_size = get_viewport().size
	if viewport_size.y > viewport_size.x:
		keep_aspect = Camera3D.KEEP_WIDTH
	else:
		keep_aspect = Camera3D.KEEP_HEIGHT
