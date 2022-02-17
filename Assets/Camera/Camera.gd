extends Camera2D

onready var rng = RandomNumberGenerator.new()#variable para generar numeros aleatorios
onready var player = get_tree().get_nodes_in_group("player")[0]

#solo para crear un numero random
func random(min_number, max_number):
	rng.randomize()
	var random = rng.randf_range(min_number, max_number)
	return random


func _process(delta) -> void:
	global_position.x = player.global_position.x

#Para generar el temblor en la camara usando offset_h y offset_v de la camara
func shake_camera(shake_power) -> void:
	offset_h = random(-shake_power, shake_power)# 
	offset_v = random(-shake_power, shake_power)

func screen_shake(shake_lenght : float, shake_power : float, shake_priority : int) -> void:
	var current_shake_priority : int = 0
	
	if shake_priority > current_shake_priority:
		$Tween.interpolate_method(
			self,# Objeto afectado("self" : este mismo nodo)
			"shake_camera",# Metodo o funcion afectada
			shake_power,# Valor inicial
			0, # Valor final y es cero por queremos que vuelva a su estado original
			shake_lenght,# Tiempo que transcurre enre uno y otro
			Tween.TRANS_SINE,# Transicion inicial
			Tween.EASE_OUT# Transicion final
		)
		$Tween.start()

