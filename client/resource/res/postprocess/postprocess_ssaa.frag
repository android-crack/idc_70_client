
#ifdef OPENGL_ES
precision mediump float;
#endif

// Uniforms
uniform sampler2D u_texture;
uniform vec2 u_texelSize;
// Inputs
varying vec2 v_texCoord[5];
//varying vec2 v_texelSize;

float luminance(vec4 color)
{
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	return gray;
}

void main()
{
	float t = luminance(texture2D(u_texture, v_texCoord[0])); 
	float l = luminance(texture2D(u_texture, v_texCoord[1])); 
	float r = luminance(texture2D(u_texture, v_texCoord[2])); 
	float b = luminance(texture2D(u_texture, v_texCoord[3])); 

 
	vec2 n = vec2( -( t - b ), r - l );
	float nl = length(n);
 
	if ( nl < (1.0 / 16.0) ) {
		#ifdef DEBUG
		gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);	
		#else
		gl_FragColor = texture2D(u_texture, v_texCoord[4]); 
		#endif
	} else {
		n *= u_texelSize.xy / nl;
 
		vec4 o = texture2D(u_texture, v_texCoord[4]);
		vec4 t0 = texture2D(u_texture, v_texCoord[4] + n * 0.5) * 0.9;
		vec4 t1 = texture2D(u_texture, v_texCoord[4] - n * 0.5) * 0.9;
		vec4 t2 = texture2D(u_texture, v_texCoord[4] + n) * 0.75;
		vec4 t3 = texture2D(u_texture, v_texCoord[4] - n) * 0.75;
 
		#ifdef DEBUG
		gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);	
		#else
		gl_FragColor = (o + t0 + t1 + t2 + t3) / 4.3;
		#endif
	}
}

