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
uniform float u_lightmapAlpha;

uniform sampler2D u_lightmapTexture2;
uniform float u_lightmapIntensity2;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec2 v_texCoord1;
varying vec2 v_texCoord2;


void main()
{ 
    vec4 _baseColor = texture2D(u_diffuseTexture, v_texCoord) * u_mainColor;
	vec4 lightColor1 = texture2D(u_lightmapTexture, v_texCoord1);
	vec4 lightColor2 = texture2D(u_lightmapTexture2, v_texCoord2);
	vec4 color1 = vec4(_baseColor.rgb * lightColor1.rgb * lightColor1.a * u_lightmapIntensity, _baseColor.a);
	vec4 color2 = vec4(_baseColor.rgb * lightColor2.rgb * lightColor2.a * u_lightmapIntensity2, _baseColor.a);
	gl_FragColor = color1 * u_lightmapAlpha + color2 * (1.0 - u_lightmapAlpha);
}
