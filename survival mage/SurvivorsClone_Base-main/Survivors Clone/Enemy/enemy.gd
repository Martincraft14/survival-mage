extends CharacterBody2D

@export var movent_speed = 20.0

@export var hp = 10

@export var knockback_recovery = 3
var knockback = Vector2.ZERO

var death_animation = preload("res://Enemy/explosion.tscn")
#@onready obtiene un valor cuand se carga el nodo(en este caso enemy)
#Se usa para referenciar otros nodos

@onready var sprite = $AnimatedSprite2D

#Get tree usa todos los nodos, esta por encima del nodo del mundo, seria como cojer
#le nodod raiz del proyecto
#Get first node in group nos da el grupo de player, dentro de los nodos del juego
#como solo est ael grupo player, el enemigo sabe que es el jugador 
@onready var player = get_tree().get_first_node_in_group("player")

@onready var sound_hit = $soundHit



#Para poder borrar del array de hitonce
signal remove_from_array(object)

#_delta, no suamos delta
func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	#Gloval position es tambien un Vecotr2
	#Y cada vez que se procesa este funcion, se calcula la posicion global del 
	#enemigo en comparacion con la del jugador, y el enemigo se mueve hacia esa direccion
	#gracias a direction_to, que tambien devuleve un Vecotr2 apuntando hacia el jugador
	#direction_to esta normalizado por lo que no hay que normalizarlo
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movent_speed
	velocity += knockback  
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < 0.1:
		sprite.flip_h = false
	
	#Como siempre se estara moviendo no hace falta hacer la logica
	sprite.play("walking")


func death():
	
	emit_signal("remove_from_array", self)
	var enemy_death = death_animation.instantiate()#Inicializamos la muerte
	enemy_death.scale = sprite.scale #Hacemos que tenga el mismo tamaño que nuestro enemigo
	enemy_death.global_position = global_position # la posicion
	#la spawneamos en el padre, porque enemy va ha dejar de existir el proximo frmae
	get_parent().call_deferred("add_child", enemy_death)
	
	queue_free()
	
	
#La señal que mandamos desde hurtbox la cual tramita el daño y knockback
func _on_hurt_box_hurt(damage, angle, knockback_amount):
	print("--- SEÑAL RECIBIDA ---")
	print("Daño: ", damage)
	print("Ángulo: ", angle)
	print("Knockback_amount: ", knockback_amount)
	
	
	
	hp -= damage
	#el vecot por el que se empuja con el angulo desde el cual viene el ataque 
	knockback = angle * knockback_amount
	print("Knockback calculado: ", knockback)
	
	if hp <= 0:
		death()
	else:
		sound_hit.play()
