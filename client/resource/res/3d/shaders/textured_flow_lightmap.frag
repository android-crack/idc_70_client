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
uniform vec4 u_flowTexColor;
uniform sampler2D u_flowTex;
uniform sampler2D u_maskTex;
uniform float u_flowIntensity;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_texCoord1;
varying vec2 v_flowTexCoord;


void main()
{ 
    vec4 _baseColor = texture2D(u_diffuseTexture, v_texCoord) * u_mainColor;
	
	//对应工具上的standard flow混合方式
	vec4 mask = texture2D(u_maskTex, v_texCoord);
	vec4 flow = texture2D(u_flowTex, v_flowTexCoord) * u_flowTexColor * u_flowIntensity;
	vec3 flowMask = flow.rgb*mask.a;
	_baseColor.rgb += _baseColor.rgb*flowMask;
	
	// light
	vec4 lightColor = texture2D(u_lightmapTexture, v_texCoord1);
	_baseColor.rgb *= lightColor.rgb*lightColor.a*u_lightmapIntensity;
	
    gl_FragColor = _baseColor;
}
