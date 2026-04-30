#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
  vec4 c = texture(tex, v_texcoord);

  // Better balanced warm tone (no green cast)
  c.r *= 1.04; // slight red boost
  c.g *= 0.96; // reduce green a bit (important)
  c.b *= 0.75; // stronger blue cut

  // soften contrast slightly (easier on eyes)
  c.rgb = mix(vec3(0.5), c.rgb, 0.97);

  fragColor = c;
}
