class_name ClickableSolution
extends StaticBody3D
## A physics body for ray collision checks (to select on click) that retains the
## index of its corresponding solution option, so we know what we clicked on.

var solution_index = -1

func _init(index: int):
	solution_index = index
