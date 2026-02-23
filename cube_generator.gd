class_name CubeGenerator

## Returns a 3x3x3 array of bools, all set to true, except of a random connected component
## of slots set to false.
static func generate_random_layout(n_false = 13) -> Array:
	var layout = _full_layout()
	var x = randi() % 3
	var y = randi() % 3
	var z = randi() % 3
	layout[x][y][z] = false

	for _i in n_false:
		_expand(layout, false)

	return layout

## Returns an inverted copy of the layout.
static func invert_layout(layout: Array) -> Array:
	var copy = layout.duplicate(true)
	for x in 3:
		for y in 3:
			for z in 3:
				copy[x][y][z] = not copy[x][y][z]
	return copy

## Expands true and false slots, respectively, in-place, such that both slot
## sets remain connected components.
static func mutate_layout(layout: Array, n_true: int, n_false: int) -> Array:
	var flipped_indices = []
	for i in n_true:
		flipped_indices.push_back(_expand(layout, true, flipped_indices))
	for i in n_false:
		flipped_indices.push_back(_expand(layout, false, flipped_indices))
	return layout

## Returns a 3x3x3 array of truth :)
static func _full_layout() -> Array:
	return [
		[[true, true, true], [true, true, true], [true, true, true]],
		[[true, true, true], [true, true, true], [true, true, true]],
		[[true, true, true], [true, true, true], [true, true, true]]
	]

## Flips a random slot with another value to value such that both slot sets remain connected components.
## Returns indices of flipped value.
static func _expand(layout: Array, value: bool, blocked_indices = []) -> Array:
	var indices = _indices_of(layout, value)
	while true:
		var xyz = indices[randi() % indices.size()]
		var neighbors = _get_neighbors(xyz[0], xyz[1], xyz[2])
		var nxyz = neighbors[randi() % neighbors.size()]
		if layout[nxyz[0]][nxyz[1]][nxyz[2]] == value or nxyz in blocked_indices:
			continue
		layout[nxyz[0]][nxyz[1]][nxyz[2]] = value
		var other_value_indices = _indices_of(layout, not value)
		var x = other_value_indices[0][0]
		var y = other_value_indices[0][1]
		var z = other_value_indices[0][2]
		var component = _get_connected_component(layout, x, y, z)
		if component.size() < other_value_indices.size():
			layout[nxyz[0]][nxyz[1]][nxyz[2]] = not value
			continue
		return nxyz
	return []

## Returns the indices of all slots with the specified value.
static func _indices_of(layout: Array, value: bool) -> Array:
	var result = []
	for x in 3:
		for y in 3:
			for z in 3:
				if layout[x][y][z] == value:
					result.push_back([x, y, z])
	return result

## Return the indices of all slots in the connected component containing x, y, z.
static func _get_connected_component(layout: Array, x: int, y: int, z: int) -> Array:
	var value = layout[x][y][z]
	var visited = [[x, y, z]]
	var queue = [[x, y, z]]
	while queue.size() > 0:
		var xyz = queue.pop_front()
		for nxyz in _get_neighbors(xyz[0], xyz[1], xyz[2]):
			if (
				layout[nxyz[0]][nxyz[1]][nxyz[2]] == value and
				nxyz not in visited
			):
				visited.push_back(nxyz)
				queue.push_back(nxyz)
	return visited

## Returns straight neighbors in bounds.
static func _get_neighbors(x: int, y: int, z: int) -> Array:
	var result = []
	if x > 0:
		result.push_back([x - 1, y, z])
	if x < 2:
		result.push_back([x + 1, y, z])
	if y > 0:
		result.push_back([x, y - 1, z])
	if y < 2:
		result.push_back([x, y + 1, z])
	if z > 0:
		result.push_back([x, y, z - 1])
	if z < 2:
		result.push_back([x, y, z + 1])
	return result
