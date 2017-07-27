
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;
attribute vec2 a_texCoord;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform mat4 u_worldViewMatrix;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_viewSpacePos;

#include "base.inc" 

void main()
{
    v_texCoord = a_texCoord;
    vec4 position = getPosition();
	v_viewSpacePos = u_worldViewMatrix * position;
    gl_Position = u_worldViewProjectionMatrix * position;
}
