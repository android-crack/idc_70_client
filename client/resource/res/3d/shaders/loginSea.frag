#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

#define WATER_SPECULAR

// Uniforms
uniform vec4 u_mainColor;
uniform samplerCube _Cube;
uniform sampler2D _WaterMap;

uniform sampler2D _NormalMap;
uniform float _WaterAttenuation;
uniform float _normalStrength;
uniform vec4 _ShallowWaterTint;
uniform vec4 _DeepWaterTint;
uniform float _Reflectivity;
uniform float _Opaqueness;


uniform float _Fresnel0;
uniform float _Shininess;
uniform float _Gloss;
uniform vec4 u_lightDir;
uniform vec4 u_lightColor;
uniform vec4 u_ambentColor;

// Varyings
varying vec2 v_mainTexUV;
varying vec2 v_waterMapUV;

// 计算cameraWorldPos - vertexWorldPos
varying vec3 v_viewDir;

vec3 CombineEffectsWithLighting(							 
								float refrStrength,										
								vec3 reflection,						
								vec3 pNormal,								
								vec3 normViewDir,
								float waterAttenuationValue
							)
{

	
	#ifdef WATER_SPECULAR

	vec3 normLightDir = normalize(u_lightDir).rgb;
	float nDotView = dot(pNormal, normViewDir);		//Masking
	float nDotLight = dot(pNormal, normLightDir);	//Shadows (diffuse)
	vec3 anisoDir = normalize( cross(pNormal, normLightDir) );
	float lightDotT = dot(normLightDir, anisoDir);
	float viewDotT = dot(normViewDir, anisoDir);
	float spec = sqrt(1.0 - lightDotT * lightDotT) * sqrt(1.0 - viewDotT * viewDotT) - lightDotT * viewDotT;
	spec = pow(spec, _Shininess * 128.0);
	spec *= _Gloss;
	//Masking & self-shadowing
	spec *= max(.0, nDotView) * max(.0, nDotLight);
	//Prevent highlights from leaking to the wrong side of the light
	spec *= max(sign(dot(normViewDir, -normLightDir)), 0.0); 
	float specularComponent = spec;
	specularComponent *= u_lightColor.r / 2.0;
	float fresnel = _Fresnel0 + (1.0 - _Fresnel0) * pow( (1.0 - nDotView ), 5.0);
	fresnel = max(0.0, fresnel - .1);
	specularComponent *= fresnel;
	specularComponent = specularComponent * specularComponent * 10.0;

	#else

	float nDotView = dot(pNormal, normViewDir);	
	float fresnel = _Fresnel0 + (1.0 - _Fresnel0) * pow( (1.0 - nDotView ), 5.0);
	fresnel = max(0.0, fresnel - .1);

	#endif

	vec3 finalColor;
    finalColor = mix(_ShallowWaterTint.rgb, _DeepWaterTint.rgb, waterAttenuationValue);

	//!!!!!!!!!!!!!!!!!!!!
	//!Magic! Don't touch!
	//!!!!!!!!!!!!!!!!!!!!

	vec3 refraction = _ShallowWaterTint.rgb * refrStrength * 0.5;
	finalColor.rgb = mix(refraction, finalColor.rgb, clamp( (max(waterAttenuationValue, refrStrength * .5) * 0.8), 0.0, 1.0 ) );

    //Add reflection，fresnel reflection
	finalColor.rgb = mix(finalColor.rgb, reflection, clamp(fresnel, 0.0, _Reflectivity) );

	#ifdef WATER_SPECULAR
	return (finalColor * u_lightColor.rgb + specularComponent) + u_ambentColor.rgb * .5;
	#else
	return (finalColor * u_lightColor.rgb) + u_ambentColor.rgb * .5;
	#endif
}

vec3 UnpackNormal(sampler2D tex, vec2 uv)
{
	vec3 value = texture2D(tex, uv).rgb;
	value = value * 2.0 - 1.0;
	return value;
}

vec3 CalculateNormalInTangentSpace(vec2 uv_MainTex)
{
		vec3 pNormal = UnpackNormal(_NormalMap, v_mainTexUV);
		pNormal.z /= _normalStrength;
		pNormal = normalize(pNormal);	//Very very important to normalize!!!
		return pNormal;
}


void main()
{
	vec4 outColor = u_mainColor;
	vec4 waterMapValue = texture2D(_WaterMap, v_waterMapUV);
	vec3 normViewDir = normalize(v_viewDir);
	vec3 pNormal = CalculateNormalInTangentSpace(v_mainTexUV);
	pNormal = vec3(pNormal.x, pNormal.z, pNormal.y);
	float waterAttenuationValue = clamp( waterMapValue.r * _WaterAttenuation, 0.0, 1.0);

	//Reflectivity
	vec3 refl = reflect( -normViewDir, pNormal);
	vec3 reflectCol = textureCube( _Cube , refl ).rgb;

	outColor.rgb *= CombineEffectsWithLighting(
								waterMapValue.a,
								reflectCol,
								pNormal,
								normViewDir,
								waterAttenuationValue
								);
	

    outColor.a = waterMapValue.b;
	outColor.a *= _Opaqueness;

	gl_FragColor = outColor;

}