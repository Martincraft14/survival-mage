extends Node2D

#Podemos llamar a toda la clase Spwan_info
@export var spawns: Array[Spawn_info] = []

#Explicado en enemy
@onready var player = get_tree().get_first_node_in_group("player")

var time = 0

signal changetime(time)


func _ready():
	connect("changetime",Callable(player,"change_time"))
	

#corremos un Timer cada segundo
func _on_timer_timeout():
	#añadimos un segundo
	time += 1
	
	var enemy_spawns = spawns
	for i in enemy_spawns:
		#nos movemos por el spawan_arrya entre el time start y time end
		if time >= i.time_start and time <= i.time_end: #si hay miramos si el delaycounter es menor que el delay del spawn
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0 #reseteamos el counter a 0 
				#res://Enemy/enemy.tscn
				var new_enemy = i.enemy #cargamos el enemigo
				var counter  = 0
				while counter < i.enemy_numb: #spawneamos el numero de enemigos 
					#creamos una nueva instancia de nuestro nuevo enemigo
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()#elejimos una posicion aleatoria 
					#fuera de la camara para spwanear al enemigo 
					
					#Lo spawnea en el mundo
					add_child(enemy_spawn)
					counter += 1 #subimos el contador hasta que se llege al numero de enemigos que queremos spawnear
	emit_signal("changetime", time)

#Para obtener la posicion aleatoria de spawneao
func get_random_position():
	#VPR = Viweport Rect(lo que vemos), lo multiplicamos por un numero aleatorio entre 1.1 y 1.4
	#para que sea mas grand eque la ventana de vision
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	
	#Seteamos las esquinas 
	var top_left = Vector2(player.global_position.x - vpr.x/2,player.global_position.y - vpr.y/2)
	var top_rigth = Vector2(player.global_position.x + vpr.x/2,player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2,player.global_position.y + vpr.y/2)
	var bottom_rigth = Vector2(player.global_position.x + vpr.x/2,player.global_position.y + vpr.y/2)
	
	#Coje un valor aleatorio del array para la posicion de spawn
	var pos_side = ["up","down", "right", "left"].pick_random()
	
	#Solo los inicializamos, luego los usaremos 
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	#La posicion done aparecera el enemigo(elejimos un lado)
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_rigth
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_rigth
		"right":
			spawn_pos1 = top_rigth
			spawn_pos2 = bottom_rigth
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
			
			
	#Cojemos un valor entre los puntos
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	#devolvemos el rango aleatorio creado entre spawn_pos1 y spawn_pos2
	#esto nos devolvera nuestra posicion global de spawneo 
	return Vector2(x_spawn, y_spawn)
