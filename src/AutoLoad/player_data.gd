extends Node

signal updated
signal died
signal reset

## Variables estáticas
var score: int = 0:
	set = set_score

var debug = true

var deaths: int = 0:
	set = set_deaths

func reset_data():
	score = 0
	deaths = 0
	reset.emit()

func set_score(new_score: int) -> void:
	score = new_score
	updated.emit()

func set_deaths(new_value: int) -> void:
	deaths = new_value
	died.emit()
