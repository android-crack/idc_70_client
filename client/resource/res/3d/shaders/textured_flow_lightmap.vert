
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec2 a_texCoord1; 


///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform float u_time;
uniform vec4 u_texSpeed;
uniform vec4 u_diffuseTextureST;
uniform vec4 u_flowTexST;
uniform vec4 u_lightmapTextureST;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_flowTexCoord;
varying vec2 v_texCoord1;


#include "base.inc" 


void main()
{
	vec4 uvOffset = u_time * u_texSpeed;
	v_texCoord = (a_texCoord + uvOffset.xy) * u_diffuseTextureST.xy + u_diffuseTextureST.zw;
	v_flowTexCoord = (a_texCoord + uvOffset.zw) * u_flowTexST.xy + u_flowTexST.zw;
    v_texCoord1 = a_texCoord1*u_lightmapTextureST.xy + u_lightmapTextureST.zw;
	
    vec4 position = getPosition();
    gl_Position = u_worldViewProjectionMatrix * position;
}
