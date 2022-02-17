extends Area2D

class_name BasicCoins

export(String, "coin", "chest", "diamond") var type = "coin"
onready var active : bool = true


func _ready() -> void:
	$AnimationPlayer.play("idle")


func _on_Coin_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("collected")


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"collected":
			if active:
				$CoinsCollector.play()
				active = false
				
				match type:
					"coin":
						GLOBAL.coins += 1
						#print("se sumo + 1 a coins")
					"diamond":
						GLOBAL.coins += 5
					"chest":
						GLOBAL.coins += 100
						#print("se sumo + 100 a coins")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"collected":
			queue_free()

