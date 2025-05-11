extends Sprite2D

var displayed_text = "":
	set = set_text
var _frame:int = 0
var btn:int = 0:
	set = _set_frame
func _ready():
	_frame = get_meta("btn",0)
	btn = _frame	
func _process(delta: float) -> void:
	_set_frame(1 if Meta.touching else 0)
func set_text(v):
	$text.text = v
func _set_frame(v):
	set_frame(_frame + v)
