class_name Wormhole
extends Node3D

const PORTAL_SIZE: float = 0.4

@onready var area_3d: Area3D = $Area3D
@onready var portal: MeshInstance3D = $portal

signal body_teleported(body: Node3D)
var current_portal_size: float = 0
var enabled: bool = true:
	set(value):
		enabled = value
		enable(value)

func enable(value:bool):
	if value:		
		set_size(PORTAL_SIZE)
	else:
		set_size(0)
	
	area_3d.monitorable = value
	area_3d.monitoring = value
	portal.visible = value

func set_size(value: float):
	var mat := portal.get_active_material(0)
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val),
		0.0,  # from
		value,  # to
		1.0   # duration in seconds
	)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		body_teleported.emit(body)
		body.teleport_ship()
