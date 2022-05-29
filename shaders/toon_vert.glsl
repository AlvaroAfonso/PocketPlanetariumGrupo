uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;

uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8];

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying vec4 ecPosition;
varying vec3 ecNormal;

void main() {
    gl_Position = transform * position;
    ecPosition = vec4(vec3(modelview * position), 1.0);
    //ecNormal = normalize(normalMatrix * normal);
    ecNormal = normal;
}