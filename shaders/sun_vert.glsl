#define PI 3.1415926538

uniform mat4 modelviewMatrix;
uniform mat4 transformMatrix;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec2 texCoord;

varying vec3 ecPosition;
varying vec4 vertTexCoord;

void main() {
  //Vértice en coordenadas transformadas
  gl_Position = transformMatrix * position;
  
  //Posición del vértice en coordenadas del ojo
  ecPosition = vec3(modelviewMatrix * position);  
  
  //Coordenada de textura
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}
