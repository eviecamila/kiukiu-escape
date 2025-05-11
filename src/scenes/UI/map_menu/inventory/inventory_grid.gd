extends Node2D

signal exited
signal equip(pos, item)

var focused = 0: set = change_focus
var can_use = false
var inv: Inventory = Inventory.get_instance()
var texto = 'Tools': set = set_title

@onready var grid = [
	$NinePatchRect/GridContainer/ItemBox,
	$NinePatchRect/GridContainer/ItemBox2,
	$NinePatchRect/GridContainer/ItemBox3,
	$NinePatchRect/GridContainer/ItemBox4,
	$NinePatchRect/GridContainer/ItemBox5,
	$NinePatchRect/GridContainer/ItemBox6,
	$NinePatchRect/GridContainer/ItemBox7,
	$NinePatchRect/GridContainer/ItemBox8,
	$NinePatchRect/GridContainer/ItemBox9
]

@onready var options = $NinePatchRect/OptionsMenu
var options_children = []
var options_index = 0

func refresh():
	var m = inv.tools if texto == 'Tools' else inv.inventory
	print(inv)
	for i in range(0, m.size()):
		var item = m[i]
		grid[i]._set_item(item)

func _ready():
	options_children = options.get_children()
	options.hide()
	for i in grid:
		i.connect("options_exited", Callable(hide_options))
		i.connect("focus", Callable(focus))
		i.connect("accept", Callable(on_box_accept))
	inv.connect("equip", Callable(on_equip))
	reset_focus()


func _input(event: InputEvent) -> void:
	
	if not can_use:
		return
	for action in ["ui_left", "ui_right", "ui_up", "ui_down", "btn_1", "btn_2"]:
		if event.is_action_pressed(action):
			print("can_use: ",can_use,"\nItem: ",focused, "\nindex: ", options_index)
			handle_input(action)

func handle_input(action):
	match action:
		"ui_left": change_focus(-1)
		"ui_right": change_focus(1)
		"ui_up": change_focus(-3)
		"ui_down": change_focus(3)
		"btn_1":
			if grid[focused].object:
				print('se presiono btn_1')
				if !options.visible:
					can_use = false
					grid[focused].can_use = true
					options.show()
					return
				#grid[focused].can_use = true
				print('pendiente de handling')
			else:
				Meta._play_sound($SFX, "inventory/denied.ogg")
		"btn_2":
			print('se presiono btn_1')
			if options.visible:
				return
			can_use = false
			emit_signal("exited")

func reset_focus():
	while focused != 0:
		change_focus(-1)

func change_focus(delta):
	if not grid:
		return
	print(focused)
	grid[focused]._set_focused(false)
	focused += delta
	if focused > 8:
		focused -= 9
	elif focused < 0:
		focused += 9
	grid[focused]._set_focused(true)

func set_title(v):
	texto = v
	$NinePatchRect/NinePatchRect/Label.text = v

func _on_visibility_changed() -> void:
	can_use = visible
	if can_use:
		reset_focus()
		refresh()
func on_equip():
	var items = inv.get_equipped_objects()
	emit_signal("equip", 0, items[0])
	emit_signal("equip", 1, items[1])
func on_box_accept():
	print('culo')
	var in_tools = texto == "Tools"
	if options_index!=2:
		var equip_status = inv.equip_item(focused, options_index, in_tools)
		on_equip()
		Meta._play_sound($SFX, "inventory/equip.wav")
	else:
		hide_options(grid[focused])
			
func hide_options(item):
	options.hide()
	await get_tree().create_timer(.1).timeout
	can_use = true
	item.can_use = false

func focus(delta):
	options_index += delta
	if options_index >= options_children.size():
		options_index = 0
	elif options_index < 0:
		options_index = options_children.size() - 1
	for i in range(options_children.size()):
		options_children[i].get_children()[0].visible = (i == options_index)

func _on_options_menu_visibility_changed() -> void:
	if options.visible:
		options_index=0
		focus(0)
		options.position = grid[focused].position
