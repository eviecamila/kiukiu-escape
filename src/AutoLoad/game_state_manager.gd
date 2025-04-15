extends Node

signal game_paused(is_paused)

enum State {
	PLAYING,
	PAUSED_MENU,
	DIALOG,
	SPECIAL_ITEM,
	MAP_MENU
}

var current_state: State = State.PLAYING

func set_state(new_state: State):
	if current_state != new_state:
		current_state = new_state
		emit_signal("game_paused", is_paused())
		set_physics_process(current_state == State.PLAYING)
		set_process_input(current_state == State.PLAYING or current_state == State.DIALOG or current_state == State.PAUSED_MENU) # Adjust input processing as needed

func is_paused():
	return current_state != State.PLAYING

func is_dialog_active():
	return current_state == State.DIALOG

func is_special_item_active():
	return current_state == State.SPECIAL_ITEM
