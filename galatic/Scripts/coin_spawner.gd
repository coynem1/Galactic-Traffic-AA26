extends Node3D

@export var coin_scene: PackedScene
@export_range(1, 100) var max_coins: int = 10
@export_range(0, 100, 0.1) var spawn_interval: float = 2.0
@export_range(0, 200, 0.1) var spawn_width: float = 40.0
@export_range(0, 200, 0.1) var spawn_length: float = 40.0

signal collected_coin
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer < spawn_interval:
		return
	timer = 0.0
	
	if get_child_count() < max_coins:
		spawn_coin()

func spawn_coin() -> void:
	var coin = coin_scene.instantiate()
	add_child(coin)
	
	coin.connect("collected", _on_collect)
	coin.global_position = Vector3(
		randf_range(-spawn_width / 2, spawn_width / 2),
		0.0,
		randf_range(-spawn_length / 2, spawn_length / 2)
	)

func _on_collect():
	collected_coin.emit()
