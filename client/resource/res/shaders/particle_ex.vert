///////////////////////////////////////////////////////////
// Attributes

//positionStart = a_position.xyz
//costTimeSec = a_position.w
attribute vec4 a_position;

//_velocity = a_tangent.xyz
//_angleStart = a_tangent.w
attribute vec4 a_tangent;

//_acceleration = a_binormal.xyz
//_rotationPerParticleSpeed = a_binormal.w
attribute vec4 a_binormal;

//texCoord = a_texCoord.xy
//_sizeStart = a_texCoord.z
//_sizeEnd  = a_texCoord.w
attribute vec4 a_texCoord;

//colorStart = a_color
attribute vec4 a_color;

//colorEnd = a_normal
attribute vec4 a_normal;

//percent = a_blendWeights.x
//colorLerpPrecent = a_blendWeights.y
//widthoffset = a_blendWeights.z
//heightoffset = a_blendWeights.w
attribute vec4 a_blendWeights;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_viewProjectionMatrix;
uniform mat4 u_transformMatrix;
uniform vec3 u_viewRight;
uniform vec3 u_viewUp;

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec4 v_color;

vec4 quaternionMul(vec4 q, vec4 r)
{
	vec3 qv = q.xyz;
	vec3 rv = r.xyz;

	return vec4(
		cross(qv, rv) + qv * r.w + q.w * rv,
		q.w * r.w - dot(qv, rv));
}

vec4 rotate(vec4 q, vec4 p)
{
	vec4 c = vec4(-1.0 * q.xyz, q.w);
	vec4 t = quaternionMul(q, p);
	return quaternionMul(t, c);
}

vec3 expand()
{
	vec3 position = a_position.xyz + a_tangent.xyz * a_position.w + a_binormal.xyz * a_position.w * a_position.w / 2.0;
	float halfSize = ( a_texCoord.z + (a_texCoord.w - a_texCoord.z) * a_blendWeights.x ) / 2.0;
	vec3 right = u_viewRight;
	vec3 up = u_viewUp;

	vec3 obj = right * halfSize * a_blendWeights.z + up * halfSize * a_blendWeights.w;

	vec3 forward = normalize(cross(right, up));
	float angle = ( a_tangent.w + a_binormal.w * a_position.w ) / 2.0;
	vec4 p = vec4(obj, 0.0);
	vec4 r = vec4(forward * sin(angle), cos(angle));
	vec4 worldPosition = u_transformMatrix * vec4( position.xyz, 1 );
	return worldPosition.xyz + rotate(r, p).xyz;
}

void main()
{
	vec3 position = expand();
    gl_Position = u_viewProjectionMatrix * vec4(position, 1);
    v_texCoord = a_texCoord.xy;
    v_color = a_color + (a_normal - a_color) * a_blendWeights.y;
}
