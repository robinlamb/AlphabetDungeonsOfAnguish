extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayMusic.play_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_btnPlay_pressed():
	get_tree().change_scene("res://CharacterName.tscn")


func _on_btnInstructions_pressed():
	get_tree().change_scene("res://Instructions.tscn")


func _on_btnCredits_pressed():
	get_tree().change_scene("res://Credits.tscn")
