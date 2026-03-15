extends SubViewport

func _ready() -> void:
	# Render at half resolution on mobile devices to improve performance
	if (
		OS.has_feature("mobile") or
		OS.has_feature("web_android") or
		OS.has_feature("web_ios")
	):
		scaling_3d_scale = 0.5
