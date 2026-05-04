extends Control

@onready var dialog_label = $HBoxContainer/PanelContainer/VBoxContainer/DialogText
@onready var face = $HBoxContainer/AnimatedSprite2D

func show_dialog(text: String, anim: String = "idle"):
	visible = true
	dialog_label.text = text
	face.play(anim)

func hide_dialog():
	visible = false
	face.stop()
