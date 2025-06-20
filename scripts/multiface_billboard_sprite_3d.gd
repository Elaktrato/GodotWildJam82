@tool
extends Node3D
class_name OmnidirectionalSprite3D

@export var _front: SpriteBase3D
@export var _front_side: SpriteBase3D
@export var _side: SpriteBase3D
@export var _back_side: SpriteBase3D
@export var _back: SpriteBase3D

@export var flip_h: bool = false

var _camera: Camera3D:
	get:
		return get_viewport().get_camera_3d()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_camera || !_front || !_front_side || !_side || !_back_side || !_back:
		return

	var y_diff = _camera.global_rotation.y - global_rotation.y
	var sector = 4 + int((y_diff) / (PI / 4.0))
	sector %= 8
	# print(sector + 4)

	_front.visible = false
	_front_side.visible = false
	_side.visible = false
	_back_side.visible = false
	_back.visible = false

	var sprites: Array = [_front, _front_side, _side, _back_side, _back, _back_side, _side, _front_side]
	var h_flips: Array = [false, true, true, true, false, false, false, false]
	sprites[sector].visible = true
	sprites[sector].flip_h = h_flips[sector]
