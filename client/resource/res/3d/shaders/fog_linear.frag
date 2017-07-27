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
uniform vec4 u_fogColor;
uniform float u_fogStart;
uniform float u_fogEnd;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_viewSpacePos;

void main()
{ 
	vec4 color = texture2D(u_diffuseTexture, v_texCoord)*u_mainColor;
	vec4 viewPos = v_viewSpacePos;
	viewPos.a = 0.0;
	float dist = length(viewPos);
	float fogFactor = (u_fogEnd - abs(dist))/(u_fogEnd - u_fogStart);
	fogFactor = clamp(fogFactor, 0.0, 1.0);
	color.rgb = mix(u_fogColor.rgb, color.rgb, fogFactor);
	
    gl_FragColor = color;
}
