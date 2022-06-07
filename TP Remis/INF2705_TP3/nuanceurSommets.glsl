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

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(location=0) in vec4 Vertex;
layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

out Attribs {
    vec3 L[3];
    vec3 normale, obsVec;
    vec4 couleur;
    vec2 TexCoord;
} AttribsOut;


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

void main( void ){
    vec3 L[3];
    vec3 normale;

    // transformation standard du sommet
    gl_Position = matrProj * matrVisu * matrModel * Vertex;

    vec3 pos = vec3(matrVisu * matrModel * Vertex);
    vec3 N = normalize(matrNormale * Normal);
    vec3 O = normalize(-vec3(matrVisu * matrModel * Vertex).xyz);
    AttribsOut.TexCoord = TexCoord.st;
   
    if(typeIllumination == 0){ //Gouraud
        for(int i = 0; i < 3; i++){
            AttribsOut.L[i] = (((matrVisu * LightSource.position[i]).xyz - pos));
        }
        normale = matrNormale * Normal;
        AttribsOut.couleur = calculerReflexion(AttribsOut.L, normalize(normale), O);
        AttribsOut.normale = N;
    }
    else if(typeIllumination == 1){ //Phong
        for(int i = 0; i < 3; i++){
            AttribsOut.L[i] = (((matrVisu * LightSource.position[i]).xyz - pos));
        }
        
        normale = matrNormale * Normal;
        AttribsOut.normale = normale;
    }
    AttribsOut.obsVec = O;
}
