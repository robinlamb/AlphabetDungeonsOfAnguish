extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal dead
var can_move = true
var attack = preload("res://sounds/snake/snakeattack.ogg")
var die = preload("res://sounds/snake/snakedeath.ogg")
var type = "serpent"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_can_move(blcan_move):
	can_move = blcan_move
	if can_move == false:
		$AudioStreamPlayer3D.playing = false
	else:
		$AudioStreamPlayer3D.playing = true

func encounter():
	can_move = false
	$AnimationPlayer.play("idle")
	$AudioStreamPlayer3D.playing = false
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func attack():
	$AnimationPlayer.play("strike")
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func hurt():
	$AnimationPlayer.play("idle")
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()

func die():
	$AnimationPlayer.play("idle")
	$AudioStreamPlayer.stream = die
	$AudioStreamPlayer.play()
	$DeathTimer.set_wait_time(5.0)
	$DeathTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DeathTimer_timeout():
	emit_signal("dead")
	queue_free()
