extends Node2D


func _on_damagers_body_entered(body: Node2D) -> void:
	print(body)
	if body.get_class() == "Hen":
		print("XD")
