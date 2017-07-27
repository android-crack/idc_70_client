
#if defined(SKINNING)
attribute vec4 a_blendWeights;
attribute vec4 a_blendIndices;
uniform vec4 u_matrixPalette[SKINNING_JOINT_COUNT * 3];
#include "skinning.vert"
#else
#include "skinning-none.vert" 
#endif

