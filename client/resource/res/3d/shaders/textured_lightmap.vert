
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec2 a_texCoord1; 


///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform vec4 u_lightmapTextureST;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_texCoord1;

#include "base.inc" 

void main()
{
	v_texCoord = a_texCoord;
	v_texCoord1 = a_texCoord1*u_lightmapTextureST.xy + u_lightmapTextureST.zw;
	
    vec4 position = getPosition();
    gl_Position = u_worldViewProjectionMatrix * position;
}
