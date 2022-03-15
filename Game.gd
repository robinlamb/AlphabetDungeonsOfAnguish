extends Spatial

var current_level

var pultergiest = preload("res://modelscenes/roguepultergiest.tscn")
var giant = preload("res://modelscenes/roguegiant.tscn")
var serpent = preload("res://modelscenes/snake.tscn")
var bat = preload("res://modelscenes/rougebat.tscn")
var wallChunk = preload("res://modelscenes/SlideableWallChunk.tscn")
var wallChunkLong = preload("res://modelscenes/SlideableWallChunkLong.tscn")
var key = preload("res://fonts/key.tscn")
var stairs = preload("res://modelscenes/stairs.tscn")
var potion = preload("res://modelscenes/potion.tscn")
var antidote = preload("res://modelscenes/antidote.tscn")
var gold = preload("res://modelscenes/roguemoney.tscn")
var shield = preload("res://modelscenes/shield.tscn")

var item_x_coordinates = [50.0, 29.0, 13.0, -5, -20.0, -43.0]
var item_z_coordinate
var item_spots_filled = [false, false, false, false, false, false]

var wall_instance
var wall_2_instance

var item_instance

var monster_instance

var potion_num = 0
var antidote_num = 0
var has_key = false
var has_shield = false

var player_health = 50
var snake_health = 15
var giant_health = 30
var pultergiest_health = 20
var bat_health = 10
var player_damage
var enemy_damage
var gold_collected = 0
var current_enemy
var current_enemy_health = 10

func _ready():
	$Spatial.can_move = false
	$Spatial.idle()
	current_level = 1
	setup_floor()
	var dialog = Dialogic.start("introduction")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func _physics_process(delta):
	
	$lblHealth.text = "Health: " + str(player_health)
	$lblGoldCollected.text = "Gold Collected: " + str(gold_collected)
	$lblPotions.text = "Potions: " + str(potion_num)
	$lblAntidotes.text = "Antidotes: " + str(antidote_num)

func fade_screen():
	$ScreenFade/AnimationPlayer.play("screenfade")

func key_found():
	has_key = true
	$lblKeyFound.visible = true
	get_tree().call_group("items", "key_found")

func shield_found():
	$Spatial.can_move = false
	has_shield = true
	get_tree().call_group("enemies", "can_move", false)
	$Spatial.victory()
	$DungeonMusic.playing = false
	$WinGame.playing = true
	var dialog = Dialogic.start("tlShieldFound")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func calculatePlayerDamage(enemy):
	var damage
	randomize()
	match(enemy):
		"bat":
			damage = randi() % 2 + 2
		"pultergiest":
			damage = randi() % 4 + 2
		"serpent":
			damage = randi() % 5 + 2
		"giant":
			damage = randi() % 7 + 4
		"vomited":
			damage = randi() % 6 + 2
			
	return damage

func calculateGold(enemy):
	var gold
	randomize()
	match(enemy):
		"bat":
			gold = randi() % 300 + 100
			
		"pultergiest":
			gold = randi() % 500 + 100
			
		"serpent":
			gold = randi() % 700 + 100
		
		"giant":
			gold = randi() % 1000 + 200
	
	return gold
		
		
func calculateEnemyDamage():
	var damage
	randomize()
	if $Spatial.poisoned:
		damage = randi() % 5 + 2
	else:
		damage = randi() % 7 + 3
	return damage

func add_potion():
	potion_num += 1
	$Spatial.can_move = false
	get_tree().call_group("enemies", "change_can_move", false)
	var dialog = Dialogic.start('tlPotionFound')
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	dialog.connect('timeline_end', self, 'unpause')
	add_child(dialog)

func unpause(timeline_name):
	$Spatial.can_move = true
	get_tree().call_group("enemies", "change_can_move", true)

func add_antidote():
	antidote_num += 1
	$Spatial.can_move = false
	get_tree().call_group("enemies", "change_can_move", false)
	var dialog = Dialogic.start('tlAntidoteFound')
	dialog.connect('timeline_end', self, 'unpause')
	add_child(dialog)
	
