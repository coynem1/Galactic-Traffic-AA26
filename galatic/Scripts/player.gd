extends "res://Scripts/boid.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()  # runs the parent boid setup
	seekEnabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		seekTarget = get_mouse_world_position()
	else:
		seekTarget = global_position  # seek own position = no force applied
	super._physics_process(delta)

func get_mouse_world_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var plane = Plane(Vector3(0, 0, 1), global_transform.origin.z)
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var intersection = plane.intersects_ray(from, dir)
	return intersection if intersection else global_transform.origin
