extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0


@onready var collision = $CollisionShape2D

@onready var timer = $Timer

#LAS SEÑALES SON BUILD IN CONDITION QUE NOS PERMITE ACTIVAR METODOS EN OTROS NODOS,
#tambien pueden usar señales de los nodos padres
#En el caso de Area2D somos capaces de detectar colisiones, si algo a entrado en nuestra area
#Tambien podemos crear nustras propias señales, no solo las que ya existe en godot
signal hurt(damage, angel, knockback)


var hit_once_array = []

#cada vez que alguien entre al area esto se procesara
func _on_area_entered(area):
	#Cunado una area en el grupo attack entra en la hurtbox
	if area.is_in_group("attack"):
		# comprobamos si el area que entra tiene el atributo damage
		if not area.get("damage") == null:
			#los tipos de HurtBox, es un switch de toda la vida
			match HurtBoxType:
				0:#Cooldown
					#Si esta en cooldown, desactivara el collisionShape2D para que no recibamos mas daño por un tiempo
					collision.call_deferred("set", "disabled",true)
					timer.start()
				1:#HitOnce
					if hit_once_array.has(area) == false: #Detecta si es golpeado
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							#comprobamos que no esta conectada
							#asi se conect auna señal por codigo, en vez de las otras formas 
							if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								#la conectamos
								area.connect("remove_from_array",Callable(self, "remove_from_list"))
							pass
					else:
						return
				2:#DisableHitBox
					#El metodo que hemos creado en hitbox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			var angle =  Vector2.ZERO
			var knockback = 1
			
			#miramos si el ataque tiene angulo y knockBack (no podemos declararlo arriba porque habra ataques que 
			#no tengan o knockback o angulo)
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			
			
			#enviamos nuestra señal damage
			emit_signal("hurt",damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

#SEÑAL DE TIMER PARA CUANDO ACABE LE COOLDOWN DE LA HURTBOX
func _on_timer_timeout() -> void:
	#volvemos a activar el collisionShape2D
	collision.call_deferred("set", "disabled",false)
	
func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)
