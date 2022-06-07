#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
    vec4 ambient[3];
    vec4 diffuse[3];
    vec4 specular[3];
    vec4 position[3];      // dans le repère du monde
} LightSource;

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
    vec4 emission;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
    vec4 ambient;       // couleur ambiante globale
    bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
    // partie 1: illumination
    int typeIllumination;     // 0:Gouraud, 1:Phong
    bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
    bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
    // partie 2: texture
    int numTexCoul;           // numéro de la texture de couleurs appliquée
    int numTexNorm;           // numéro de la texture de normales appliquée
    int afficheTexelFonce;    // un texel foncé doit-il être affiché 0:normalement, 1:mi-coloré, 2:transparent?
};

uniform sampler2D laTextureCoul;
uniform sampler2D laTextureNorm;

/////////////////////////////////////////////////////////////////

in Attribs {
    vec3 L[3];
    vec3 normale, obsVec;
    vec4 couleur;
    vec2 TexCoord;
} AttribsIn;

out vec4 FragColor;

vec4 calculerReflexion( in vec3 L[3], in vec3 N, in vec3 O ) {   
    vec4 couleur = vec4(0.0,0.0,0.0,1.0);
    for(int i = 0; i < 3; i++){
        vec3 L = vec3(normalize(L[i]));
        couleur += FrontMaterial.emission + (FrontMaterial.ambient * LightModel.ambient ) + FrontMaterial.ambient * LightSource.ambient[i] ;
        
        float NdotL = dot(N, L);
        if(NdotL > 0.0){
            couleur += FrontMaterial.diffuse * LightSource.diffuse[i] * NdotL;

            float NdotHV;
            if(utiliseBlinn){
                NdotHV = max(0.0,dot(normalize(L + O),N));
            }
            else{
                NdotHV = max(0.0,dot(reflect(-L,N),O));
            }
            couleur += FrontMaterial.specular * LightSource.specular[i] * pow(NdotHV,FrontMaterial.shininess);
        } 
    }
    return couleur;
}

void main( void )
{
    vec3 N = normalize( AttribsIn.normale ); // vecteur normal
    vec3 O = normalize( AttribsIn.obsVec );  // position de l'observateur
    vec4 couleurTexture = texture(laTextureCoul, AttribsIn.TexCoord);
    vec4 couleurFinale = vec4(0.0, 0.0, 0.0, 0.0);

    if ( numTexNorm != 0 ) { //Partie 4: calcul de la nouvelle normal en fonction du relief choisi
        vec4 couleur = texture(laTextureNorm, AttribsIn.TexCoord);
        vec3 dN = normalize((couleur.rgb - 0.5)*2.0); 
        N = normalize(N + dN);
    }

    if(typeIllumination == 0){ //Gouraud
        couleurFinale = AttribsIn.couleur;
    } 
    else if(typeIllumination == 1){ //Phong
        vec4 couleur = calculerReflexion(AttribsIn.L,N,O);
        couleurFinale = clamp(couleur, 0.0, 1.0);
    }

    if (numTexCoul != 0) { //Partie 2: calcul de la texture avec les couleurs
        if (couleurTexture[0] < 0.5 && couleurTexture[1] < 0.5 && couleurTexture[2] < 0.5) {
            if (afficheTexelFonce == 1) { 
                couleurTexture = vec4(0.5, 0.5, 0.5, 0.5);
            } 
            else if (afficheTexelFonce == 2) {
                discard;
            }
        }
        couleurFinale = couleurFinale * couleurTexture;
    } 
    FragColor = couleurFinale;
}
