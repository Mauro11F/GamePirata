#extends Area2D

extends BasicCoins


func _on_Chest_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("collected")
