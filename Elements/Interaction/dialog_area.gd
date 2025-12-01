extends Area2D
@onready var pvb = $PreviewButton
@export var dialog = ['sin dialogos']
var area_active = false

func _ready():
	pvb.visible = false
	SignalBus.connect("input", _input)
func _input(event):
	if area_active and event.is_action_pressed("btn_1"):
		SignalBus.emit_signal("display_dialog", get_meta("dialogs", dialog))

func _on_area_entered(area: Area2D) -> void:
	pvb.visible=true
	print('picale al clic w')
	area_active = true


func _on_area_exited(area: Area2D) -> void:
	pvb.visible = false
	area_active = false
