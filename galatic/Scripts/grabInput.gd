extends Node3D

@export var grab_size: float = 1.0
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D

signal grabbing(value: bool)
var selected: bool = false

func _ready() -> void:
	collision_shape_3d.scale *= grab_size

func _input(event: InputEvent) -> void:
	if not selected:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			grabbing.emit(false)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = true
			grabbing.emit(true)
