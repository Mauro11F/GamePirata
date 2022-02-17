extends Area2D



func _on_SpawnPoint_body_entered(body):
	if body.is_in_group("player"):
		get_node("AnimatedSprite").play("turn")
		get_node("Sound").play()
		GLOBAL.spawmPoint = global_position
		#GLOBAL.coins = GLOBAL.coins
		#print("Monedas obtenidas hasta el momento: ", GLOBAL.coins)



func _on_AnimatedSprite_animation_finished():
	get_node("AnimatedSprite").play("idle")
