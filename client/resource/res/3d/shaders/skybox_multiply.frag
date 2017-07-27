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

uniform float u_effectAlpha;
uniform sampler2D u_effectTexture;

// Varyings
varying vec2 v_texCoord;

void main()
{
	vec4 color = texture2D(u_diffuseTexture, v_texCoord)*u_mainColor;
	vec4 effectColor = texture2D(u_effectTexture, v_texCoord)*u_mainColor;
	gl_FragColor = effectColor * u_effectAlpha + color * (1.0 - u_effectAlpha);
}