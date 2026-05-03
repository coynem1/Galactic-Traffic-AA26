extends "res://Scripts/boid.gd"

var selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()  # runs the parent boid setup
	seekEnabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if selected:
		seekTarget = MouseUtil.get_mouse_world_position(global_position)
	else:
		seekTarget = global_position  # seek own position = no force applied
		
	super._physics_process(delta)


func _on_grabpoint_grabbing(value: bool) -> void:
	selected = value
