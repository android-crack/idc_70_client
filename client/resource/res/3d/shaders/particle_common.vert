
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


vec3 expand(float halfW, float halfH, vec3 viewRight, vec3 viewUp, float angle, vec3 localPos, mat4 worldMat)
{
	vec3 obj = halfW * viewRight + halfH * viewUp;
	vec3 forward = normalize(cross(viewRight, viewUp));
	angle = angle/2.0;
	vec4 p = vec4(obj, 0.0);
	vec4 r = vec4(forward * sin(angle), cos(angle));
	vec4 worldPosition = worldMat * vec4( localPos, 1.0 );
	return worldPosition.xyz + rotate(r, p).xyz;
}