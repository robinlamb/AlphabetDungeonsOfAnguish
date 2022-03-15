extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var can_move = true
var attack = preload("res://sounds/batsounds/batattack.ogg")
var hurt = preload("res://sounds/batsounds/bathurt.ogg")
var type = "bat"
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func encounter():
	can_move = false
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func attack():
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func hurt():
	$AudioStreamPlayer.stream = hurt
	$AudioStreamPlayer.play()

func die():
	$AudioStreamPlayer.stream = hurt
	$AudioStreamPlayer.play()
	$AudioStreamPlayer3D.playing = false
	$DeathTimer.set_wait_time(2.0)
	$DeathTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_can_move(blcan_move):
	can_move = blcan_move
	if can_move == false:
		$AudioStreamPlayer3D.playing = false
	else:
		$AudioStreamPlayer3D.playing = true
	
func _on_DeathTimer_timeout():
	emit_signal("dead")
	queue_free()
