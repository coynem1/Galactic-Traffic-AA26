extends Control

@onready var points_value: Label = $VBoxContainer/pointsValue

var points: int = 0:
	set(value):
		points = value
		points_value.text = str(points)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_formation_spawner_add_points(value: int) -> void:
	points += value


func _on_coin_spawner_collected_coin() -> void:
	points += PointsUtil.COIN_POINTS_VALUE
