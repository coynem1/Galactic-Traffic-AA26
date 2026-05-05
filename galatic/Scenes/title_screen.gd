extends Control

@onready var rules_panel = $VBoxContainer/RulesPanel
@onready var rules_label = $VBoxContainer/RulesPanel/Label
@onready var music = $Music

const RULES_TEXT = """ 
- Take control of the leader ship and guide their fleets through the portal to gain points!
- Leader ships are worth more and will teleport their follower ships with them!
- Avoid the flying asteroids!!!
"""

func _ready():
	rules_panel.visible = false
	rules_label.text = RULES_TEXT
	music.play()

func _on_how_to_play_pressed():
	rules_panel.visible = !rules_panel.visible # Toggle it on / off
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
