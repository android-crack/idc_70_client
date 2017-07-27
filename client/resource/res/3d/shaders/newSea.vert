
#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

// Attributes
attribute vec4 a_position;
attribute vec2 a_texCoord0;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;

uniform float u_time;
uniform float u_scale;

uniform mat4 u_worldMatrix;
uniform vec2 u_columnShift[COLUMN];
uniform vec2 u_rowShift[ROW];

uniform float u_colorProgress; 
uniform vec4  u_centerColor1 ;
uniform vec4  u_edgeColor1;
uniform vec4  u_centerColor2;
uniform vec4  u_edgeColor2;

			  
#if defined(VERTEX_ANIMATION)
uniform vec4 u_vertexWaveArg;
uniform vec4 u_vertexWaveDir;
vec4 Gerstner(vec4 position)
{
	vec4 worldPosition = u_worldMatrix * position;
	
	vec3 offsets;
	vec3 wavedir = vec3(u_vertexWaveDir.x, 0.0, u_vertexWaveDir.y);
	vec2 dir = normalize(wavedir).xz;

	float amplitude = u_vertexWaveArg.x;
	float length = u_vertexWaveArg.y;
	float speed = u_vertexWaveArg.z;
	float steepness = u_vertexWaveArg.w;
	float pi = 3.14;

	float angle = (dot(dir, worldPosition.xz) + u_time * speed) * 2.0 * pi / length;
	offsets.y = amplitude * sin(angle);
	offsets.xz = dir * steepness * amplitude * cos(angle); 
	position.xyz += offsets;
	
	return position;			
}
#endif

uniform vec4 u_uvSpeed;

uniform vec4 u_normalTexST;
uniform vec4 u_foamTexST;
uniform float u_normalMovement;

varying vec2 v_normalTexUV;
varying vec3 v_normalArgs;
varying vec2 v_foamTexUV;



varying vec4 v_color1;
varying vec4 v_color2;

#if defined(SPECULAR)
uniform vec4 u_shiness;
#endif

#if defined(BACKGROUND)
uniform vec4 u_backgroundTexST;
varying vec2 v_backgroundTexUV;
#endif


void calcUV(vec2 coffset, vec2 roffset)
{
	vec2 uv = a_texCoord0;

	uv.x += coffset.y;
	uv.y += roffset.y;

	vec4 uvOffset = u_time * u_uvSpeed;

	v_normalTexUV = (uv + uvOffset.zw) * u_normalTexST.xy + u_normalTexST.zw;
	v_foamTexUV = (uv + uvOffset.xy) * u_foamTexST.xy + u_foamTexST.zw;
	
	#if defined(BACKGROUND)
	v_backgroundTexUV = uv * u_backgroundTexST.xy + u_backgroundTexST.zw;
	#endif
}

void calcLight(vec4 position)
{
	float blender = cos(position.x + position.z + position.y + u_time * 6.28 /u_normalMovement);

	v_normalArgs.x = (blender + 1.0) * 0.5;	
	//TODO: == gl_Position
	vec4 out_pos = u_worldViewProjectionMatrix * position;
	float dxy2 = dot(out_pos.xy, out_pos.xy);
	float m =  dxy2/(2.0 * u_colorProgress);
	float dm = 1.0 - m;
	v_color1 = u_centerColor1 * dm + u_edgeColor1 * m ;
	v_color2 = u_centerColor2 * dm + u_edgeColor2 * m;
	
	#if defined(SPECULAR)
	//v_normalArgs.y = u_shinessPower;
	//v_normalArgs.z =  ((1.0 - u_baseColor.a) + blender) * 0.5;
	float minangle = u_shiness.x * 3.14/180.0;
	float maxangle = u_shiness.y * 3.14/180.0;
	float span = maxangle - minangle;
	float angle = minangle + span * dxy2/2.0;
	v_normalArgs.y = cos(angle);
	v_normalArgs.z = u_shiness.z + v_normalArgs.y * u_shiness.w;
	#endif
}

void main()
{
	vec4 pos = vec4(a_position.x, 0.0, a_position.z, 1);

	int c = int(a_position.y);
	int r = int(a_position.w);
	vec2 coffset = u_columnShift[c];
	vec2 roffset = u_rowShift[r];
	pos.x += coffset.x;
	pos.z += roffset.x;

	#if defined(VERTEX_ANIMATION)
	pos = Gerstner(pos);
	#endif

    gl_Position = u_worldViewProjectionMatrix * pos;
	calcUV(coffset, roffset);
	calcLight(pos);
}

