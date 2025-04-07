extends Node2D


func on_grabbed() -> void:
	print('me agarraron')
	PlayerData.max_jumps +=1