func add_money(amount):
	gold_collected += amount
	Dialogic.set_variable("dlGoldAmount", amount)
	$Spatial.can_move = false
	get_tree().call_group("enemies", "change_can_move", false)
	Dialogic.set_variable("dlHasItems", "true")
	var dialog = Dialogic.start('tlGoldFound')
	dialog.connect('timeline_end', self, 'unpause')
	add_child(dialog)

func player_attack():
	get_tree().call_group("player", "attack")
	var dialog = Dialogic.start("tlPlayerAttacks")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func enemy_takes_damage(enemy):
	Dialogic.set_variable("dlEnemyDamage", enemy_damage)
	enemy.hurt()
	var dialog = Dialogic.start("tlEnemyDamage")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func enemy_dies(enemy):
	enemy.die()
	$FadeBattleMusic.play("fade")
	
func enemy_dodges(enemy):
	var dialog = Dialogic.start("tlEnemyDodges")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func enemy_attacks():
	current_enemy.attack()
	var dialog = Dialogic.start("tlEnemyAttack")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")
	
func decide_outcome_enemy_attack():
	randomize()
	var dodge = 1
	if (randi() % 3 == dodge):
		player_dodges()
	else:
		player_damage = calculatePlayerDamage(current_enemy.type)
		Dialogic.set_variable("dlPlayerDamage", player_damage)
		player_health -= player_damage
		if player_health < 0:
			player_health = 0
		
		if player_health <= 0:
			player_dies()
		else:
			player_takes_damage()
			

func player_turn():
	get_tree().call_group("player", "idle")
	var dialog = Dialogic.start("tlPlayerTurn")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func dialog_listener(string):
	match string:
		"useitem":
			if potion_num == 0:
				$ItemMenu/btnPotions.disabled = true
			else:
				$ItemMenu/btnPotions.disabled = false
			if antidote_num == 0:
				$ItemMenu/btnAntidotes.disabled = true
			else:
				$ItemMenu/btnAntidotes.disabled = false
				
			$ItemMenu/lblAntidotes.text = "Antidotes: " + str(antidote_num)
			$ItemMenu/lblPotions.text = "Potions: " + str(potion_num)
			$ItemMenu.visible = true
		"attack":
			player_attack()
		"restartgame":
			get_tree().reload_current_scene()
		"started":
			$Spatial.can_move = true
		"poisoned":
			$Spatial.poisoned = true
			$Spatial/AnimatedSprite3D.play("poisoned")
			$Spatial.idle()
		"potiondrank":
			decide_outcome_potion()
		"enemyattacks":
			decide_outcome_enemy_attack()
		"playerattacked":
			decide_outcome_player_attack()
		"antidotedrank":
			decide_outcome_antidote()
		"vomited":
			decide_outcome_vomits()
		"enemyturn":
			enemy_attacks()
		"tryagain":
			get_tree().reload_current_scene()
	
func decide_outcome_player_attack():
	randomize()
	var dodge = 1
	if (randi() % 3 == dodge):
		enemy_dodges(current_enemy)
	else:
		enemy_damage = calculateEnemyDamage()
		current_enemy_health -= enemy_damage
		Dialogic.set_variable("dlEnemyDamage", enemy_damage)
		
		if current_enemy_health <= 0:
			enemy_dies(current_enemy)
		else:
			enemy_takes_damage(current_enemy)
	
func victory():
	get_tree().call_group("player", "victory")
	var dialog = Dialogic.start("tlPlayerWins")
	add_child(dialog)
	$AudioStreamPlayer.play()

func player_dodges():
	get_tree().call_group("player", "idle")
	var dialog = Dialogic.start("tlPlayerDodges")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func player_takes_damage():
	get_tree().call_group("player", "hurt")
	var dialog = Dialogic.start("tlPlayerDamage")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func player_dies():
	get_tree().call_group("player", "die")
	$BattleMusic.playing = false
	var dialog = Dialogic.start("tlPlayerDies")
	add_child(dialog)
	$MusicDeath.play()
	dialog.connect("dialogic_signal", self, "dialog_listener")

