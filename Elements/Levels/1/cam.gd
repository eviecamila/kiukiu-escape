extends Camera2D


const SCREEN_SIZE := Vector2( 1280, 720 )
var cur_screen := Vector2( 0, 0 )

func _ready():
	set_as_top_level( true )
	global_position = get_parent().global_position
	_update_screen( cur_screen )
	SignalBus.cam_smooth.connect(set_camera_smooth)

func _physics_process(delta):
	var parent_screen : Vector2 = ( get_parent().global_position / SCREEN_SIZE ).floor()
	if not parent_screen.is_equal_approx( cur_screen ):
		
		_update_screen( parent_screen )
# Función para controlar si la cámara debe seguir con suavidad o no.
func set_camera_smooth(val: bool):
	# Habilitar/Deshabilitar el suavizado de la posición.
	# Esto permite transiciones suaves cuando el jugador se mueve,
	# pero permite saltos instantáneos (teletransporte) o movimientos controlados
	# por código (transiciones de sala).
	print("seteando cam smooth a "+ str(val))
	set_position_smoothing_enabled(val)

func _update_screen( new_screen : Vector2 ):
	cur_screen = new_screen
	global_position = cur_screen * SCREEN_SIZE + SCREEN_SIZE *.5
