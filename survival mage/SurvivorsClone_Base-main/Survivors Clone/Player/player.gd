extends CharacterBody2D

#Cargamos el sprite cuando se carga el nodo dentro de una variable para poder usarla
@onready var sprite = $AnimatedSprite2D

var hp = 80

var movmentSpeed = 40.0


#ATTACKS
var iceSpear = preload("res://Player/Attacks/ice_spear.tscn") 

#ATTACKNODES
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer") 


#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1


#Enemy related(Los enemigos que estan cerca de nosotros)
var enemy_close = []




func _ready():
	attack()


#se procesa Cade 1/60 segundos
#Delta en 1s/ el frame rate
func _physics_process(delta: float):
	movement() 
	
#Comprueba la tecla y le asigan un valor
func movement():
	#1 si se aprite 0 sino
	#si aprieto derecha 1 si aprieto izquierda -1
	var x_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	#1 si se aprite 0 sino
	#si aprieto abajo 1 si aprieto arriba -1
	var y_move = Input.get_action_strength("down") - Input.get_action_strength("up")
	#Un vecotr para la direccion del jugador
	var mov = Vector2(x_move,y_move)
	
	#Como es un sprite animado hay que cambiar hacia que lado apunta dependiendo de si nos movemos a la
	#Izquierda o derecha, eso se hace con flip_h, que unicamente cambia hacia donde mira
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	
	#PARA LAS ANIMACIONES
	# si hay movimiento 
	if mov != Vector2.ZERO:
		#reproducir la animación de walking
		if sprite.animation != "walking":
			sprite.play("walking")
	else:
		# Si no hay movimiento, cambiar a la animación de idle
		if sprite.animation != "idle":
			sprite.play("idle")
		
	
	
	
	#Velocity -> hacia donde se dirigue el jugador, variable interna del propio motor
	
	#normalized hace que no te muevas mas rapido en diagonal que solo hacia un lado
	#Como multiplicamos el vector de movimeinto por 40(la velocidad del jugador)
	#Si pulsamos abajo e izquierda Vecotr2 seria(40x40), como es un vector eso hace que la diagonal sea
	#56.56, haciendonos mover mas rapido en diagonal. normalized coje cada vector y lo divide
	#entre la hipotenusa [V2(40x,40y) * (40/56.56)] lo que nos daria la velocidad
	#en diagonal de V2(28.28x,28.28y)
	
	velocity = mov.normalized()*movmentSpeed
	#Funcion propia del motor para le movimento de Body2D(el tipo de playerque estamos creando)
	move_and_slide()


#Conectamos la señal que envia la hurtBox para recibir el daño
func _on_hurt_box_hurt(damage, _angel, _knockback):
	hp -= damage
	
	#par ver por consola si funiona
	print(hp)



func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			
			

#Cargando la munición
func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()

#Disparando la munición
func _on_ice_spear_attack_timer_timeout() -> void:
	if icespear_ammo > 0:
		#creamos una lanza de hielo si hay municion
		var icespear_attack = iceSpear.instantiate()
		#la creamos en la posicion del jugador
		icespear_attack.position = position
		#elejimos un enemigo al azar 
		icespear_attack.target = get_random_target()
		#Le decimos a que nivel tenemos el ataque 
		icespear_attack.level = icespear_level
		#añadimos el child, la lanza d ehielo con un nivel y un objetivo
		add_child(icespear_attack)
		#Le quitamos 1 de municion 
		icespear_ammo -= 1
		#Si tenemos municion empezamos el attackTimer
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
			
func get_random_target():
	if enemy_close.size() > 0:
		#Elejimos un enemigo dentro del array de posibles targets y elejimos uno al azar para atacarlo
		#y devolvemos sus coordenadas globales para dirigir el ataque hacia esa posición
		return enemy_close.pick_random().global_position
	else:
		#Para que tenga algo hacia lo que atacar para que no sea null
		return Vector2.UP 

#ENEMY DETCTION AREA
func _on_enemy_detection_area_body_entered(body):
	#si no el enemigo no esta en el array de targets(enemy_close) cuando entra en la esfera de detecion lo añadimos
	if not enemy_close.has(body):
		enemy_close.append(body)

#ENEMY DETCTION AREA
func _on_enemy_detection_area_body_exited(body):
	#Cuando lo matamos lo sacamos del array
	if enemy_close.has(body):
		enemy_close.erase(body)
