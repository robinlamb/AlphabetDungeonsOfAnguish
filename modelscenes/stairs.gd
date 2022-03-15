extends Spatial
var metal_clang = preload("res://sounds/items/shield.ogg")
var lock_unlocked = preload("res://sounds/items/doorCloseecho_1.ogg")
var stair_climb = preload("res://sounds/items/stairs.ogg")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var has_key = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func key_found():
	has_key = true




func _on_Timer_timeout():
	$lock.visible = false
	get_tree().call_group("game", "fade_screen")
	$tmrStairClimb.set_wait_time(1.0)
	$tmrStairClimb.start()
	$AudioStreamPlayer.set_stream(stair_climb)
	$AudioStreamPlayer.play()
	$Timer.stop()


func _on_lockarea_body_entered(body):
	if body.is_in_group("player") and has_key:
		$AudioStreamPlayer.set_stream(lock_unlocked)
		$AudioStreamPlayer.playing = true
		$Timer.set_wait_time(1.0)
		$Timer.start()
	if body.is_in_group("player") and has_key == false:
		$AudioStreamPlayer.set_stream(metal_clang)
		$AudioStreamPlayer.play()


func _on_tmrStairClimb_timeout():
	
	get_tree().call_group("game", "change_levels")
