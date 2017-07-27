#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

// Inputs

varying vec2 v_uv;

uniform sampler2D u_diffuseTexture;
uniform vec4 u_mainColor;

void main()
{	
	vec4 color = texture2D(u_diffuseTexture, v_uv);
	gl_FragColor = color * u_mainColor;
}
