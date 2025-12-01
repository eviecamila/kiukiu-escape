# Audio_Manager.gd (Reemplaza el contenido de tu game_ui.gd)

extends Node

# Referencias a los nodos de audio hijos
@onready var sfx_player: AudioStreamPlayer = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGM 
@onready var fade_canvas: CanvasLayer = $FadeCanvas 
# NOTA: Debes asegurarte de que estos nodos existan en la escena GameUI y se llamen SFX y BGM.
var UI_FADE_DURATION = 1

func _ready():
	# Establecer la opacidad inicial (si la UI debe empezar invisible)
	#self.modulate = Color(0, 0, 0, 0) 
	
	# 🚨 NOTA: fade_canvas es el sistema de fade de pantalla,
	# no tiene sentido ocultarlo aquí si es un Autoload.
	# Si 'GameUI' es la raíz de la UI, es mejor que controles 'self'.
	
	# Conectamos las señales al SignalBus (si se definen)
	SignalBus.ui_fade_in.connect(fade_in)
	SignalBus.ui_fade_out.connect(fade_out)
	SignalBus.sfx.connect(play_sfx)
# Hace que la UI se desvanezca (se vuelva transparente)
	
func fade_out(duration: float = UI_FADE_DURATION):
	# Usamos self para manipular la opacidad del nodo raíz (GameUI)
	var tween = create_tween()
	# Animamos el canal alfa (transparencia) de la modulación a 0.0
	tween.tween_property(self, "modulate:a", 0.0, duration)
	# Opcional: Esperar a que termine si se llama con 'await'
	return tween
# Hace que la UI aparezca (se vuelva visible)
func fade_in(duration: float = UI_FADE_DURATION):
	var tween = create_tween()
	
	# Animamos el canal alfa de la modulación a 1.0 (opaco)
	tween.tween_property(self, "modulate:a", 1.0, duration)
	
	# Opcional: Esperar a que termine si se llama con 'await'
	return tween
# ==============================================================================
# 1. FUNCIÓN PARA EFECTOS DE SONIDO (SFX) - Reproducción ÚNICA
# ==============================================================================
# @param path: La ruta al archivo .wav o .ogg (ej: "assets/audio/player/hit.wav")
func play_sfx(path: String):
	# Cargar el archivo de audio
	
	var audio_stream = load("res://Assets/audio/sfx/" + path)
	print("playing "+ str(audio_stream))
	# 1. Asignar el stream al reproductor SFX
	sfx_player.stream = audio_stream
	
	# 2. Desactivar el bucle (loop) para SFX
	# NOTA: En Godot 4, el loop se controla en el stream. 
	# Asegúrate de que tu archivo de audio no tenga el loop activado por defecto.
	
	# 3. Reproducir el SFX (solo se reproduce una vez)
	sfx_player.play()
	print("Audio Manager: Reproduciendo SFX desde ", path)


# ==============================================================================
# 2. FUNCIÓN PARA MÚSICA DE FONDO (BGM) - Reproducción en LOOP
# ==============================================================================
# @param path: La ruta al archivo de música
# @param volume_db: El volumen opcional (ej: -5.0)
func play_bgm(path: String, volume_db: float = 0.0):
	
	# 1. Detener la música actual (para evitar superposición)
	if bgm_player.playing:
		bgm_player.stop()

	# Cargar el archivo de audio
	var audio_stream = load("res://" + path)
	
	# 2. Asignar el stream y activar el bucle (loop)
	if audio_stream is AudioStreamWAV:
		# Debes configurar la propiedad 'loop' en el recurso AudioStream 
		# (usualmente se hace en el Inspector del recurso, NO desde el código).
		# Para forzarlo en código, a veces se requiere duplicar el recurso, 
		# pero lo más limpio es asegurarse de que el archivo de música tenga
		# la propiedad 'Loop' o 'Loop Mode' activada en su Inspector.
		
		# En Godot 3:
		# if audio_stream.has_method("set_loop"): audio_stream.set_loop(true)
		# En Godot 4, es más complejo, lo mejor es editar el Stream en el editor.
		pass # Asumimos que el recurso de audio .ogg o .mp3 ya tiene el loop activado en el Inspector.

	bgm_player.stream = audio_stream
	bgm_player.volume_db = volume_db
	
	# 3. Reproducir
	bgm_player.play()
	print("Audio Manager: Reproduciendo BGM en loop desde ", path)


# Función para detener BGM (útil para pantallas de pausa o carga)
func stop_bgm():
	bgm_player.stop()
	print("Audio Manager: BGM detenido.")
