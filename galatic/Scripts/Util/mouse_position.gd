extends Node

'''
This script calculates the position of where the mouse is on the flat X, Z plane
Used by any class.
'''
	
func get_mouse_world_position(offset: Vector3) -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var plane = Plane(Vector3(0, 1, 0), offset.z)
	
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var intersection = plane.intersects_ray(from, dir)
	
	return intersection if intersection else offset
