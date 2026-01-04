#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    c.r *= 1.0;
    c.g *= 0.85;
    c.b *= 0.65;
    fragColor = c;
}
