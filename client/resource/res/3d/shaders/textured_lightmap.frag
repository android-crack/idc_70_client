#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

///////////////////////////////////////////////////////////
// Uniforms
uniform vec4 u_mainColor;
uniform sampler2D u_diffuseTexture;
uniform sampler2D u_lightmapTexture;
uniform float u_lightmapIntensity;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_texCoord1;


void main()
{ 
    vec4 _baseColor = texture2D(u_diffuseTexture, v_texCoord) * u_mainColor;
	vec4 lightColor = texture2D(u_lightmapTexture, v_texCoord1);
	_baseColor.rgb *= lightColor.rgb*lightColor.a*u_lightmapIntensity;
	gl_FragColor = _baseColor;
}
