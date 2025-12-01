extends Node3D
@onready var cam:Camera3D = $CAM
func _ready() -> void:
	cam.set_current(true)
func _input(event: InputEvent) -> void:
	for p in ["ui_accept", "ui_up", "btn_reset", "btn_1"]:
		if event.is_action_pressed(p):
			print("emití " + p)
			SignalBus.emit_signal("input", event)
