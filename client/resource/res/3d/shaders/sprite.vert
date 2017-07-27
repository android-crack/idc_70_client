///////////////////////////////////////////////////////////
// Attributes
attribute vec3 a_position;
attribute vec2 a_texCoord;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform vec4 u_mainColor;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_color;


void main()
{
    gl_Position = u_worldViewProjectionMatrix * vec4(a_position, 1);
    v_texCoord = a_texCoord;
    v_color = u_mainColor;
}
