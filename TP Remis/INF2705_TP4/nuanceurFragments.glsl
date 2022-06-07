#version 410

uniform sampler2D leLutin;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

void main( void ){
    FragColor = AttribsIn.couleur;

    if(texnumero!=0){
        if (texture(leLutin,AttribsIn.texCoord).a < 0.1 ) 
            discard;
        FragColor = mix (FragColor, texture(leLutin, AttribsIn.texCoord), 0.6);
    }
}
