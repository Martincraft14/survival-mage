extends Sprite2D


func _ready() -> void:
	$AnimationPlayer.play("explode")
	


func _on_animation_player_animation_finished() -> void:
	queue_free()
