extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var poisoned = false
export var max_speed = 8
var velocity = Vector3.ZERO
var can_move = true
var battle_in_progress = false

var attack1 = preload("res://sounds/player/attack.ogg")
var attack2 = preload("res://sounds/player/attack2.ogg")
var dead1 = preload("res://sounds/player/dead.ogg")
var dead2 = preload("res://sounds/player/dead2.ogg")
var drinkpotion = preload("res://sounds/player/drinkpotion.ogg")
var healthrestored = preload("res://sounds/player/healthrestored.ogg")
var vomit_sound = preload("res://sounds/player/roguelikesick.ogg")
var hurt1 = preload("res://sounds/player/hurt.ogg")
var hurt2 = preload("res://sounds/player/hurt2.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	idle()
	
func _physics_process(delta):
	var input_vector = get_input_vector()
	apply_movement(input_vector)
	if can_move:
		velocity = move_and_slide(velocity, Vector3.UP)
	
	
func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	input_vector.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	return input_vector.normalized()
	

func apply_movement(input_vector):
	velocity.x = input_vector.x * max_speed
	velocity.z = input_vector.z * max_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_random_sound():
	randomize()
	return (randi() % 2)
	
func idle():
	$AnimatedSprite3D/EyebrowLeft.visible = false
	$AnimatedSprite3D/EyebrowRight.visible = false
	$AnimatedSprite3D/EyeLeft.play("default")
	$AnimatedSprite3D/EyeRight.play("default")
	$AnimationPlayer.play("idle")
	if poisoned:
		$AnimatedSprite3D/Mouth.play("frown")
		$AnimatedSprite3D.play("poisoned")
	else:
		$AnimatedSprite3D/Mouth.play("default")
		$AnimatedSprite3D.play("default")

func restore_health():
	$heartparticles.restart() 
	$AudioStreamPlayer.stream = healthrestored
	$AudioStreamPlayer.play()
	
func drink_potion():
	$AnimatedSprite3D/EyebrowLeft.visible = true
	$AnimatedSprite3D/EyebrowRight.visible = true
	$AnimatedSprite3D/EyeLeft.play("pained")
	$AnimatedSprite3D/EyeRight.play("pained")
	$AnimatedSprite3D/Mouth.play("smallopen")
	$AnimationPlayer.play("drink")
	$AudioStreamPlayer.stream = drinkpotion
	$AudioStreamPlayer.play()
	
	
func hurt():
	$AnimatedSprite3D/EyebrowLeft.visible = true
	$AnimatedSprite3D/EyebrowRight.visible = true
	$AnimatedSprite3D/EyeLeft.play("pained")
	$AnimatedSprite3D/EyeRight.play("pained")
	$AnimatedSprite3D/Mouth.play("smallopen")
	$AnimationPlayer.play("hurt")
	var soundnum = get_random_sound()
	if soundnum == 1:
		$AudioStreamPlayer.stream = hurt1
	else:
		$AudioStreamPlayer.stream = hurt2
	$AudioStreamPlayer.play()

func attack():
	$AnimatedSprite3D/EyebrowLeft.visible = true
	$AnimatedSprite3D/EyebrowRight.visible = true
	$AnimatedSprite3D/Mouth.play("smallopen")
	$AnimationPlayer.play("attack")
	var soundnum = get_random_sound()
	if soundnum == 1:
		$AudioStreamPlayer.stream = attack1
	else:
		$AudioStreamPlayer.stream = attack2
	$AudioStreamPlayer.play()

func victory():
	idle()
	$AnimatedSprite3D/Mouth.play("grin")

func die():
	$AnimatedSprite3D/EyebrowLeft.visible = true
	$AnimatedSprite3D/EyebrowRight.visible = true
	$AnimatedSprite3D/Mouth.play("smallopen")
	$AnimatedSprite3D/EyeLeft.play("dead")
	$AnimatedSprite3D/EyeRight.play("dead")
	$AnimationPlayer.play("die")
	var soundnum = get_random_sound()
	if soundnum == 1:
		$AudioStreamPlayer.stream = dead1
	else:
		$AudioStreamPlayer.stream = dead2
	$AudioStreamPlayer.play()
	
func gets_cured():
	poisoned = false
	idle()

func vomit():
	$VomitTimer.set_wait_time(2.0)
	$VomitTimer.start()
	$AudioStreamPlayer.stream = vomit_sound
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("sick")
	$AnimatedSprite3D/Mouth.play("straight")


func _on_VomitTimer_timeout():
	$VomitTimer.stop()
	$AnimationPlayer.play("vomiting")
	$AnimatedSprite3D/CheekLeft.visible = false
	$AnimatedSprite3D/CheekRight.visible = false
	$AnimatedSprite3D/CheekSpotLeft.visible = false
	$AnimatedSprite3D/CheekSpotRight.visible = false
	$AnimatedSprite3D/EyeLeft.play("pained")
	$AnimatedSprite3D/EyeRight.play("pained")
	$AnimatedSprite3D/Mouth.play("largeopen")
	$vomit.restart()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		$AnimatedSprite3D/Mouth.play("dead")
	if anim_name == "attack":
		idle()
	if anim_name == "vomiting":
		idle()
	if anim_name == "hurt":
		idle()
	if anim_name == "drink":
		idle()


func _on_StartBattleArea_body_entered(body):
	if not battle_in_progress:
		
		if body.is_in_group("enemies"):
			get_tree().call_group("game", "start_battle", body)
			battle_in_progress = true
