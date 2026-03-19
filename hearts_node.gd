extends Node3D

@export var num_hearts: int
@export var heart_size: float
@export var padding: float


const TEX_FULL: Texture2D = preload("res://media/heart_full_outlined.png")
const TEX_EMPTY: Texture2D = preload("res://media/heart_empty_outlined.png")

const BLINK_INTERVAL_SECONDS := 0.22


var sprites: Array[Sprite3D] = []
var num_full_hearts: int

func _ready() -> void:
	for i in num_hearts:
		var sprite = Sprite3D.new()
		sprite.pixel_size = heart_size / TEX_FULL.get_width()
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		sprite.position.x = (heart_size + padding) * i
		add_child(sprite)
		sprites.push_back(sprite)
	set_full_hearts(num_hearts)

func set_full_hearts(value: int):
	for i in num_hearts:
		sprites[i].texture = TEX_FULL if i < value else TEX_EMPTY
	num_full_hearts = value

## Starts animation and schedules decrease of num_full_hearts.
func loose_heart():
	var index = num_full_hearts - 1
	sprites[index].visible = false

	var tween = get_tree().create_tween()
	tween.tween_callback(func (): sprites[index].visible = true).set_delay(BLINK_INTERVAL_SECONDS)
	tween.tween_callback(func (): sprites[index].visible = false).set_delay(BLINK_INTERVAL_SECONDS)
	tween.tween_callback(func (): sprites[index].visible = true).set_delay(BLINK_INTERVAL_SECONDS)
	tween.tween_callback(func ():
		sprites[index].visible = false
		set_full_hearts(num_full_hearts - 1)
	).set_delay(BLINK_INTERVAL_SECONDS)
	tween.tween_callback(func (): sprites[index].visible = true).set_delay(BLINK_INTERVAL_SECONDS)

func _process(_delta: float) -> void:
	_reset_padding()

## Repositions based on portrait/landscape mode.
func _reset_padding():
	var viewport_size = get_viewport().size
	position.x = 0.94 if viewport_size.y > viewport_size.x else 1.15
