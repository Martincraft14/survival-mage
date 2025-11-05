extends Area2D

#HitBox sera lo que golpea, habra tambien una HurtBox que procesara e ldaño que nos hara la HitBox

@export var damage = 1 

@onready var timer = $Timer
@onready var collition = $CollisionShape2D

func tempdisable():
	collition.call_deferred("set", "disabled", true)
	timer.start()
	
	


func _on_timer_timeout():
	collition.call_deferred("set", "disabled", false)
	
	
	
	
	#SOBRE LAS COLISIONES
	#EN GODOT HAY HASTA 32 CAPAS DE COLISION 
	#para colisionar unas con otras tiene que estar en la misma capa fisica (layer)
	#a parte hay Masks
	#El Layer dicta donde existe la colision y la mascara dicta contra que colisionara con los
	#objetos que existan en la layer
	
	
	
	
	
	
	
