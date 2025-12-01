extends CharacterBody2D

#Cargamos el sprite cuando se carga el nodo dentro de una variable para poder usarla
@onready var sprite = $AnimatedSprite2D

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var soundLevelUp = get_node("%snd_levelup")
@onready var itemsOptions = preload("res://Utility/item_option.tscn")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWapons = get_node("%CollectedWapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")







#ESTADISTICAS DEL JUGADOR
var hp = 80
var maxhp = 80
var movmentSpeed = 40.0

var experience = 0
var experience_level = 1
var collected_experience = 1

var time = 0


#ATTACKS
var iceSpear = preload("res://Player/Attacks/ice_spear.tscn") 
var tornado = preload("res://Player/Attacks/tornado.tscn")
var javeline = preload("res://Player/Attacks/javelin.tscn")

#ATTACKNODES
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer") 
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelineBase = get_node("%JavelineBes")


#UPGRADES
#LOS UPGRADES QUE YA TENGAMOS
var collected_upgrades = []
#LAS OPCIONES Q TENEMOS 
var upgrade_options = []

var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0 
var additional_attacks = 0



#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

#EL TORNADO QUIERO QUE VAYA HACIA DONDE SE ESTABA MOVIENDO EL JUGADOR
var last_movement = Vector2.UP

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

#JAVELINE
var javeline_ammo = 0
var javeline_level =  0


#Los enemigos que estan cerca de nosotros
var enemy_close = []




func _ready():
	#PARA QUE EMPIECE CON UN ATAQUE 
	upgrade_character("icespear1")
	attack()
	set_expbar(experience,calculate_experiencecap())
	_on_hurt_box_hurt(0,0,0)


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
		last_movement = mov
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
	#EL MINIMO DAÑO POSIBLE ES 1 Y EL MAXIMO 999
	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	
	



func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1-spell_cooldown) 
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1-spell_cooldown) 
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javeline_level > 0:
		spawn_javeline()
			

#Cargando la munición
func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo + additional_attacks
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

func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		#lo unico que cambios es el targetting
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javeline():
	#Cada hijo de javeline base
	var get_javeline_total = javelineBase.get_child_count()
	var calc_spawns = (javeline_ammo + additional_attacks) - get_javeline_total
	while calc_spawns > 0:
		var javelin_spawn = javeline.instantiate()
		javelin_spawn.global_position = global_position
		javelineBase.add_child(javelin_spawn)
		calc_spawns -= 1
	#UPDATE Javelin
	var get_javelins = javelineBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()
			
			
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


func _on_grab_area_area_entered(area):
	#SI EL OBJETO ESTA EN EL GRUPO LOOT, EL OBJETIVO ES EL JUGADOR
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		#HAY Q PONERLO EN UNA VARIABLE PORQUE COLLECT DEVUELVE VALOR DE LA GEMA
		var gem_exp = area.collect()
		
		calculate_experience(gem_exp)
	

func calculate_experience(gem_exp):
	if get_tree().paused:
		return
	
	
	
	#EXPERIENCIA NECESARIA PARA SUBIR DE NIVEL
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	#LA EXPERIENCIA QUE TENIAMOS ANTES + LA QUE VAMOS HA RECIVIR ES MAYOR QUE EL MAXIMO
	#SUBIMOS DE NIVEL
	if experience + collected_experience >= exp_required:
		#LA EXPERIENCIA QUE SOBRARIA A LA HORA DE SUBIR DE NIVEL SE QUEDA GUARDADA
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
		#CUANDO SUBAMOS DE NIVEL LLAMAREMOS OTRA VEZ A LA FUNCION PARA NO PERDER EXPERIENCIA
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
	#PARA ACUTALIZAR EL GUI
	set_expbar(experience, exp_required)


#PARA QUE SEA PROGRESIVO HAY Q IR SUBIENDO EL TOPE DE LA EXPERIENCIA 
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap



func set_expbar(set_value=1,set_max_value=100):
	expBar.value = set_value
	expBar.max_value = set_max_value
	

func levelup():
	soundLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemsOptions.instantiate()
		#ELEJIMOS UN OBJETO RANDOM PARA LAS MEJORAS 
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	
	get_tree().paused = true
	
	




func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javeline_level = 1
			javeline_ammo = 1
		"javelin2":
			javeline_level = 2
		"javelin3":
			javeline_level = 3
		"javelin4":
			javeline_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movmentSpeed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			#PARA NO SUPERAR NUESTRA VIDA MAXIMA 
			hp = clamp(hp,0,maxhp)
	adjust_gui_collection(upgrade)
	attack()
	var options_children = upgradeOptions.get_children()
	for i in options_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
	

#DEVUELVE UN ITEM ALEATORIO PARA LA MEJORA
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #ENCUENTRAS LAS MEJORAS YA REALIZADAS
			pass
		elif  i in upgrade_options: #SI LA MEJOPRA YA ES UNA OPCION  
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #SOLO LA COMIDA ES UN ITEM, ASI Q CUANDO TENGAMSO TODAS LAS MEJORAS PODREMOS CURARNOS
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #SI HAY PREREQUISITOS SE MIRA SI YA ESTAN 
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades: #SI NO ESTA SE PASA
					to_add = false
			if to_add:
				dblist.append(i) #SI ESTAN SE AÑADE A LA LISTA
		else:
			dblist.append(i) # SI PASA TODOS LOS CHECHS SE AÑADE A LA LISTA
	if dblist.size() > 0: #CUANDO HAYA UPCIONES EN LA LISTA SE ELIJIRA UNA RANDOM, ENTRE TODAS LAS QUE ESTE 
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem) 
		return randomitem
	else:
		return null

#VAMOS A LLAMAR A ESTO DESDE ENEMY SPAWNER PORQUE YA TIENE UN TIMER DEL JUEGO APRA GENERAR LOS ENEMIGOS
func change_time(argtime = 0):
	#POR DEFECTO SI TIME = 1 SOLO MUESTRA 1 Y QUIERO QSE VEA 00:00
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m) #COMO UN APPEND
	if get_s < 10:
		get_s = str (0, get_s)
	lblTimer.text = str(get_m,":", get_s)

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match  get_type:
				"weapon":
					collectedWapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)
