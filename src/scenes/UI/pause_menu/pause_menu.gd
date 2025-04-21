extends Control

signal continued
signal respawned
var _is_paused:bool =false:
	set = set_paused

func _input(event) -> void:
	if !visible: return
	await get_tree().create_timer(.1).timeout
	for i in ["pause", "ui_cancel"]:
		if event.is_action_pressed(i):
			_on_continue_pressed()
		

	
func set_paused(val):
	_is_paused = val
	get_tree().paused = val
	visible = val


func _on_continue_pressed() -> void:
	hide()
	await get_tree().create_timer(0.1).timeout
	set_paused(false)
	emit_signal("continued")

func _pause():
	print("pausando")
	set_paused(true)
func _on_settings_pressed() -> void:
	print('settings')
	 # Replace with function body.


func _on_respawn_pressed() -> void:
	emit_signal("respawned")


func _on_btn_pressed() -> void:
	print('a casa pringao')


func _on_sfx_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_bgm_value_changed(value: float) -> void:
	pass # Replace with function body.
