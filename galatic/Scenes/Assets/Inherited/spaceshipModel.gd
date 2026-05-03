extends Node3D

@onready var model: MeshInstance3D = $craft_speederA

enum materials {
	Wings = 0,
	Body = 1,
	Glass = 2,
	Details = 3
}

# General public setter
func set_colour(colour: Color, full: bool):
	if full:
		_change_part_colour(materials.Body, colour)
		_change_part_colour(materials.Wings, colour)
	else:
		_change_part_colour(materials.Body, colour)
		_change_part_colour(materials.Wings, Color(1.0, 1.0, 1.0, 1.0))

func _change_part_colour(surface: materials, colour: Color):
	var new_mat = StandardMaterial3D.new()
	new_mat.albedo_color = colour
	new_mat.roughness = 0.2
	model.set_surface_override_material(surface, new_mat)
	
