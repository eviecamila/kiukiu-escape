extends Node2D

func _ready():
	if PlayerData.debug:
		_on_start_pressed()
	$Label.text = PlayerData.version
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		show_question()

func change_scene(path: String) -> void:
	#var scene = load("res://%s.tscn" % path).instantiate()
	get_tree().change_scene_to_file("res://%s.tscn" % path)

func _on_start_pressed() -> void:
	change_scene("src/scenes/stages/stage")

func _on_settings_pressed() -> void:
	# change_scene("scenes/menu")
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()

func show_question() -> void:
	if get_node_or_null("Question") != null:
		return  # Si ya existe, no instanciar otra vez

	var question_scene = load("res://src/scenes/Question.tscn")
	var question = question_scene.instantiate()
	
	question.name = "Question"  # Asignar nombre para identificarla
	question.question_text = "¿Quieres salir del juego?"
	question.yes_text = "Sí, salir"
	question.no_text = "Cancelar"
	question.yes_value = true
	question.no_value = false

	question.connect("option_selected", Callable(self, "_on_option_selected"))
	add_child(question)


func _on_option_selected(selected: bool) -> void:
	if selected:
		get_tree().quit()
