extends Node2D
class_name SpringWater
var lives = Lives.get_instance()
var _path = "res://src/scenes/objects/items/hearts/spring_water.tscn"
func _ready() -> void:
	$Objeto.to_inv = true
func on_grabbed() -> void:
	pass
	print("¡Agua revitalizante! ¡Curación total!")
	
func use(hen:Hen):
	Meta._play_sound(hen.audio, "items/heal.wav")
	lives.max_life()
	PlayerData.lives = PlayerData.max_lives
	PlayerData.golden_lives = PlayerData.max_golden_lives

func on_finished() -> void:
	queue_free()
