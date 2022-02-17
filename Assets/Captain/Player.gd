extends KinematicBody2D

export (PackedScene) var Shoot
onready var player : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]


const SPEED = 120
const FLOOR = Vector2(0, -1) #Para indicar la direccion del suelo
const GRAVITY = 16
const JUMP_HEIGHT = 380
const BOUNKING_JUMP = 112 #Fuerza de rebote en la pared

onready var motion : Vector2 = Vector2.ZERO
var can_move : bool #Compraobar si el personaje puede moverse

var inmunity : bool = false #Para crear el estado de inmunidad al player
var health : int = 5 #Sera la cantidad de vida del player


""" STATE MACHINE """
var playback : AnimationNodeStateMachinePlayback

func _ready():
	playback = $AnimationTree.get("parameters/playback")# Obtenemos la referencia al parametro playback del nodo AnimateTree.
	playback.start("idle")# Iniciamos en el estado "idle"
	$AnimationTree.active = true # Activamos el AnimationTree

func _process(delta):
	motion_ctrl()
	jump_ctrl()
	attack_ctrl()
	shot_ctrl()

func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis

# Al separar los comportamientos en distintas funciones, la funcion de movimiento a quedado mucha mas limpia
func motion_ctrl():
	motion.y += GRAVITY
	
	if can_move: #Se podra mover solo si can_move es true
		motion.x = get_axis().x * SPEED
		
		if get_axis().x == 0:
			playback.travel("idle")
		elif get_axis().x == 1:
			playback.travel("run")
			$Sprite.flip_h = false
		elif get_axis().x == -1:
			playback.travel("run")
			$Sprite.flip_h = true
		
		match playback.get_current_node():
			"idle":
				motion.x = 0
				$Particles.emitting = false
			"run":
				$Particles.emitting = true
	
	# Con el nodo posirion2D (Raycast) solo es cuestion de cambiar la escala del nodo para cambiar la direccion de los raycast
	match $Sprite.flip_h:
		true:
			$Raycast.scale.x = -1
		false:
			$Raycast.scale.x = 1
	
	
	motion = move_and_slide(motion, FLOOR)
	
	var slide_count = get_slide_count()# Retorna el numero de veces que el cuepro esta colisionando
	
	if slide_count:# Si es mayor a 0 quiere decir que colisiono con algo
		#guradaremos el objeto colisionado por un lado y su colider por otro
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		
		#Si pertenece al grupo platform y presionamos la tecla "abajo",desactivamos el "collider"
		# del player y activamos el "timer"
		if collider.is_in_group("platform") and Input.is_action_just_pressed("ui_down"):
			$Collision2D.disabled = true
			$Timer.start()

func _on_Timer_timeout():
	# Activamos de neuvo el collider del player
	$Collision2D.disabled = false

#Funcion de salto
func jump_ctrl():
	match is_on_floor():
		true:#Si esta tocando el suelo entonces...
			can_move = true#Se puede mover
		
			if Input.is_action_just_pressed("Jump"):
				$Sounds/jump.play()
				motion.y -= JUMP_HEIGHT
			
		false:# Si NO esta tocando el suelo
			$Particles.emitting = false# Desactivamos la Polvareda
			
			if motion.y < 0:
				playback.travel("jump")
			else:
				playback.travel("fall")
			
			if $Raycast/Wall.is_colliding(): #si el nodo esta colicionando entonces... 
				#can_move = false
				
				var col = $Raycast/Wall.get_collider()#Guardamos la colicion
				
				#Si el personaje esta tocando la pared y saltando entonces...
				if col.is_in_group("wall"):
					can_move = false
					if Input.is_action_just_pressed("Jump"):
						#can_move = false
						$Sounds/jump.play()
						motion.y -= JUMP_HEIGHT
						
						if $Sprite.flip_h:
							motion.x += BOUNKING_JUMP
							$Sprite.flip_h = false
						else:
							motion.x -= BOUNKING_JUMP
							$Sprite.flip_h = true

#Funcion para controlar el ataque
func attack_ctrl():
	var body = $Raycast/Hit.get_collider()#guardamos el cuerpo colicionado
	
	if is_on_floor():
		if get_axis().x == 0 and Input.is_action_just_pressed("Attack"):
			match playback.get_current_node():
				"idle":
					playback.travel("attack1")
					$Sounds/attack.play()
				"attack1":
					playback.travel("attack2")
					$Sounds/attack.play()
				"attack2":
					playback.travel("attack3")
					$Sounds/attack.play()
			
			if $Raycast/Hit.is_colliding():
				if body.is_in_group("enemy"):
					body.damage_ctrl(3)

func shot_ctrl():
	if Input.is_action_just_pressed("Shoot"):
		var shoot = Shoot.instance()
		shoot.global_position = $Raycast/ShootSpawn.global_position
		
		if player.get_node("Sprite").flip_h:
			shoot.scale.x = -1
			shoot.direction = -224
		else:
			shoot.scale.x = 1
			shoot.direction = 224
	
		get_tree().call_group("level", "add_child", shoot)

func damage_ctrl(damage : int) -> void:
	match inmunity:
		false:# Si el personaje no se encuentra en estado de inmuunidad
			health -= damage # Entonces le restamos el daño recibido
			get_node("AnimationPlayer").play("hit")# Se reproduce la animacion de daño
			get_node("Sounds/hit").play()# Se reproduce el sonido de daño
			inmunity = true# Mientras recibe el daño se hace inmune


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"hit":
			inmunity = false# Cuando termne su animacion de hit dejara de ser inmune



