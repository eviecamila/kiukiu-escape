shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);  // Dirección (horizontal)
uniform float speed = 0.5;                // Velocidad controlada (ej. 0.5)
uniform float amplitude = 0.1;            // Amplitud reducida

void fragment() {
    // Genera un tiempo suave y controlado
    float time = TIME * speed * 0.1;  // Multiplicar por 0.1 para reducir la velocidad

    // Onda triangular para movimiento de ida y vuelta
    float triangle_wave = abs(fract(time) * 2.0 - 1.0);

    // Aplicar desplazamiento con amplitud controlada
    vec2 offset = direction * triangle_wave * amplitude;

    // Muestrear la textura con el desplazamiento
    COLOR = texture(TEXTURE, UV + offset);
}