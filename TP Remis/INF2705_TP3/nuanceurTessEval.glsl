#version 410
layout(quads) in ;

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
} AttribsOut;

vec2 interpole1( vec2 v0, vec2 v1, vec2 v2, vec2 v3 ){
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec2 v01 = mix( v0, v1, gl_TessCoord.x );
    vec2 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}
vec3 interpole2( vec3 v0, vec3 v1, vec3 v2, vec3 v3 ){
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec3 v01 = mix( v0, v1, gl_TessCoord.x );
    vec3 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}
vec4 interpole3( vec4 v0, vec4 v1, vec4 v2, vec4 v3 ){
    // mix( x, y, f ) = x * (1-f) + y * f.
    vec4 v01 = mix( v0, v1, gl_TessCoord.x );
    vec4 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

void main(){
    gl_Position = interpole3( gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[3].gl_Position, gl_in[2].gl_Position );

    AttribsOut.couleur = interpole3( AttribsIn[1].couleur, AttribsIn[0].couleur, AttribsIn[3].couleur, AttribsIn[2].couleur );
    AttribsOut.L[0] = interpole2( AttribsIn[0].L[0], AttribsIn[1].L[0], AttribsIn[3].L[0], AttribsIn[2].L[0] );
    AttribsOut.L[1] = interpole2( AttribsIn[0].L[1], AttribsIn[1].L[1], AttribsIn[3].L[1], AttribsIn[2].L[1] );
    AttribsOut.L[2] = interpole2( AttribsIn[0].L[2], AttribsIn[1].L[2], AttribsIn[3].L[2], AttribsIn[2].L[2] );

    AttribsOut.normale = interpole2( AttribsIn[0].normale, AttribsIn[1].normale, AttribsIn[3].normale, AttribsIn[2].normale );
    AttribsOut.obsVec = interpole2( AttribsIn[0].obsVec, AttribsIn[1].obsVec, AttribsIn[3].obsVec, AttribsIn[2].obsVec );
    AttribsOut.TexCoord = interpole1( AttribsIn[0].TexCoord, AttribsIn[1].TexCoord, AttribsIn[3].TexCoord, AttribsIn[2].TexCoord );
}