extends Node3D

signal body_teleported(body: Node3D)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		body_teleported.emit(body)
		print("Teleported!")
