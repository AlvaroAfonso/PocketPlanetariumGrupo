#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8];
uniform float opacity;

varying vec4 ecPosition;
varying vec3 ecNormal;

void main() {
  vec4 color;
  float intensity;
  vec3 direction = normalize(lightPosition[0].xyz - ecPosition.xyz);
  intensity = max(0.0, dot(direction, ecNormal));
if (intensity >= 0.99) {
color = vec4(1.0, 1.0, 1.0, opacity);
} else {
	color = vec4(0.4, 0.4, 0.5, opacity);
}
   
  gl_FragColor = color;
}