class_name Wormhole
extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var portal: MeshInstance3D = $portal

signal body_teleported(body: Node3D)
var enabled: bool = true:
	set(value):
		enabled = value
		enable(value)
		

func enable(value:bool):
	area_3d.monitorable = value
	area_3d.monitoring = value
	portal.visible = value

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		body_teleported.emit(body)
		body.teleport_ship()
