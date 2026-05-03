extends Node3D

@onready var wormhole_1: Wormhole = $Wormhole
@onready var wormhole_2: Wormhole = $Wormhole2
@onready var wormhole_3: Wormhole = $Wormhole3
@onready var wormhole_4: Wormhole = $Wormhole4

@export_range(0, 40, 0.01) var spawn_x_width: float = 20
@export_range(0, 40, 0.01) var spawn_z_width: float = 20

signal body_teleported(body: Node3D)
var wormholes: Array = []
var opened: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wormholes = [
		wormhole_1,
		wormhole_2,
		wormhole_3,
		wormhole_4
	]
	opened = wormholes.map(func(_w): return false)
	
	for w in wormholes:
		w.connect("body_teleported", _on_wormhole_body_teleported)
		w.enable(false)
		
	_open_wormhole()

func _open_wormhole() -> void:
	for i in range(wormholes.size()):
		if opened[i]:
			continue
		
		opened[i] = true
		wormholes[i].position = Vector3(randf_range(-spawn_x_width/2, spawn_x_width/2), 0, randf_range(-spawn_z_width/2, spawn_z_width/2))
		wormholes[i].enable(true)
		return


func _on_wormhole_body_teleported(body: Node3D) -> void:
	body_teleported.emit(body)
