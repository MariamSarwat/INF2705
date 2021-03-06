#version 410
layout(vertices = 4) out;

uniform float TessLevelInner;
uniform float TessLevelOuter;
in Attribs {
    vec3 L[3];
    vec3 normale, obsVec;
    vec4 couleur;
    vec2 TexCoord;
} AttribsIn[];

out Attribs {
    vec3 L[3];
    vec3 normale, obsVec;
    vec4 couleur;
    vec2 TexCoord;
} AttribsOut[];

void main(){
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

   if (gl_InvocationID == 0){
      gl_TessLevelInner[0] = TessLevelInner;
      gl_TessLevelInner[1] = TessLevelInner;
      gl_TessLevelOuter[0] = TessLevelOuter;
      gl_TessLevelOuter[1] = TessLevelOuter;
      gl_TessLevelOuter[2] = TessLevelOuter;
      gl_TessLevelOuter[3] = TessLevelOuter;
    }

    AttribsOut[gl_InvocationID].normale = AttribsIn[gl_InvocationID].normale;
    AttribsOut[gl_InvocationID].obsVec = AttribsIn[gl_InvocationID].obsVec;
    AttribsOut[gl_InvocationID].couleur = AttribsIn[gl_InvocationID].couleur;
    AttribsOut[gl_InvocationID].TexCoord = AttribsIn[gl_InvocationID].TexCoord;

    AttribsOut[gl_InvocationID].L[0] = AttribsIn[gl_InvocationID].L[0];
    AttribsOut[gl_InvocationID].L[1] = AttribsIn[gl_InvocationID].L[1];
    AttribsOut[gl_InvocationID].L[2] = AttribsIn[gl_InvocationID].L[2];
}