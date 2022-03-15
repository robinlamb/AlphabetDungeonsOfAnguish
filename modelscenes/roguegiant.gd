extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var attack = preload("res://sounds/giant/giantattack.ogg")
var die = preload("res://sounds/giant/giantdeath.ogg")
var hurt = preload("res://sounds/giant/giantpain.ogg")
var encounter = preload("res://sounds/giant/giantencounter.ogg")
var can_move = true
var type = "giant"
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func encounter():
	can_move = false
	$AudioStreamPlayer3D.playing = false
	$AudioStreamPlayer.stream = encounter
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
