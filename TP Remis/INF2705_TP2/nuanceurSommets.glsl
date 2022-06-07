#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

uniform vec4 planRayonsX; // équation du plan de RayonsX
uniform int attenuation; // on veut une atténuation en profondeur 
uniform int estSelectionne; //si on selectionne le poisson

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;

out Attribs {
    vec4 couleur;
    float clipDistanceRayonsX;
} AttribsOut;

void main( void )
{
    // transformation standard du sommet
    gl_Position = matrProj * matrVisu * matrModel * Vertex;
    
    vec4 pos = matrModel * Vertex;
    AttribsOut.clipDistanceRayonsX = dot(planRayonsX, pos);
    
    // couleur du sommet
    AttribsOut.couleur = Color;


    // atténuer selon la profondeur
    if ( attenuation == 1 && estSelectionne==0)
    {
        const float debAttenuation = -12.0;
        const float finAttenuation = +5.0;
        const vec4 coulAttenuation = vec4( 0.2, 0.15, 0.1, 1.0 );


        if(Color[3] > 0.4){
			// le poisson est un cylindre centré dans l'axe des z de rayon 1 entre (0,0,0) et (0,0,1). Donc le z varie entre 0 et 1.
			float z = smoothstep(0,1,Vertex.z); //creation d'une variable pour faire attenuation
			vec4 cyan = vec4(0.0,1.0,1.0,1.0);
			
			AttribsOut.couleur = mix(Color,cyan,z) ; // interpoler la nouvelle couleur sur chaque sommet
			
		}
        // Mettre un test bidon afin que l'optimisation du compilateur n'élimine l'attribut "planRayonsX".
        // Vous ENLEVEREZ ce test inutile!
        //if ( planRayonsX.x < -10000.0 ) AttribsOut.couleur.r += 0.001;

        float z = smoothstep(finAttenuation, debAttenuation,pos.z);
        AttribsOut.couleur = mix(AttribsOut.couleur,coulAttenuation,z) ;
    }
}
