extends Area2D

#ESTE ATAQUE NO SALDRA DEL JUGADOR, SINO QUE IRA MOVIENDOSE POR LA PANTALLA PARA ATACANDO A LOS ENEMIGOS 
var level = 1
var hp  = 9999
var speed = 200
var damage  = 10
var knockback_amount = 10
var attack_size = 1.0
var path = 1 #La cantidad de ataques que realizara antes de pararse
var attack_speed = 4.0


var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_position = Vector2.ZERO

#Referencia a los dos tipos de sprites
var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirection = get_node("%ChangeDirection")
@onready var resetPostTimer = get_node("%ResetPostTimer")
@onready var snd_attack = $snd_javelin


signal remove_from_array(object)

func _ready():
	update_javelin()
	_on_reset_post_timer_timeout()


func update_javelin():
	level = player.javeline_level
	match level:
		1:
			hp = 9999
			speed = 200
			damage = 10
			knockback_amount = 100
			path = 1 
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1- player.spell_cooldown)
		2:
			hp = 9999
			speed = 200
			damage = 10
			knockback_amount = 100
			path = 2 
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1- player.spell_cooldown)
		3:
			hp = 9999
			speed = 200
			damage = 10
			knockback_amount = 100
			path = 3 
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1- player.spell_cooldown)
		4:
			hp = 9999
			speed = 200
			damage = 15
			knockback_amount = 120
			path = 3 
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1- player.spell_cooldown)
	
	
	
	scale = Vector2(1.0,1.0) * attack_size
	attackTimer.wait_time = attack_speed
	
func _physics_process(delta):
	if target_array.size() > 0:
		position += angle*speed*delta
	else:
		#angulo entra la javalina y el jugador
		var player_angle = global_position.direction_to(reset_position)
		#distancia entre la javalinay el jugador 
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 100
		position += player_angle * return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)
		


func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < path:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	angle = global_position.direction_to(target)
	changeDirection.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
func enable_attack(atk = true):
	if atk:
		collision.call("set","disabled", false)
		sprite.texture = spr_jav_atk
	else:
		collision.call("set","disabled", true)
		sprite.texture = spr_jav_reg
	
	
	
	
func _on_attack_timer_timeout() -> void:
	add_paths()
	
func _on_change_direction_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		changeDirection.stop()
		attackTimer.start()
		enable_attack(false)


#
func _on_reset_post_timer_timeout() -> void:
	var choose_direction = randi() % 4
	reset_position = player.global_position
	match choose_direction:
		0:
			reset_position.x += 50
		1:
			reset_position.x -= 50
		2:
			reset_position.y += 50
		3:
			reset_position.y += 50
			
		
		
		
		
		
		
		
		
		
		
		
