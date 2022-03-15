extends KinematicBody

var can_move = true
signal dead

var attack = preload("res://sounds/pultergiest/pultergiestattack.ogg")
var hurt = preload("res://sounds/pultergiest/pultergiestpain.ogg")
var die = preload("res://sounds/pultergiest/pultergiestdeath.ogg")
var type = "pultergiest"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func encounter():
	can_move = false
	$AudioStreamPlayer3D.playing = false
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func attack():
	$AnimationPlayer.play("attack")
	$AudioStreamPlayer.stream = attack
	$AudioStreamPlayer.play()
	
func hurt():
	$AnimationPlayer.play("hurt")
	$AudioStreamPlayer.stream = hurt
	$AudioStreamPlayer.play()

func die():
	$AnimationPlayer.play("dead")
	$AudioStreamPlayer.stream = die
	$AudioStreamPlayer.play()
	
func change_can_move(blcan_move):
	can_move = blcan_move
	if can_move == false:
		$AudioStreamPlayer3D.playing = false
	else:
		$AudioStreamPlayer3D.playing = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dead":
		emit_signal("dead")
		queue_free()
