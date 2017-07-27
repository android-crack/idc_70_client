#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

// Inputs
attribute vec2 a_position;

// Uniforms
uniform mat4 u_worldMatrix;
uniform mat4 u_viewProjectionMatrix;

// Varying
varying vec2 v_uv;

void main()
{
	vec2 pos = a_position;
	
	vec4 world_position = u_worldMatrix[3];
	vec4 clip_position = u_viewProjectionMatrix * world_position;
	vec2 offset = 0.5 * (clip_position.xy / clip_position.w + 1.0) - vec2(0.5, 0.5);

	vec2 scale = vec2(u_worldMatrix[0][0], u_worldMatrix[1][1]);
	v_uv =  0.5 * (a_position.xy + 1.0) - offset / scale;
	gl_Position = vec4(pos * scale, 0, 1);
}
