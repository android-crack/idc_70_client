#include "particle_common.vert" 
///////////////////////////////////////////////////////////
// Attributes
attribute vec3 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec3 a_normal;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_viewProjectionMatrix;
uniform mat4 u_transformMatrix;
uniform vec3 u_viewRight;
uniform vec3 u_viewUp;
///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_color;

void main()
{
	float halfW = a_normal.x;
	float halfH = a_normal.y;
	float angle = a_normal.z;

	vec3 position = expand(halfW, halfH, u_viewRight, u_viewUp, angle, a_position.xyz, u_transformMatrix);
	gl_Position = u_viewProjectionMatrix * vec4(position, 1.0);
	v_texCoord = a_texCoord;
	v_color = a_color;
}
