extends KinematicBody2D

class_name BasicEnemy # Le damos un nombre de clase para que otros enemigos hereden sus comportamientos basicos

onready var camera : Camera2D = get_tree().get_nodes_in_group("camera")[0]#traemos en el nodo que pertenesca a un grupo "camera"

const FLOOR = Vector2(0, -1)
const GRAVITY = 16

export (int ,1 ,10) var health : int = 3

onready var motion : Vector2 = Vector2.ZERO
onready var can_move : bool = true
onready var direction : int = 1

const MIN_SPEED = 42
const MAX_SPEED = 74
var speed : int

func _ready() -> void:
	$AnimationPlayer.play("run")


func _process(_delta) -> void:
	attack_ctrl()
	patrol_ctrl()
	
	if can_move:
		motion_ctrl()


func attack_ctrl() -> void:
	if get_node("RayCast/Attack").is_colliding():
		if get_node("RayCast/Attack").get_collider().is_in_group("player"):
			can_move = false
			$AnimationPlayer.play("attack")

func patrol_ctrl() -> void:
	if get_node("RayCast/Patrol").is_colliding():
		if get_node("RayCast/Patrol").get_collider().is_in_group("player"):
			speed = MAX_SPEED
		else:
			speed = MIN_SPEED
	else:
		speed = MIN_SPEED


func motion_ctrl() -> void:
	if direction == 1:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	#Si colisiona con una pared o el raycas deja de estar en contacto con el suelo entoncescambio su direccion
	if is_on_wall() or not $RayCast/Ground.is_colliding():
		direction *= -1
		$RayCast.scale.x *= -1
	
	
	motion.y += GRAVITY
	motion.x = speed * direction
	
	motion = move_and_slide(motion, FLOOR)

func damage_ctrl(damage) -> void:
	if can_move:
		if health > 0:
			health -= damage #parametro para definir la cantidad de vida a restar
			$AnimationPlayer.play("hit")
			#print("La vida del enemigo es: " + str(health))
		else:
			$AnimationPlayer.play("dead")


func _on_AnimationPlayer_animation_started(anim_name):#Senal enviada cuando comienza x animacion
	match anim_name:
		"hit":
			can_move = false# No se mueve si recibe golpes
			camera.screen_shake(0.7, 0.8, 100)
		"attack":
			get_node("RayCast/Attack").get_collider().damage_ctrl(1)
			#print("menos 1 de vida")
		"dead":
			$SoundDead.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"hit":
			if health > 0:
				can_move = true # Si aun esta con vida, se puede seguir moviendo
				$AnimationPlayer.play("run")
			else:
				$AnimationPlayer.play("dead")# Si no tiene mas vida reproduce la anim. de muerto
		"attack":
			can_move = true
			get_node("AnimationPlayer").play("run")
		"dead":
			queue_free()# Al terminar la animacion se elimina



