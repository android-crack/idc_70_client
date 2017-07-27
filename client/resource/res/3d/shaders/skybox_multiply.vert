#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

// Attributes
attribute vec4 a_position;
attribute vec2 a_texCoord;

// Uniforms
uniform mat4 u_worldViewProjectionMatrix;

// Varyings
varying vec2 v_texCoord;


void main()
{
	v_texCoord = a_texCoord;
	gl_Position = u_worldViewProjectionMatrix * a_position;
}