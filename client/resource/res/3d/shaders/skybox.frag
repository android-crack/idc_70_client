#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

// Uniforms
uniform sampler2D u_diffuseTexture;
uniform vec4 u_mainColor;

// Varyings
varying vec2 v_texCoord;

void main()
{
	vec4 color = texture2D(u_diffuseTexture, v_texCoord);
	gl_FragColor = color * u_mainColor;
}