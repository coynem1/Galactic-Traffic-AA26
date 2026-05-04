extends Node3D

@onready var wormhole_1: Wormhole = $Wormhole
@onready var wormhole_2: Wormhole = $Wormhole2
@onready var wormhole_3: Wormhole = $Wormhole3
@onready var wormhole_4: Wormhole = $Wormhole4

@export_range(0, 40, 0.01) var spawn_x_width: float = 20
@export_range(0, 40, 0.01) var spawn_z_width: float = 20

signal body_teleported(body: Node3D)
var wormholes: Array = []
var wormhole_state: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wormholes = [
		wormhole_1,
		wormhole_2,
		wormhole_3,
		wormhole_4
	]
	
	for w in wormholes:
		wormhole_state[w] = false
		w.connect("body_teleported", _on_wormhole_body_teleported)
		w.enable(false)
		
	_open_wormhole()

func _open_wormhole() -> void:
	for w in wormholes:
		if wormhole_state[w]:
			continue
		
		wormhole_state[w] = true
		w.position = Vector3(randf_range(-spawn_x_width/2, spawn_x_width/2), 0, randf_range(-spawn_z_width/2, spawn_z_width/2))
		w.enable(true)
		return


func _on_wormhole_body_teleported(body: Node3D) -> void:
	body_teleported.emit(body)

# Randomise portals
func _on_timer_timeout() -> void:
	for w in wormholes:
		if wormhole_state[w]:
			w.enable(false)
			wormhole_state[w] = false

	await get_tree().create_timer(2.0).timeout
	_open_wormhole()
		
