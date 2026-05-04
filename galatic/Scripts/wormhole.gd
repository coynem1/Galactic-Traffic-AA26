class_name Wormhole
extends Node3D

const PORTAL_SIZE: float = 0.4

@onready var area_3d: Area3D = $Area3D
@onready var portal: MeshInstance3D = $portal

signal body_teleported(body: Node3D)
var current_portal_size: float = 0

func _ready() -> void:
	portal.visible = false
	# Set shader radius to 0 directly without tweening
	var mat := portal.get_active_material(0)
	mat.set_shader_parameter("radius", 0)

func enable(value:bool):
	area_3d.monitorable = value
	area_3d.monitoring = value
	portal.visible = true
	
	if value:		
		set_size(PORTAL_SIZE)
	else:
		set_size(0)
	

func set_size(value: float):
	var mat := portal.get_active_material(0)
	var tween: Tween = create_tween()
	
	#print("Changing: ", value, " Size: ", current_portal_size)
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(val): mat.set_shader_parameter("radius", val),
		current_portal_size,  # from
		value,  # to
		1.0   # duration in seconds
	)
	
	# Hide only after shrink finishes
	if value == 0:
		tween.tween_callback(func(): portal.visible = false)
	current_portal_size = value

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		body_teleported.emit(body)
		body.teleport_ship()
