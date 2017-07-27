
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec3 a_normal;
attribute vec3 a_tangent;
attribute vec3 a_binormal;

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
uniform mat4 u_inverseTransposeWorldViewMatrix;
uniform vec3 u_lightDirection;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;
varying vec3 v_lightDirection;



void main()
{
    v_texCoord = a_texCoord;
	
	//mat3 inverseTransposeWorldViewMatrix = mat3(u_inverseTransposeWorldViewMatrix[0].xyz, u_inverseTransposeWorldViewMatrix[1].xyz, u_inverseTransposeWorldViewMatrix[2].xyz);
    //vec3 normalVector = normalize(inverseTransposeWorldViewMatrix * a_normal);
    //vec3 tangentVector  = normalize(inverseTransposeWorldViewMatrix * a_tangent);
    //vec3 binormalVector = normalize(inverseTransposeWorldViewMatrix * a_binormal);
    //mat3 tangentSpaceTransformMatrix = mat3(tangentVector.x, binormalVector.x, normalVector.x, tangentVector.y, binormalVector.y, normalVector.y, tangentVector.z, binormalVector.z, normalVector.z);
	//v_lightDirection = tangentSpaceTransformMatrix * u_lightDirection;
	v_lightDirection = u_lightDirection;
	
    gl_Position = u_worldViewProjectionMatrix * a_position;
}
