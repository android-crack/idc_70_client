#ifdef OPENGL_ES
precision mediump float;
#endif
// Inputs
attribute vec2 a_position;
attribute vec2 a_texCoord;

//uniform
uniform vec2 u_texelSize;
uniform float u_offsetScale;

// Varying
varying vec2 v_texCoord[8];

void main()
{
    gl_Position = vec4(a_position, 0, 1);

	vec2 uv = a_texCoord;
				
	vec2 up = vec2(0.0, u_texelSize.y) * u_offsetScale;
	vec2 right = vec2(u_texelSize.x, 0.0) * u_offsetScale;
			
	v_texCoord[0] = uv + up;
	v_texCoord[1] = uv - up;
	v_texCoord[2] = uv + right;
	v_texCoord[3] = uv - right;
	v_texCoord[4] = uv - right + up;
	v_texCoord[5] = uv - right -up;
	v_texCoord[6] = uv + right + up;
	v_texCoord[7] = uv + right -up;
}

