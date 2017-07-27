#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

///////////////////////////////////////////////////////////
// Uniforms
#if defined(MAIN_COLOR)
uniform vec4 u_mainColor;
uniform float u_mainIntensity;
#endif
uniform sampler2D u_diffuseTexture;

#if defined(LIGHTMAP)
uniform sampler2D u_lightmapTexture;
uniform float u_lightmapIntensity;
#endif


///////////////////////////////////////////////////////////
// Variables
vec4 _baseColor;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;

#if defined(LIGHTMAP)
varying vec2 v_texCoord1;
#endif


#if defined(OUTLINE)
uniform vec3 u_outlineColor;
#endif
#if defined(TEXTURE_FLOW)
uniform vec4 u_flowTexColor;
varying vec2 v_flowTexCoord;
uniform sampler2D u_flowTex;
uniform sampler2D u_maskTex;
uniform float u_flowIntensity;
#endif

#if defined(VERTEX_COLOR)
varying vec4 v_color;
#endif


void main()
{ 
    _baseColor = texture2D(u_diffuseTexture, v_texCoord);
	#if defined(MAIN_COLOR)
	_baseColor *= u_mainColor*u_mainIntensity; 
	#endif
	
	#if defined(VERTEX_COLOR)
	_baseColor *= v_color;
	#endif

    gl_FragColor.a = _baseColor.a;

	//TODO:remove discard
	///The GPU cannot perform hidden surface removal when blending or alpha testing is enabled,
	//or if a fragment shader uses the discard instruction or writes to the gl_FragDepth output variable. 
	//In these cases, the GPU cannot decide the visibility of a fragment using the depth buffer,
	//so it must run the fragment shaders for all primitives covering each pixel, 
	//greatly increasing the time and energy required to render a frame. 
	//To avoid this performance cost, minimize your use of blending, discard instructions, and depth writes.	
	
	//or Instead of using alpha testing or discard instructions to kill pixels,
	//use alpha blending with alpha set to zero. The color framebuffer is not modified, 
	//but the graphics hardware can still use any Z-buffer optimizations it performs.
	//This does change the value stored in the depth buffer and so may require back-to-front sorting of the transparent primitives
    #if defined(TEXTURE_DISCARD_ALPHA)
    if (gl_FragColor.a < 0.1)
        discard;
	   //gl_FragColor.a = step(0.5,  _baseColor.a);
	#else
	   //gl_FragColor.a = _baseColor.a;

    #endif

	//TODO:流光混合方式要改
	#if defined(TEXTURE_FLOW)
	//vec4 mask = texture2D(u_maskTex, v_texCoord);
 	//vec4 flowColor = texture2D(u_flowTex, v_flowTexCoord) * u_flowTexColor* 2.0 * u_flowIntensity;
	//_baseColor.rgb += flowColor.rgb * flowColor.a * mask.a;
	
	//对应工具上的standard混合方式
	vec4 mask = texture2D(u_maskTex, v_texCoord);
	vec4 flow = texture2D(u_flowTex, v_flowTexCoord) * u_flowTexColor * 2.0 * u_flowIntensity;
	vec3 flowMask = flow.rgb*mask.a;
	_baseColor.rgb += _baseColor.rgb*flowMask;
	#endif


    #if defined(OUTLINE)
	gl_FragColor.rgb = u_outlineColor;
	return;
	#endif

    gl_FragColor.rgb = _baseColor.rgb;
 
	#if defined(LIGHTMAP)
	vec4 lightColor = texture2D(u_lightmapTexture, v_texCoord1);
	gl_FragColor.rgb *= lightColor.rgb*lightColor.a*u_lightmapIntensity;
	#endif
 
}
