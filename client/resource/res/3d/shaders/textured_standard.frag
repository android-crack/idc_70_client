#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

///////////////////////////////////////////////////////////
// Uniforms

uniform vec4 u_mainColor;
uniform sampler2D u_diffuseTexture;


///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;


void main()
{ 
    gl_FragColor = texture2D(u_diffuseTexture, v_texCoord)*u_mainColor;
}
