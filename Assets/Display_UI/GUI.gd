extends CanvasLayer

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]

func _ready():
	get_node("AnimationPlayer").play("FadeIn") # producimos la animacion de inicio
	get_node("TextureProgress").max_value = player.health

func _process(delta):
	if is_instance_valid(player):
		get_node("TextureProgress").value = player.health
		get_node("ScoreContainer/Label").text = str("x ") + str(GLOBAL.coins)


func _on_TextureProgress_value_changed(value):
	if value <= 0:
		get_node("AnimationPlayer").play("FadeOut") # Reproducimos la animacion de Fade-out


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"FadeOut":# Cuando se ejecute esta animacion pausamos el juego
			get_tree().paused = true
			get_node("Control2/VBoxContainer").visible = true # Hacemos visible el texto gameover
			get_node("Sound/GamerOver").play()# Reproducimos la musica de game over
		"FadeIn":# Cuando iniciamos esta animacion ocultamos texto game over
			get_node("Control2/VBoxContainer").visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeIn":# Cuando termina de ocultarse, sacamos la PAUSA
			get_tree().paused = false


func _on_GamerOver_finished():
	# Cuando termine la musica de Game Over se reinicia la escena.
	# Utilizamos call_deferred para hacer una llmada segura y que no nos arroje advertencia
	get_tree().call_deferred("reload_current_scene")
	
	GLOBAL.levelStart = false


