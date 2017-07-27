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
uniform sampler2D u_normalTexture;

uniform vec4 u_lightColor;
uniform float u_lightIntensity;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec3 v_lightDirection;


void main()
{ 
	vec4 baseColor = texture2D(u_diffuseTexture, v_texCoord)*u_mainColor;
	vec3 normalVector = normalize(texture2D(u_normalTexture, v_texCoord).rgb * 2.0 - 1.0);
	float diffuse = max(dot(normalVector, normalize(v_lightDirection)), 0.0);
	
	vec4 c;
	c.rgb = baseColor.rgb + baseColor.rgb * u_lightColor.rgb * diffuse * u_lightIntensity; 
	c.a = baseColor.a;
	
    gl_FragColor = c;
}
