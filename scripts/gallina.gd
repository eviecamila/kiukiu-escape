extends AnimatedSprite2D

#Gestion de animacion y movimiento de la gallina

var speed = 400

# No es necesario @onready ya que AnimatedSprite2D es el nodo padre

func is_kp(k):
	return Input.is_action_pressed(k)
var is_moving_x = false
# Renombrar las funciones para evitar confusiones
func start_walking():
	play("walk")

func stop_walking():
	stop()

func _process(delta):
	var movement = Vector2()
	
	if is_kp("ui_left"):
		movement.x -= 1
		is_moving_x=true
	if is_kp("ui_right"):
		movement.x += 1
		is_moving_x=true
	if is_kp("ui_up"):
		movement.y -= 1
	if is_kp("ui_down"):
		movement.y += 1
	
	
	#gestionar animacion de caminar
	if is_moving_x==true:
		start_walking()
	else: stop_walking()
	
	if movement.length() > 0:
		movement = movement.normalized()

	position += movement * speed * delta

	# Girar el sprite horizontalmente
	if movement.x != 0:
		flip_h = movement.x < 0
