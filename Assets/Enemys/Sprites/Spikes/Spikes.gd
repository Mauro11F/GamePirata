extends Area2D


func _on_Spikes_body_entered(body):
	if body.is_in_group("player"):# Preguntasmos si el cuerpo colisionado es del grupó player
		body.damage_ctrl(3)# Llamamos a la funcion existente dentro del body "damage_ctrl()" y le restamos 5 de vida
