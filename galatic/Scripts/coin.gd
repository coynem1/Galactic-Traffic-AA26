extends Node3D

const SPIN_SPEED: float = 2

@onready var mesh: MeshInstance3D = $MeshInstance3D

signal collected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.rotate_y(SPIN_SPEED * delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		collected.emit()
		queue_free()
