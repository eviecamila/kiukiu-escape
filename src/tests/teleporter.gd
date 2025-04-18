extends Control

signal teleport(location:String)
func _on_button_pressed() -> void:
	emit_signal("teleport", $TextEdit.text)
	$TextEdit.release_focus()

# En _ready
func _ready():
	$TextEdit.mouse_filter = Control.MOUSE_FILTER_STOP  # Solo clics sobre el TextEdit
	$TextEdit.focus_mode = Control.FOCUS_CLICK  # Solo obtiene foco al hacer clic


func _on_focus_exited() -> void:
	pass # Replace with function body.
