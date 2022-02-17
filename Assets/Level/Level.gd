extends Node2D

func _ready():
	
	if GLOBAL.levelStart:#Si el nivel acaba de empezar y el player se encuentra en la rama de escenas
		GLOBAL.spawmPoint = get_node("Player").global_position# Entonces el punto de reaparicion
		#es el punto donde coloquemos el player en el escenario
		GLOBAL.coins = 0 # Si es la primera ves que inicia el level las monedas son CERO
		print("cantidad de puntos: ", GLOBAL.coins)
		
	# y para que esto se cumpla cada ves que se inicie el nivel la posicion del player debe
	# ser igual al punto de spawn
	get_node("Player").global_position = GLOBAL.spawmPoint
	# Si toco el checkPoint mostramos las monedas obtenidas
	# Mehor lo pienso bien
