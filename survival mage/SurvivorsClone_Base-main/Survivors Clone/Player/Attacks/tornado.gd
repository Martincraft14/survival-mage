extends Area2D

#ESTE ATAQUE APUNTA HACIA DONDE ESTA ANDANDO EL JUGADOR, ES UN ATAQUE EN ZIGZAG QUE ATRABIESA
#A LOS ENEMIGOS 
var level = 1
var hp = 9999#COMO QUIERO Q ATRABIESE A LOS ENEMIGOS LA VIDA NO LA USAREMOS PERO PARA MANTENER LA CONSISTENCIA LA PONEMOS
var speed = 100.0
var damage  = 5
var knockback_amount = 100
var attack_size = 1.0

var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")



func _ready():
	match level:
		1:
			hp = 9999
			speed = 100.0
			damage  = 5
			knockback_amount = 100
			attack_size = 1.0 * (1+ player.spell_size)
		2:
			hp = 9999
			speed = 100.0
			damage  = 5
			knockback_amount = 100
			attack_size = 1.0 * (1+ player.spell_size)
		3:
			hp = 9999
			speed = 100.0
			damage  = 5
			knockback_amount = 100
			attack_size = 1.0 * (1+ player.spell_size)
		4:
			hp = 9999
			speed = 100.0
			damage  = 5
			knockback_amount = 125
			attack_size = 1.0 * (1+ player.spell_size)

	# Usa la dirección del jugador (last_movement) como base para el zigzag
	var base_direction = last_movement.normalized()
	var perpendicular = Vector2(-base_direction.y, base_direction.x)
	angle_less = (base_direction + perpendicular * 2)
	angle_more = (base_direction - perpendicular * 2)
	
	angle = angle_less if randi_range(0, 1) == 0 else angle_more
	
	var tween = create_tween()
	
	
	if angle == angle_less:
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
	else:
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
		tween.tween_property(self, "angle", angle_less, 0.5)
		tween.tween_property(self, "angle", angle_more, 0.5)
	
	tween.play()
	
func _physics_process(delta):
	position += angle*speed*delta

func _on_timer_timeout() -> void:
	
	emit_signal("remove_from_array", self)
	queue_free()
