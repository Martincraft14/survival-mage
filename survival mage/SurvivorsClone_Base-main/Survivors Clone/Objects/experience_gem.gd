extends Area2D


@export var experience = 1

#LOS DIFERENTES TIPOS DE SPRITES PARA LOS TIPOS DE EXPERIENCIA 
var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")


var target = null
#SE PONE -1 AL PRINCIPO APRA QUE CAUNDO ENTRE EN EL AREA HAGA UN EFECTO DE REBOTE HACIA EL JUGADOR
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var snd = $snd_xp_collected


func _ready():
	#COMO DE BASE ES LA GEMA VERDE SOLAMENTE LA DEVOLVEMOS
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red



func _physics_process(delta):
	if target != null:
		global_position =  global_position.move_toward(target.global_position, speed)
		speed += 2*delta



func collect():
	snd.play()
	#NO PODEMOS HACER QUEUE FREE AQUI PORQUE SINO NO SUENA LA MUSICA
	collision.call_deferred("set", "disable",true)
	sprite.visible = false
	return experience


func _on_snd_xp_collected_finished() -> void:
	queue_free()
