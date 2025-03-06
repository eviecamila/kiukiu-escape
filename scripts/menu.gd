extends Control

var is_map_visible = false

func _process(delta):
	if Input.is_action_pressed("ui_map"):
		is_map_visible = not is_map_visible
		set_visible(is_map_visible)
