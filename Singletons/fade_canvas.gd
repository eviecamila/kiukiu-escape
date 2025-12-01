extends CanvasLayer

# 🚨 CORRECCIÓN: Asegúrate de que el nombre del nodo ColorRect sea 'Fade_Rect' 
@onready var fade_rect: ColorRect = $Fade_Rect 
const DEFAULT_FADE_TIME: float = 0.5 # Duración predeterminada del fade

func _ready() -> void:
	fade_out_from_black(.3)
# Señal para notificar cuando la pantalla está completamente negra
# ¡Esta señal es el equivalente asíncrono del 'return true' que buscas!
signal fully_faded_in

# Función para poner la pantalla totalmente NEGRA (Fade In)
# Retorna el objeto Tween para que el código llamador pueda usar 'await'.
# Después de que el Tween finaliza, emite la señal fully_faded_in.
func fade_in_to_black(duration: float = DEFAULT_FADE_TIME) -> Tween:
	var tween_in = create_tween()
	# Animamos el canal alfa a 1.0 (opaco = negro)
	tween_in.tween_property(fade_rect, "modulate:a", 1.0, duration)
	
	# Conectamos la señal para notificar cuando se complete
	tween_in.finished.connect(Callable(self, "_on_fade_in_finished"), CONNECT_ONE_SHOT)
	
	return tween_in

# Función auxiliar que se llama cuando el Fade In termina.
func _on_fade_in_finished():
	emit_signal("fully_faded_in")
	print("Pantalla completamente negra. Lista para teletransporte.")

# Función para quitar el negro de la pantalla (Fade Out)
# Retorna el objeto Tween para que el código llamador pueda usar 'await'.
func fade_out_from_black(duration: float = DEFAULT_FADE_TIME) -> Tween:
	var tween_out = create_tween()
	# Animamos el canal alfa a 0.0 (transparente = visible)
	tween_out.tween_property(fade_rect, "modulate:a", 0.0, duration)
	
	print("Comenzando Fade Out.")
	return tween_out