func player_drinks_potion():
	get_tree().call_group("player", "drink_potion")
	var dialog = Dialogic.start("tlPotion")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func players_health_restored():
	player_health = 50
	get_tree().call_group("player", "restore_health")
	var dialog = Dialogic.start("tlHealthRestored")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func player_vomits():
	get_tree().call_group("player", "vomit")
	player_damage = calculatePlayerDamage("vomited")
	player_health -= player_damage
	Dialogic.set_variable("dlPlayerDamage", player_damage)
	var dialog = Dialogic.start("tlPlayerVomits")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")
	
func decide_outcome_potion():
	if $Spatial.poisoned:
		player_vomits()
	else:
		players_health_restored()

func decide_outcome_vomits():
	if player_health <= 0:
		player_dies()
	else:
		decide_outcome_player_attack()
	
func player_drinks_antidote():
	get_tree().call_group("player", "drink_potion")
	var dialog = Dialogic.start("tlAntidote")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func decide_outcome_antidote():
	var dialog
	if $Spatial.poisoned:
		$Spatial.gets_cured()
		dialog = Dialogic.start("tlPoisonCured")
		Dialogic.set_variable("dlPoisoned", "false")
	else:
		$Spatial.idle()
		dialog = Dialogic.start("tlNothingHappens")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func start_battle(enemy):
	$Spatial.can_move = false
	get_tree().call_group("enemies", "change_can_move", false)
	$DungeonMusic.playing = false
	$BattleMusic.volume_db = 0.0
	$BattleMusic.playing = true
	current_enemy = enemy
	Dialogic.set_variable("dlEnemyName", enemy.type)
	
	match enemy.type:
		"bat":
			current_enemy_health = bat_health
			
		"pultergiest":
			current_enemy_health = pultergiest_health
			
		"serpent":
			current_enemy_health = snake_health
		
		"giant":
			current_enemy_health = giant_health
	
	enemy.encounter()
	var dialog = Dialogic.start("tlEncounter")
	add_child(dialog)
	dialog.connect("dialogic_signal", self, "dialog_listener")

func _on_AudioStreamPlayer_finished():
	if not has_shield:
		$Spatial.can_move = true
		$Spatial.idle()
		$Spatial.battle_in_progress = false
		get_tree().call_group("enemies", "change_can_move", false)
		$DungeonMusic.playing = true


func _on_btnBack_pressed():
	$ItemMenu.visible = false
	player_turn()


func _on_btnPotions_pressed():
	$ItemMenu.visible = false
	potion_num -= 1
	player_drinks_potion()


func _on_btnAntidotes_pressed():
	$ItemMenu.visible = false
	antidote_num -= 1
	player_drinks_antidote()

