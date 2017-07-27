#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif


///////////////////////////////////////////////////////////

//uniform sampler2D u_textures[TEXTURE_COUNT];
uniform sampler2D u_normalTex;
uniform sampler2D u_foamTex;

varying vec4 v_color1;
varying vec4 v_color2;

varying vec2 v_normalTexUV;
varying vec2 v_foamTexUV;
varying vec3 v_normalArgs;


#if defined(SPECULAR)
uniform vec4 u_specularColor;
uniform float u_shinessIntensity;
#endif

#if defined(BACKGROUND)
uniform  sampler2D u_backgroundTex;
uniform float u_backgroundAlphaOffset;
varying vec2 v_backgroundTexUV;
#endif


void main()
{
	vec4 normal = texture2D(u_normalTex, v_normalTexUV);
	vec2 n = vec2(v_normalArgs.x, 1.0 - v_normalArgs.x);
	float diff = dot(normal.xy, n);

	vec4 c = v_color1 * (1.0 - diff) + v_color2 * diff;
	vec4 texcolor = texture2D(u_foamTex, v_foamTexUV);
	c *= texcolor;
	
	#if defined(SPECULAR)
	float nh = clamp(v_normalArgs.y * dot(normal.zw, n), 0.0, 1.0);
	float spec = max(0.0, pow(nh, v_normalArgs.z));
	c.rgb += u_specularColor.rgb * spec *  u_shinessIntensity;
	//c.rgb += u_specularColor.rgb * spec;
	#endif

	#if defined(BACKGROUND)
	vec4 background = texture2D(u_backgroundTex, v_backgroundTexUV);
	c.a *= (u_backgroundAlphaOffset + background.a);
    c.rgb = c.rgb * c.a + background.rgb * (1.0 - c.a);;
	#endif

	gl_FragColor = c;
}

