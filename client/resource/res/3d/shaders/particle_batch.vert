///////////////////////////////////////////////////////////
// Attributes
attribute vec3 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
attribute vec4 a_normal;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_viewProjectionMatrix;
//uniform mat4 u_transformMatrix;
//uniform vec3 u_viewRight;
//uniform vec3 u_viewUp;

#define CAPACITY 32 
#define UPRIGHG_CAPACITY (CAPACITY * 2)

uniform mat4 u_transformMatrix[CAPACITY];
uniform vec3 u_viewUpRight[UPRIGHG_CAPACITY];
//uniform vec3 u_viewRight[CAPACITY];
//uniform vec3 u_viewUp[CAPACITY];

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
	float w = a_normal.x;
	float h = a_normal.y;
	float angle = a_normal.z/2.0;
	int idx = int(a_normal.w);

	//vec3 up = u_viewUp[idx];
	//vec3 right = u_viewRight[idx];
	int idx2 = idx * 2;
	vec3 up = u_viewUpRight[idx];
	vec3 right = u_viewUpRight[idx + 1];
	vec4 worldPosition = u_transformMatrix[idx] * vec4( a_position.xyz, 1.0 );

	//vec3 right = u_viewRight;
	//vec3 up = u_viewUp;
	//vec4 worldPosition = u_transformMatrix * vec4( a_position.xyz, 1.0 );

	vec3 p3 = w * right + h * up;
	vec4 p = vec4(p3, 0.0);
	vec3 forward = normalize(cross(right, up));
	vec4 r = vec4(forward * sin(angle), cos(angle));
	return worldPosition.xyz + rotate(r, p).xyz;
}

void main()
{
	vec3 position = expand();
	gl_Position = u_viewProjectionMatrix * vec4(position, 1.0);
	v_texCoord = a_texCoord;
	v_color = a_color;
}