func setup_floor():
	var player_y_position = 1.6
	
	randomize()
	
	var player_location = randi() % 3
	
	match player_location:
		0:
			$Spatial.transform.origin = Vector3(41.0, player_y_position, -15)
		1:
			$Spatial.transform.origin = Vector3(-4, player_y_position, -15)
		2:
			$Spatial.transform.origin = Vector3(12, player_y_position, -15)
	
	randomize()
	
	var type_wall = randi() % 2
	var wall_z
	
	if type_wall == 0:
		wall_instance = wallChunk.instance()
		wall_z = 9.3
		
	else:
		wall_instance = wallChunkLong.instance()
		wall_z = 7.2
	
	add_child(wall_instance)
	
	randomize()
	
	var wall_location = randi() % 2
	
	if wall_location == 0:
		wall_instance.transform.origin= Vector3(21.0, 0.0, wall_z)
	else:
		wall_instance.transform.origin = Vector3(0.0, 0.0, wall_z)
	
	randomize()
	
	type_wall = randi() % 2	
	if type_wall == 0:
		wall_2_instance = wallChunk.instance()
		wall_z = 9.3
		
	else:
		wall_2_instance = wallChunkLong.instance()
		wall_z = 7.2
	
	add_child(wall_2_instance)
	
	randomize()
	
	wall_location = randi() % 2
	
	if wall_location == 0:
		wall_2_instance.transform.origin = Vector3(-12, 0.0, wall_z)
	else:
		wall_2_instance.transform.origin = Vector3(-27, 0.0, wall_z)
	
	if current_level < 5:
		place_item("stairs", true)
		place_item("key", true)	
		
	else:
		place_item("shield", true)
	
	randomize()
	
	var potion_here = randi() % 2
	
	if potion_here == 0:
		place_item("potion", false)
		
	randomize()
	
	var antidote_here = randi() % 2
	
	if antidote_here == 0:
		place_item("antidote", false)
	
	randomize()
	
	var gold_here = randi() % 3
	
	if gold_here == 0:
		place_item("gold", true)
	
	
	

func place_item(item_type, has_guardian):
	
	var pultergiest_y_position = 1.0
	var bat_y_position = 4.0
	var monster_y_coordinate
	var monster_x_coordinate
	var monster_z_coordinate
	
	randomize()
	var item_z_coordinate = float(randi() % 16 + 4)
	
	randomize()
	
	var random_slot = randi() % 6
	
	while item_spots_filled[random_slot] == true:
		randomize()
		random_slot = randi() % 6
	
	item_spots_filled[random_slot] = true	
	var item_x_coordinate = item_x_coordinates[random_slot]
	
	var item_y_coordinate
	
	match item_type:
		"stairs":
			item_instance = stairs.instance()
			item_y_coordinate = 0.0
			
		"key":
			item_instance = key.instance()
			item_y_coordinate = 1.0
		"potion":
			item_instance = potion.instance()
			item_y_coordinate = 0.0
			print("potion")
			
		"antidote":
			item_instance = antidote.instance()
			item_y_coordinate = 0.0
			print("antidote")
			
		"gold":
			item_instance = gold.instance()
			item_y_coordinate = 0.0
			print("gold")
		"shield":
			print("ran")
			item_instance = shield.instance()
			item_y_coordinate = 1.0
	
	
	add_child(item_instance)
	
	item_instance.transform.origin = Vector3(item_x_coordinate, item_y_coordinate, item_z_coordinate)	
	
	if has_guardian:
		var random_type
		
		randomize()
		match current_level:
			1: 
				random_type = 0
			2: 
				random_type = randi() % 2
			3:
				random_type = randi() % 3
				
			4: random_type = randi() % 4
			
			5: random_type = randi() % 2 + 2
			
		print(random_type)
		
		match random_type:
			0:
				monster_instance = bat.instance()
				monster_y_coordinate = bat_y_position
			1:
				monster_instance = pultergiest.instance()
				monster_y_coordinate = pultergiest_y_position
			2:
				monster_instance = serpent.instance()
				monster_y_coordinate = 0.0
			3:
				monster_instance = giant.instance()
				monster_y_coordinate = 0.0
		
		add_child(monster_instance)
		monster_instance.connect("dead", self, "victory")
			
		monster_x_coordinate = item_x_coordinate + 1
		monster_z_coordinate = item_z_coordinate - 4
		print(monster_x_coordinate)
		print(monster_y_coordinate)
		print(monster_z_coordinate)
		monster_instance.transform.origin = Vector3(monster_x_coordinate, monster_y_coordinate, monster_z_coordinate)

func change_levels():
	item_spots_filled = [false, false, false, false, false, false] 
	current_level += 1
	$lblLevel.text = "Level: " + str(current_level)
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("items", "queue_free")
	get_tree().call_group("moveablewalls", "queue_free")
	has_key = false
	$lblKeyFound.visible = false
	setup_floor()
	
