shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 0.0; // control del reveal
uniform vec2 center = vec2(0.5, 0.5); // centro (en UV)

void fragment() {
    vec2 uv = UV;
    float dist = distance(uv, center);

    // si la distancia es menor al radio, mostramos el pixel
    float alpha = step(dist, radius);

    vec4 tex = texture(TEXTURE, uv);
    COLOR = vec4(tex.rgb, tex.a * alpha);
}
