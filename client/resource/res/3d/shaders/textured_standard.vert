
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;
attribute vec2 a_texCoord;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;

#include "base.inc" 

void main()
{
    v_texCoord = a_texCoord;
    vec4 position = getPosition();
    gl_Position = u_worldViewProjectionMatrix * position;
}
