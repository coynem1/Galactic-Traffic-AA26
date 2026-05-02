extends MeshInstance3D

enum materials {
	Wings,
	Body,
	Glass,
	Details
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_status(false)

# Leaders are brighter
func update_status(leader: bool):
	if leader:
		_change_colour(materials.Body, Color.from_hsv(randf(), 1.0, 1.0))
	else:
		_change_colour(materials.Body, Color(0.536, 0.712, 0.84, 1.0))

func _change_colour(surface: materials, colour: Color):
	var mat = get_surface_override_material(surface).duplicate()
	set_surface_override_material(surface, mat)
	set_instance_shader_parameter("albedo_color", colour)
