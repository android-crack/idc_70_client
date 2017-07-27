
///////////////////////////////////////////////////////////
// Atributes
attribute vec4 a_position;

#if defined(VERTEX_COLOR)
attribute vec4 a_color;
varying vec4 v_color;
#endif

#if defined(SKINNING)
attribute vec4 a_blendWeights;
attribute vec4 a_blendIndices;
#endif

attribute vec2 a_texCoord;

#if defined(LIGHTMAP)
attribute vec2 a_texCoord1; 
#endif

#if defined(OUTLINE)
attribute vec3 a_normal;
#endif

///////////////////////////////////////////////////////////
// Uniforms
uniform mat4 u_worldViewProjectionMatrix;
#if defined(SKINNING)
uniform vec4 u_matrixPalette[SKINNING_JOINT_COUNT * 3];
#endif


#if defined(TEXTURE_FLOW)
uniform float u_time;
uniform vec4 u_texSpeed;
uniform vec4 u_diffuseTextureST;
uniform vec4 u_flowTexST;
#endif

#if defined(LIGHTMAP)
uniform vec4 u_lightmapST;
#endif

#if defined(GHOST)
uniform float u_pow;
uniform float u_pass;
uniform float u_dir;
#endif
///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;

#if defined(TEXTURE_FLOW)
varying vec2 v_flowTexCoord;
#endif

#if defined(LIGHTMAP)
varying vec2 v_texCoord1;
#endif

#if defined(SKINNING)
#include "skinning.vert"
#else
#include "skinning-none.vert" 
#endif


#if defined(OUTLINE)
uniform float u_outlineScale;
#endif

void main()
{
    vec4 position = getPosition();
	
    #if defined(OUTLINE)
	vec3 normal = getNormal();
	position.xyz += u_outlineScale * normal;
	#endif
	
	#if defined(GHOST)
	position.x-=u_pow*u_pass*u_dir;
	#endif
	
    gl_Position = u_worldViewProjectionMatrix * position;

	#if defined(VERTEX_COLOR)
	v_color = a_color;
	#endif
	
	#if defined(TEXTURE_FLOW)
	vec4 uvOffset = u_time * u_texSpeed;
	v_texCoord = (a_texCoord + uvOffset.xy) * u_diffuseTextureST.xy + u_diffuseTextureST.zw;
	v_flowTexCoord = (a_texCoord + uvOffset.zw) * u_flowTexST.xy + u_flowTexST.zw;
	#else
    v_texCoord = a_texCoord;
	#endif
    
    
    #if defined(LIGHTMAP)
    //v_texCoord1 = a_texCoord1;
	v_texCoord1 = a_texCoord1*u_lightmapST.xy + u_lightmapST.zw;
    #endif
}
