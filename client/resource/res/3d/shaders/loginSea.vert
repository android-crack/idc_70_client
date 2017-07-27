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


// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform mat4 u_worldMatrix;
uniform vec2 u_columnShift[COLUMN];
uniform vec2 u_rowShift[ROW];

uniform vec3 u_cameraPosition;
uniform vec4 u_diffuseTextureST;


// Varyings
//varying vec2 v_texCoord;

varying vec2 v_mainTexUV;
varying vec2 v_waterMapUV;

// 计算cameraWorldPos - vertexWorldPos
varying vec3 v_viewDir;

void main()
{
	vec4 pos = vec4(a_position.x, 0.0, a_position.z, 1);

	int c = int(a_position.y);
	int r = int(a_position.w);
	vec2 coffset = u_columnShift[c];
	vec2 roffset = u_rowShift[r];
	pos.x += coffset.x;
	pos.z += roffset.x;
 
	v_mainTexUV = a_texCoord0 * u_diffuseTextureST.xy + u_diffuseTextureST.zw;
	v_waterMapUV = a_texCoord0;

	vec4 worldPosition = u_worldMatrix * pos;
	v_viewDir = u_cameraPosition - worldPosition.xyz;
	vec4 resPos = u_worldViewProjectionMatrix * pos;
	gl_Position = resPos;

	
}