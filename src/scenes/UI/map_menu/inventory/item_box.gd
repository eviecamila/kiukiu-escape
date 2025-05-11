extends Panel

signal options_exited(item)
signal focus(q)
signal accept 

var can_use = false
var in_options = false

@onready var focused = $Focused:
	set = _set_focused

@onready var item = $item
var object:ItemData = null: set = _set_item

func _set_focused(val):
	focused.visible = val

func _set_item(val):
	
	if not val:
		item.frame = 23
		return
	object = val
	item.frame = val.frame

func _setup(item, q, focused: bool = false):
	_set_item(item)
	_set_focused(focused)

func _ready():
	var initial = get_meta('initial', false)
	reset(initial)

func reset(initial):
	_setup(null, 0, initial)
	
func _input(e):
	if not focused or not can_use:
		return
	for action in ["ui_down", "ui_up", "btn_1", "btn_2"]:
		if e.is_action_pressed(action):
			handle_input(action)

func show_options_menu():
	get_grid().options.show()

func hide_options_menu():
	get_grid().options.hide()

func get_grid():
	return get_parent().get_parent().get_parent()
func handle_input(action):
	match action:
		"ui_down":
			emit_signal("focus", 1)
		"ui_up":
			emit_signal("focus", -1)
		"btn_1":
			emit_signal("accept")
		"btn_2":
			can_use = false
			emit_signal("options_exited", self)
