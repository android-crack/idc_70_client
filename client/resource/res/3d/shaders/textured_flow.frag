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

uniform vec4 u_flowTexColor;
uniform float u_flowIntensity;
uniform sampler2D u_flowTex;
uniform sampler2D u_maskTex;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_flowTexCoord;

void main()
{ 
    vec4 _baseColor = texture2D(u_diffuseTexture, v_texCoord) * u_mainColor;

	//对应工具上的standard混合方式
	vec4 mask = texture2D(u_maskTex, v_texCoord);
	vec4 flow = texture2D(u_flowTex, v_flowTexCoord) * u_flowTexColor * u_flowIntensity;
	vec3 flowMask = flow.rgb*mask.a;
	_baseColor.rgb += _baseColor.rgb*flowMask;

    gl_FragColor = _baseColor;
}
