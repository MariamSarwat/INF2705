#version 410

layout(points) in;
//layout(points, max_vertices = 1) out;
layout(triangle_strip, max_vertices = 4) out;

uniform int texnumero;
in Attribs {
    vec4 couleur;
    float tempsDeVieRestant;
    float sens; // sens du vol
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

uniform mat4 matrProj;

vec2 adjustTexture(vec2 coins, int i){
    return (i*coins/16 + vec2( 0.5, 0.5 )); 
}

void main() {
    // assigner la position du point
    gl_Position = gl_in[0].gl_Position;

    // assigner la taille des points (en pixels)
    gl_PointSize = gl_in[0].gl_PointSize;

    // assigner la couleur courante
    AttribsOut.couleur = AttribsIn[0].couleur;
    AttribsOut.texCoord = vec2( 0.0, 0.0 );
    
    vec2 coins[4];
    coins[0] = vec2( -0.5,  0.5 );
    coins[1] = vec2( -0.5, -0.5 );
    coins[2] = vec2(  0.5,  0.5 );
    coins[3] = vec2(  0.5, -0.5 );

    for ( int i = 0 ; i < 4 ; ++i ) {
        float fact = gl_in[0].gl_PointSize / 40;

        //On positionne successivement aux quatre coins
        vec2 decalage = coins[i];
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        //On termine la transformation débutée dans le nuanceur de sommets
        gl_Position = matrProj * pos;   

        AttribsOut.couleur = AttribsIn[0].couleur;
        
        if(texnumero == 0){
            //On utilise coins[] pour définir des coordonnées de texture
            AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 ); 
        }
        else if (texnumero == 1){
            mat2 rotation = mat2 (cos(6.0*AttribsIn[0].tempsDeVieRestant), -sin(6.0*AttribsIn[0].tempsDeVieRestant), 
                                sin (6.0*AttribsIn[0].tempsDeVieRestant), cos(6.0*AttribsIn[0].tempsDeVieRestant));
            coins[i] = coins[i] * rotation;

            //On utilise coins[] pour définir des coordonnées de texture
            AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 ); 
        }
        else if (texnumero == 2 ){
            vec2 texCoo = coins[i] + vec2( 0.5, 0.5 );
            texCoo.x *= 1.0 / 16.0;
            int fact = int(mod(18.0 * AttribsIn[0].tempsDeVieRestant, 16));
            texCoo.x += fact / 16.0;
            AttribsOut.texCoord = texCoo;
            if (AttribsIn[0].sens == -1){
                AttribsOut.texCoord.x = - texCoo.x;
            }
        }
        else if (texnumero == 3){
            vec2 texCoo = coins[i] + vec2( 0.5, 0.5 );
            texCoo.x *= 1.0 / 16.0;
            int fact = int(mod(18.0 * AttribsIn[0].tempsDeVieRestant, 16));
            texCoo.x += fact / 16.0;
            AttribsOut.texCoord = texCoo;
        }
        EmitVertex();
    }
}
