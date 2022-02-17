extends Area2D

var direction : int
onready var can_move : bool = true

func _ready() -> void:
	$AnimationPlayer.play("shoot")
	$AudioStreamPlayer.play()

func _process(delta) -> void:
	# Su unica funcion es moverse en direccion en x, la cual es definida por quien dispara
	if can_move:
		global_position.x += direction * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()# Si sale de la pantalla se elimina el "disparo"


func _on_Shoot_body_entered(body):
	if body.is_in_group("enemy"):# Si el cuerpo pertenece al grupo enemy...
		body.damage_ctrl(1)# Ejecutamos la funcion de body llamada "damage_ctrl()"
		$AnimationPlayer.play("embedded")
		
	elif body.is_in_group("wall"):
		$AnimationPlayer.play("embedded")
	else:
		pass


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"embedded":
			can_move = false# Detenemos el movimiento del proyectil


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"embedded":
			queue_free()# Eliminamos el disparo
