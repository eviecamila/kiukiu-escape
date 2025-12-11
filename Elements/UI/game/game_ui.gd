# Audio_Manager.gd (Reemplaza el contenido de tu game_ui.gd)

extends Node

# Referencias a los nodos de audio hijos
@onready var sfx_player: AudioStreamPlayer = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGM 
@onready var fade_canvas: CanvasLayer = $FadeCanvas 
# NOTA: Debes asegurarte de que estos nodos existan en la escena GameUI y se llamen SFX y BGM.
var songs_list: PackedStringArray = ["intro.wav", "Frenetic Puzzle.wav"] 
# ^ ¡REEMPLAZA ESTO con las rutas de tus archivos de música!
var current_song_index: int = 0
var UI_FADE_DURATION = 1
func _input(event: InputEvent):
	# Usamos is_action_pressed en el evento para capturar la pulsación única.
	if event.is_action_pressed("song_next"):
		print('a')
		# Asegúrate de que el input no se use para otras cosas
		if event is InputEventKey or event is InputEventMouseButton:
			change_song(1)
			
			
	if event.is_action_pressed("song_prev"):
		print('a')
		if event is InputEventKey or event is InputEventMouseButton:
			change_song(-1)
func change_song(direction: int):
	# 1. Calcular el nuevo índice (usando el operador '%' para envolver la lista)
	current_song_index += direction
	
	# El operador '% current_song_index' asegura que el índice siempre esté dentro del rango [0, size-1].
	# Para manejar índices negativos (prev) en Godot 4:
	if current_song_index < 0:
		current_song_index = songs_list.size() - 1
	elif current_song_index >= songs_list.size():
		current_song_index = 0
		
	# 2. Reproducir la nueva canción
	play_bgm(songs_list[current_song_index])
	print("Cambiando a canción #", current_song_index, ": ", songs_list[current_song_index])
func _ready():
	
	# Establecer la opacidad inicial (si la UI debe empezar invisible)
	#self.modulate = Color(0, 0, 0, 0) 
	
	# 🚨 NOTA: fade_canvas es el sistema de fade de pantalla,
	# no tiene sentido ocultarlo aquí si es un Autoload.
	# Si 'GameUI' es la raíz de la UI, es mejor que controles 'self'.
	play_bgm(songs_list[0])
	# Conectamos las señales al SignalBus (si se definen)
	SignalBus.ui_fade_in.connect(fade_in)
	SignalBus.ui_fade_out.connect(fade_out)
	SignalBus.input.connect(_input)
	SignalBus.sfx.connect(play_sfx)
	SignalBus.bgm.connect(play_bgm)
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
func play_bgm(path: String, volume_db: float = 0.0, loop: bool = true):
	
	# 1. Detener la música actual (para evitar superposición)
	if bgm_player.playing:
		bgm_player.stop()

	# Cargar el archivo de audio
	var audio_stream = load("res://Assets/audio/bgm/" + path)
	
	# Verificar si el recurso existe y es un stream de audio
	if not audio_stream is AudioStream:
		print("ERROR: No se pudo cargar el stream de audio para BGM desde ", path)
		return

	# 2. Asignar el stream y configurar el volumen
	
	# **NOTA CRÍTICA SOBRE EL LOOP:**
	# En Godot 4, para que el loop funcione en código, debes asegurarte
	# de que el recurso (el archivo .ogg/.mp3) tenga la propiedad 'Loop' activada
	# en su Inspector (selecciona el archivo en FileSystem y ve al Inspector).
	
	# Si estás usando AudioStreamOggVorbis/AudioStreamMP3, puedes intentar
	# forzarlo si la clase tiene el método o la propiedad, PERO NO ES RECOMENDADO:
	# if audio_stream is AudioStreamOggVorbis and loop:
	#     audio_stream.loop = true # (Esto no siempre funciona en tiempo de ejecución)
	
	# Confiamos en que si loop=true (por defecto), el recurso está configurado.
	
	bgm_player.stream = audio_stream
	bgm_player.volume_db = volume_db
	
	# 3. Reproducir
	bgm_player.play()
	print("Audio Manager: Reproduciendo BGM en loop desde ", path)

# Función para detener BGM (útil para pantallas de pausa o carga)
func stop_bgm():
	bgm_player.stop()
	print("Audio Manager: BGM detenido.")
