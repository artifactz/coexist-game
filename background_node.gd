extends Node3D
## Randomly places a whole bunch of cubes on a 3D grid (with a hole/tunnel in the center),
## instantiates 12 meshes per cube representing its edges, retaining information about which
## edges need to be instantiated and which already are, for the last two layers of the 3D grid.
## Then starts moving the camera forward, removing geometry falling behind and generating new
## slices in the front.

const CAMERA_SPEED = 0.08
const CAMERA_SPIRAL_RADIUS = 0.33
const CAMERA_SPIRAL_SPEED = 0.026109
const CAMERA_ROLL_MAGNITUDE = 0.014625 * PI
const CAMERA_ROLL_SPEED = 0.015983
const W = 20
const H = 20
const D = 40
const TUNNEL_SIZE = 10

## Last two slices of a 3D grid storing along which axes (x, y, z) to put cube edges.
var edges = []

var camera_spiral_t: float = 0.0
var camera_roll_t: float = 0.25

func _ready() -> void:
	edges = [
		_create_array2d(H + 1, W + 1, func (): return PackedByteArray([0, 0, 0])),
		_create_array2d(H + 1, W + 1, func (): return PackedByteArray([0, 0, 0]))
	]
	for z in D:
		add_slice(z)

func add_slice(z: float):
	var grid = _create_array2d(H, W, func (): return randi() % 5 == 0)
	for y in H:
		for x in W:
			if (
				x > W / 2.0 - TUNNEL_SIZE / 2.0 and
				x < W / 2.0 + TUNNEL_SIZE / 2.0 and
				y > H / 2.0 - TUNNEL_SIZE / 2.0 and
				y < H / 2.0 + TUNNEL_SIZE / 2.0
			):
				grid[y][x] = 0
	var edges_grid_slice = _create_array2d(H + 1, W + 1, func (): return PackedByteArray([0, 0, 0]))
	edges.pop_front()
	edges.push_back(edges_grid_slice)

	for y in H:
		for x in W:
			if grid[y][x]:
				# Determine which new edge meshes to instantiate
				if edges[0][y][x][0] == 0: edges[0][y][x][0] = 1
				if edges[0][y][x][1] == 0: edges[0][y][x][1] = 1
				if edges[0][y][x][2] == 0: edges[0][y][x][2] = 1
				if edges[0][y + 1][x][0] == 0: edges[0][y + 1][x][0] = 1
				if edges[0][y + 1][x][2] == 0: edges[0][y + 1][x][2] = 1
				if edges[0][y][x + 1][1] == 0: edges[0][y][x + 1][1] = 1
				if edges[0][y][x + 1][2] == 0: edges[0][y][x + 1][2] = 1
				if edges[0][y + 1][x + 1][2] == 0: edges[0][y + 1][x + 1][2] = 1
				if edges[1][y][x][0] == 0: edges[1][y][x][0] = 1
				if edges[1][y][x][1] == 0: edges[1][y][x][1] = 1
				if edges[1][y + 1][x][0] == 0: edges[1][y + 1][x][0] = 1
				if edges[1][y][x + 1][1] == 0: edges[1][y][x + 1][1] = 1

	# Instantiate new edge meshes
	for slice_index in 2:
		for y in H + 1:
			for x in W + 1:
				var cell_edges = edges[slice_index][y][x]
				for ax in 3:
					if cell_edges[ax] != 1:
						continue

					var t: Transform3D
					if ax == 0:
						t = Transform3D(Basis(), Vector3(x + 0.5 - 0.5 * W, -y + 0.5 * H, -z - slice_index))
					elif ax == 1:
						t = Transform3D(Basis(Vector3.BACK, 0.5 * PI), Vector3(x - 0.5 * W, -y - 0.5 + 0.5 * H, -z - slice_index))
					else:
						t = Transform3D(Basis(Vector3.UP, 0.5 * PI), Vector3(x - 0.5 * W, -y + 0.5 * H, -z - 0.5 - slice_index))
					$MultiMeshInstance3D.add_instance(t)

					cell_edges[ax] = 2

func _process(delta: float) -> void:
	# Camera spiral movement
	camera_spiral_t = fmod(camera_spiral_t + CAMERA_SPIRAL_SPEED * delta, 1.0)
	$Camera3D.position.x = CAMERA_SPIRAL_RADIUS * cos(camera_spiral_t * 2 * PI)
	$Camera3D.position.y = CAMERA_SPIRAL_RADIUS * sin(camera_spiral_t * 2 * PI)

	# Camera roll
	camera_roll_t = fmod(camera_roll_t + CAMERA_ROLL_SPEED * delta, 1.0)
	$Camera3D.rotation.z = CAMERA_ROLL_MAGNITUDE * sin(camera_roll_t * 2 * PI)

	# Camera forward movement
	$Camera3D.position.z -= CAMERA_SPEED * delta
	if $Camera3D.position.z <= -1.0:
		# Moved one unit -- remove old geometry in the back and add new geometry in the front
		$Camera3D.position.z += 1.0
		$MultiMeshInstance3D.step()
		add_slice(D - 1)

func _create_array2d(rows: int, cols: int, initializer: Callable) -> Array:
	var result = []
	for y in rows:
		var row = []
		for x in cols:
			row.push_back(initializer.call())
		result.push_back(row)
	return result
