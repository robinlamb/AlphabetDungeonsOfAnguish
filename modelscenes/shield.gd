extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		$AudioStreamPlayer.playing = true
		$Timer.set_wait_time(.5)
		get_tree().call_group("game", "shield_found")
		$Timer.start()


func _on_Timer_timeout():
	queue_free()
