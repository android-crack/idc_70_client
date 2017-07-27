
#ifdef OPENGL_ES
precision mediump float;
#endif

//uniform
uniform sampler2D u_texture;
uniform vec2 u_texelSize;
uniform float u_blurRadius;

// Varying
varying vec2 v_texCoord[8];

float luminance(vec3 color)
{
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
	return gray;
}

vec4 frag()
{	
	// get luminance values
	//  maybe: experiment with different luminance calculations
	float topL = luminance( texture2D(u_texture, v_texCoord[0]).rgb );
	float bottomL = luminance( texture2D(u_texture, v_texCoord[1]).rgb );
	float rightL = luminance( texture2D(u_texture, v_texCoord[2]).rgb );
	float leftL = luminance( texture2D(u_texture, v_texCoord[3]).rgb );
	float leftTopL = luminance( texture2D(u_texture, v_texCoord[4]).rgb );
	float leftBottomL = luminance( texture2D(u_texture, v_texCoord[5]).rgb );
	float rightBottomL = luminance( texture2D(u_texture, v_texCoord[6]).rgb );
	float rightTopL = luminance( texture2D(u_texture, v_texCoord[7]).rgb );
	
	// 2 triangle subtractions
	float sum0 = dot(vec3(1,1,1), vec3(rightTopL,bottomL,leftTopL));
	float sum1 = dot(vec3(1,1,1), vec3(leftBottomL,topL,rightBottomL));
	float sum2 = dot(vec3(1,1,1), vec3(leftTopL,rightL,leftBottomL));
	float sum3 = dot(vec3(1,1,1), vec3(rightBottomL,leftL,rightTopL));

	// figure out "normal"
	vec2 blurDir = vec2((sum0-sum1), (sum3-sum2));
	blurDir *= u_texelSize * u_blurRadius;

	// reconstruct normal uv
	vec2 uv_ = (v_texCoord[0] + v_texCoord[1]) * 0.5;
	 
	vec4 returnColor = texture2D(u_texture, uv_);
	returnColor += texture2D(u_texture, uv_+ blurDir.xy);
	returnColor += texture2D(u_texture, uv_ - blurDir.xy);
	returnColor += texture2D(u_texture, uv_ + vec2(blurDir.x, -blurDir.y));
	returnColor += texture2D(u_texture, uv_ - vec2(blurDir.x, -blurDir.y));

	return returnColor * 0.2;
}

vec4 fragDebug()
{	
	// get luminance values
	//  maybe: experiment with different luminance calculations
	float topL = luminance( texture2D(u_texture, v_texCoord[0]).rgb );
	float bottomL = luminance( texture2D(u_texture, v_texCoord[1]).rgb );
	float rightL = luminance( texture2D(u_texture, v_texCoord[2]).rgb );
	float leftL = luminance( texture2D(u_texture, v_texCoord[3]).rgb );
	float leftTopL = luminance( texture2D(u_texture, v_texCoord[4]).rgb );
	float leftBottomL = luminance( texture2D(u_texture, v_texCoord[5]).rgb );
	float rightBottomL = luminance( texture2D(u_texture, v_texCoord[6]).rgb );
	float rightTopL = luminance( texture2D(u_texture, v_texCoord[7]).rgb );
	
	// 2 triangle subtractions
	float sum0 = dot(vec3(1,1,1), vec3(rightTopL,bottomL,leftTopL));
	float sum1 = dot(vec3(1,1,1), vec3(leftBottomL,topL,rightBottomL));
	float sum2 = dot(vec3(1,1,1), vec3(leftTopL,rightL,leftBottomL));
	float sum3 = dot(vec3(1,1,1), vec3(rightBottomL,leftL,rightTopL));

	// figure out "normal"
	vec2 blurDir = vec2((sum0-sum1), (sum3-sum2));
	blurDir *= u_texelSize * u_blurRadius;

	// reconstruct normal uv
	vec2 uv_ = (v_texCoord[0] + v_texCoord[1]) * 0.5;
	 
	vec4 returnColor = texture2D(u_texture, uv_);
	returnColor += texture2D(u_texture, uv_+ blurDir.xy);
	returnColor += texture2D(u_texture, uv_ - blurDir.xy);
	returnColor += texture2D(u_texture, uv_ + vec2(blurDir.x, -blurDir.y));
	returnColor += texture2D(u_texture, uv_ - vec2(blurDir.x, -blurDir.y));

	blurDir = vec2((sum0-sum1), (sum3-sum2)) * u_blurRadius;
	return vec4(normalize( vec3(blurDir,1) * 0.5 + 0.5), 1);
}	

void main()
{
	#ifdef DEBUG
		gl_FragColor = fragDebug();
	#else
		gl_FragColor = frag();
	#endif
}

	
