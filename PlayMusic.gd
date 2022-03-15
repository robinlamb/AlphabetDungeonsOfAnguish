extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func play_music():
	$AudioStreamPlayer.playing = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func turn_off_music():
	$AudioStreamPlayer.playing = false
