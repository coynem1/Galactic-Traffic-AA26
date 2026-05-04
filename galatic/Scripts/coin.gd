extends Node3D

const SPIN_SPEED: float = 2
const MIN_SCALE = 0.5
const MAX_SCALE = 1.0
const PULSE_SPEED = 2.0

@onready var mesh: MeshInstance3D = $MeshInstance3D

signal collected

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	var scale_factor = lerp(MIN_SCALE, MAX_SCALE, (sin(time * PULSE_SPEED) + 1.0) / 2.0)
	mesh.scale = Vector3(scale_factor, scale_factor, scale_factor)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		collected.emit()
		queue_free()
