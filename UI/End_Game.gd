extends Control

func _ready():
	$Label.text = "Thanks for playing! Your score was " + str(Global.score) + "."

func _on_Play_pressed():
	Global.reset()
	var _scene = get_tree().changed_scene("res://Game.tscn")
