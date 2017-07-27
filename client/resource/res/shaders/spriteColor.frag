#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

///////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_color;
// Uniforms
uniform sampler2D u_texture;
uniform float minAlpha;

void main()
{
	
	vec4 texColor = v_color * texture2D(u_texture, v_texCoord);
	//if (texColor.a < minAlpha)
     //   discard;
    gl_FragColor = texColor;
	
}