extends Node2D
class_name NPCDialog

signal start_dialog
signal finished

@export var typing_speed: float = 0.05  # Velocidad de escritura

@onready var dialogue_box: Panel = $Panel
@onready var sprite: Sprite2D = $Sprite
@onready var dialogue_text: Label = $Panel/BG/BoxContainer/Text
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var options_container: VBoxContainer = $Panel/BG/BoxContainer/OptionsContainer  # Asegúrate de tener este nodo

var current_texts: Array = []
var is_typing: bool = false
var npc: NPC = null
var is_running_dialog = false

var selected_option_data: Array = []
var option_chosen: bool = false

func _init() -> void:
	visible = false

func dialog(npc_instance: NPC):
	if is_running_dialog:
		return
	emit_signal("start_dialog")
	get_tree().paused=true
	npc = npc_instance
	audio_player.stream = npc.npc_resource.sfx_1
	var scale =  npc.npc_resource.scale
	if npc.npc_resource and npc.npc_resource.img:
		sprite.texture = npc.npc_resource.img
		sprite.scale = Vector2(scale*4, scale*4)

	set_data(npc.dialog_data)
	visible = true

func set_data(d: String) -> void:
	is_running_dialog = true
	visible = true
	var index := 0
	var dialogs = d.split(';')
	while index < dialogs.size():
		var entry = dialogs[index]

		if typeof(entry) == TYPE_STRING:
			dialogue_text.text = ""
			await start_typing(entry)
			await wait_for_input()

		#elif typeof(entry) == TYPE_DICTIONARY:
			#for key in entry:
				#show_options(entry[key])
				#await wait_for_option()
				#await wait_for_input()
#
				#dialogs = selected_option_data + dialogs.slice(index + 1)
				#index = -1  # reiniciar para seguir con el nuevo diálogo
				#break

		index += 1

	end_dialog()

func start_typing(text: String):
	is_typing = true
	var text_to_show = ""

	for i in range(text.length()):
		if Input.is_action_pressed("btn_2") and not Input.is_action_pressed("btn_1"):
			dialogue_text.text = text
			break
		text_to_show += text[i]
		audio_player.play()
		dialogue_text.text = text_to_show
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false

func wait_for_input():
	while not Input.is_action_pressed("btn_1"):
		await get_tree().process_frame

func show_options(options: Dictionary):
	option_chosen = false
	selected_option_data = []
	options_ctr_clr()

	for option in options:
		var button = Button.new()
		button.text = option
		button.pressed.connect(func():
			selected_option_data = options[option]
			option_chosen = true
			options_ctr_clr()
		)
		options_container.add_child(button)

func wait_for_option():
	while not option_chosen:
		await get_tree().process_frame

func end_dialog():
	emit_signal("finished")
	visible = false
	if npc.npc_resource.sfx_2:
		audio_player.stream = npc.npc_resource.sfx_2
		audio_player.play()
	if npc:
		npc.end_dialog()
	reset_dialog()
	await get_tree().create_timer(1).timeout

func reset_dialog():
	current_texts = []
	is_typing = false
	npc = null
	dialogue_text.text = ""
	sprite.texture = null
	options_ctr_clr()
	is_running_dialog = false

func options_ctr_clr():
	for child in options_container.get_children():
		child.queue_free()
func get_npc_text_color() -> String:
	var npc_type = npc.type
	return npc.types.get(npc_type, {}).get("text_color", "fff")

func _process(delta):
	if is_typing:
		return
