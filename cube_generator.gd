class_name CubeGenerator

static func full_layout() -> Array:
	return [
		[[true, true, true], [true, true, true], [true, true, true]],
		[[true, true, true], [true, true, true], [true, true, true]],
		[[true, true, true], [true, true, true], [true, true, true]]
	]

static func generate_random_layout(deactivated_subcubes = 13) -> Array:
	# Returns a 3x3x3 array of bools, all set to true, except of a random "connected component"
	# of neighbors set to false.

	var layout = full_layout()
	var x = randi() % 3
	var y = randi() % 3
	var z = randi() % 3
	layout[x][y][z] = false
	var removed = [[x, y, z]]

	while removed.size() < deactivated_subcubes:
		var i = randi() % removed.size()
		x = removed[i][0]
		y = removed[i][1]
		z = removed[i][2]

		var neighbors = []

		if x > 0:
			neighbors.push_back([x - 1, y, z])
		if x < 2:
			neighbors.push_back([x + 1, y, z])
		if y > 0:
			neighbors.push_back([x, y - 1, z])
		if y < 2:
			neighbors.push_back([x, y + 1, z])
		if z > 0:
			neighbors.push_back([x, y, z - 1])
		if z < 2:
			neighbors.push_back([x, y, z + 1])

		i = randi() % neighbors.size()
		x = neighbors[i][0]
		y = neighbors[i][1]
		z = neighbors[i][2]
		layout[x][y][z] = false
		removed.push_back([x, y, z])

	return layout

static func invert_layout(layout) -> Array:
	var copy = layout.duplicate(true)
	for x in 3:
		for y in 3:
			for z in 3:
				copy[x][y][z] = not copy[x][y][z]
	return copy
