#ifndef __AQUARIUM_H__
#define __AQUARIUM_H__

#include <vector>
#include <iterator>

//
// l'aquarium
//
class Aquarium
{
	static FormeCube *cubeFil;
	static FormeQuad *quad;
public:
	Aquarium()
		: locplanRayonsX(-1), locattenuation(-1), estSelectionne(-1)
	{
		// les hauteurs variées des poissons
		float hauteur[] = { -4.0, 9.0, -7.0, -8.0, 1.0, 5.0, -3.0, 8.0, 7.0, -1.0, -9.0, 6.0, 2.0, -6.0, 4.0, 3.0, -2.0, -5.0 };

		// créer un aquarium graphique
		glUseProgram(prog);
		initialiserGraphique();

		// initialiser la génération de valeurs aléatoires pour la création de poissons
		srand(time(NULL));

		// remplir l'aquarium
		for (unsigned int i = 0; i < sizeof(hauteur) / sizeof(hauteur[0]); ++i)
		{
			// donner distance aléatoire
			float dist = glm::mix(0.1*Etat::bDim.x, 0.7*Etat::bDim.x, rand() / ((double)RAND_MAX));
			// donner un angle aléatoire en degrés
			float angle = glm::mix(0, 360, rand() / ((double)RAND_MAX));
			// donner vitesse aléatoire de rotation
			float vit = glm::mix(-8.0, 8.0, rand() / ((double)RAND_MAX));
			vit += 4.0 * glm::sign(vit); // ajouter ou soustraire 4.0 selon le signe de vx afin d'avoir : 4.0 <= abs(vx) <= 8.0
			// donner taille aléatoire
			float taille = glm::mix(0.3, 0.6, rand() / ((double)RAND_MAX));

			// assigner une couleur de sélection
			// partie 2: modifs ici ...
			// créer un nouveau poisson avec sa couleur s'il est sélectionné le *10 c'est parce que nous avons
			int nbPoisson = sizeof(hauteur) / sizeof(hauteur[0]);
			int variation = 255/nbPoisson;
			Poisson *p = new Poisson(dist, hauteur[i], angle, vit, taille, double(i*variation)/255.0, double(i)/255.0, double(i)/255.0);


			// ajouter ce poisson dans la liste
			poissons.push_back(p);
		}

		// créer quelques autres formes
		glUseProgram(progBase);
		if (cubeFil == NULL) cubeFil = new FormeCube(2.0, false);
		glUseProgram(prog);
		if (quad == NULL) quad = new FormeQuad(1.0, true);
	}
	~Aquarium()
	{
		conclureGraphique();
		// vider l'aquarium
		while (!poissons.empty()) poissons.pop_back();
	}
	void initialiserGraphique()
	{
		GLint prog = 0; glGetIntegerv(GL_CURRENT_PROGRAM, &prog);
		if (prog <= 0)
		{
			std::cerr << "Pas de programme actif!" << std::endl;
			locVertex = locColor = -1;
			return;
		}
		if ((locVertex = glGetAttribLocation(prog, "Vertex")) == -1) std::cerr << "!!! pas trouvé la \"Location\" de Vertex" << std::endl;
		if ((locColor = glGetAttribLocation(prog, "Color")) == -1) std::cerr << "!!! pas trouvé la \"Location\" de Color" << std::endl;
		if ((locplanRayonsX = glGetUniformLocation(prog, "planRayonsX")) == -1) std::cerr << "!!! pas trouvé la \"Location\" de planRayonsX" << std::endl;
		if ((locattenuation = glGetUniformLocation(prog, "attenuation")) == -1) std::cerr << "!!! pas trouvé la \"Location\" de attenuation" << std::endl;
        if ((estSelectionne = glGetUniformLocation(prog, "estSelectionne")) == -1) std::cerr << "!!! pas trouvé la \"Location\" de enSelection" << std::endl;

    }
	void conclureGraphique()
	{
		delete cubeFil;
		delete quad;
	}

	void afficherParoisXpos()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(2 * Etat::bDim.x, 2 * Etat::bDim.y, 2 * Etat::bDim.z);
			matrModel.Translate(0.5, 0.0, 0.0);
			matrModel.Rotate(-90.0, 0.0, 1.0, 0.0);
			glUniformMatrix4fv(locmatrModel, 1, GL_FALSE, matrModel);
			quad->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherParoisXneg()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(2 * Etat::bDim.x, 2 * Etat::bDim.y, 2 * Etat::bDim.z);
			matrModel.Translate(-0.5, 0.0, 0.0);
			matrModel.Rotate(90.0, 0.0, 1.0, 0.0);
			glUniformMatrix4fv(locmatrModel, 1, GL_FALSE, matrModel);
			quad->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherParoisYpos()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(2 * Etat::bDim.x, 2 * Etat::bDim.y, 2 * Etat::bDim.z);
			matrModel.Translate(0.0, 0.5, 0.0);
			matrModel.Rotate(90.0, 1.0, 0.0, 0.0);
			glUniformMatrix4fv(locmatrModel, 1, GL_FALSE, matrModel);
			quad->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherParoisYneg()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(2 * Etat::bDim.x, 2 * Etat::bDim.y, 2 * Etat::bDim.z);
			matrModel.Translate(0.0, -0.5, 0.0);
			matrModel.Rotate(-90.0, 1.0, 0.0, 0.0);
			glUniformMatrix4fv(locmatrModel, 1, GL_FALSE, matrModel);
			quad->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherSolZneg()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(2 * Etat::bDim.x, 2 * Etat::bDim.y, 2 * Etat::bDim.z);
			matrModel.Translate(0.0, 0.0, -0.5);
			glUniformMatrix4fv(locmatrModel, 1, GL_FALSE, matrModel);
			quad->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherCoins()
	{
		matrModel.PushMatrix(); {
			matrModel.Scale(Etat::bDim.x, Etat::bDim.y, Etat::bDim.z);
			glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
			cubeFil->afficher();
		}matrModel.PopMatrix(); glUniformMatrix4fv(locmatrModelBase, 1, GL_FALSE, matrModel);
	}
	void afficherParois()
	{
		// tracer les coins de l'aquarium
		glUseProgram(progBase);
		glVertexAttrib3f(locColorBase, 1.0, 1.0, 1.0); // blanc
		afficherCoins();

		// tracer les parois de verre de l'aquarium
		glUseProgram(prog);
		glEnable(GL_BLEND);
		glEnable(GL_CULL_FACE); glCullFace(GL_BACK); // ne pas afficher les faces arrière

		glVertexAttrib4f(locColor, 0.5, 0.2, 0.2, 0.4); // rougeâtre
		afficherParoisXpos(); // paroi en +X
		glVertexAttrib4f(locColor, 0.2, 0.5, 0.2, 0.4); // verdâtre
		afficherParoisYpos(); // paroi en +Y
		glVertexAttrib4f(locColor, 0.2, 0.2, 0.5, 0.4); // bleuté
		afficherParoisXneg(); // paroi en -X
		glVertexAttrib4f(locColor, 0.5, 0.5, 0.2, 0.4); // jauneâtre
		afficherParoisYneg(); // paroi en -Y

		glDisable(GL_CULL_FACE);
		glDisable(GL_BLEND);

		// tracer le sol opaque
		glVertexAttrib3f(locColor, 0.5, 0.5, 0.5); // gris
		afficherSolZneg(); // sol en -Z
	}

	void afficherTousLesPoissons()
	{
		glVertexAttrib4f(locColor, 1.0, 1.0, 1.0, 1.0);

		for (std::vector<Poisson*>::iterator it = poissons.begin(); it != poissons.end(); it++)
		{
			(*it)->afficher();
		}
	}

	 // afficher le contenu de l'aquarium
    void afficherContenu( GLenum ordre = GL_CCW )
    {
        // afficher les poissons en fil de fer (squelette)
		//Lorsque les poissons ne sont pas sélectionné on les affiche en fil de fer en utilisant le plan de coupe donné en X
        if(!Etat::enSelection){ 
            glFrontFace(ordre);
            glEnable(GL_CLIP_PLANE0);   
            glm::vec4 planRayonsX = Etat::planRayonsX;
            glUniform4fv(locplanRayonsX, 1, glm::value_ptr(planRayonsX));
        
            afficherTousLesPoissons();
            glUniform4fv(locplanRayonsX, 1, glm::value_ptr(-planRayonsX));
            
            glPolygonMode( GL_FRONT_AND_BACK, GL_LINE);
            afficherTousLesPoissons();
            glPolygonMode( GL_FRONT_AND_BACK, GL_FILL);
            glDisable(GL_CLIP_PLANE0);
        }
    }

    // afficher l'aquarium
    void afficher()
    {
        // tracer l'aquarium avec le programme de nuanceur de ce TP
        glUseProgram( prog );
        glUniformMatrix4fv( locmatrProj, 1, GL_FALSE, matrProj );
        glUniformMatrix4fv( locmatrVisu, 1, GL_FALSE, matrVisu );
        glUniformMatrix4fv( locmatrModel, 1, GL_FALSE, matrModel );
        glUniform1i( locattenuation, Etat::attenuation ); //Pour permettre de savoir si on est en mode attenuation
        glUniform1i(estSelectionne, Etat::enSelection); // Pour permettre savoir si on est en mode de selection de poisson
        glEnable( GL_CULL_FACE ); glCullFace( GL_BACK ); // ne pas afficher les faces arrière

		//Affichage des poissons réfléchi selon l'axe
        glEnable(GL_STENCIL_TEST);
		// paroi en +Y
		glStencilFunc(GL_NEVER, 1, 1);
		glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
        
		afficherParoisYpos();

		glStencilFunc(GL_EQUAL, 1, 1);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		matrModel.PushMatrix(); {
			matrModel.Translate(0.0, 2 * Etat::bDim.y, 0.0);
			matrModel.Scale(1.0, -1.0, 1.0);
			afficherContenu();
			matrModel.Translate(0.0, -2 * Etat::bDim.y, 0.0);
		} matrModel.PopMatrix();

        // paroi en +X
        glStencilFunc(GL_NEVER, 2, 2);
		glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
        afficherParoisXpos(); 

		glStencilFunc(GL_EQUAL, 2, 2);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		matrModel.PushMatrix(); {
			matrModel.Translate(2 * Etat::bDim.x, 0.0, 0.0);
			matrModel.Scale(-1.0, 1.0, 1.0);
			afficherContenu();
			matrModel.Translate(-2 * Etat::bDim.x, 0.0, 0.0);
		}matrModel.PopMatrix();
       
        // paroi en -Y
        glStencilFunc(GL_NEVER, 4, 4);
		glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
        afficherParoisYneg(); 
    
		glStencilFunc(GL_EQUAL, 4, 4);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		matrModel.PushMatrix(); {
			matrModel.Translate(0.0, -2 * Etat::bDim.y, 0.0);
			matrModel.Scale(1.0, 1.0, 1.0);
			afficherContenu();
			matrModel.Translate(0.0, 2 * Etat::bDim.y, 0.0);
		}matrModel.PopMatrix();
        
        // paroi en -X
        glStencilFunc(GL_NEVER, 8, 8);
		glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
        afficherParoisXneg();

		glStencilFunc(GL_EQUAL, 8, 8);
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
		matrModel.PushMatrix(); {

			matrModel.Translate(-2 * Etat::bDim.x, 0.0, 0.0);
			matrModel.Scale(1.0, 1.0, 1.0);
			afficherContenu();
			matrModel.Translate(2 * Etat::bDim.x, 0.0, 0.0);
		}matrModel.PopMatrix();

        glDisable( GL_STENCIL_TEST );
        glDisable( GL_CULL_FACE );

        // afficher les poissons
        afficherContenu( );

        // afficher les parois de l'aquarium
        afficherParois( );
    }
	// sélectionner un poisson
	void selectionnerPoisson(){
		glFinish();
		
		glVertexAttrib4f(locColor, 1.0, 1.0, 1.0, 1.0);
		
		for (std::vector<Poisson*>::iterator it = poissons.begin(); it != poissons.end(); it++){
			(*it)->afficher(); //pour afficher poisson en appliquant les couleurs attribuees
		}		
		glReadBuffer( GL_BACK );

		GLubyte couleur[3];
		GLint cloture[4]; glGetIntegerv( GL_VIEWPORT, cloture );
		GLint posX = Etat::sourisPosPrec.x, posY = cloture[3]-Etat::sourisPosPrec.y;
		glReadPixels( posX,  posY, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, couleur ); // couleur entre 0 et 255
		
		int idRouge = couleur[0]; // taux de rouge du pixel
		for (std::vector<Poisson*>::iterator it = poissons.begin(); it != poissons.end(); it++){
			if(idRouge <=(*it)->getCoulRouge()){
				(*it)->setEstSelectionne();
				break;
			}
		}	
	}

	void calculerPhysique()
	{
		if (Etat::enmouvement)
		{
			// modifier les déplacements automatiques
			static int sensRayons = +1;
			// la distance de RayonsX
			if (Etat::planRayonsX.w <= -3.0) sensRayons = +1.0;
			else if (Etat::planRayonsX.w >= 3.0) sensRayons = -1.0;
			Etat::planRayonsX.w += 0.7 * Etat::dt * sensRayons;

			if (getenv("DEMO") != NULL)
			{
				// faire varier la taille de la boite automatiquement pour la démo
				static int sensX = 1;
				Etat::bDim.x += sensX * 0.1 * Etat::dt;
				if (Etat::bDim.x < 8.0) sensX = +1;
				else if (Etat::bDim.x > 12.0) sensX = -1;

				static int sensY = -1;
				Etat::bDim.y += sensY * 0.07 * Etat::dt;
				if (Etat::bDim.y < 8.0) sensY = +1;
				else if (Etat::bDim.y > 12.0) sensY = -1;
			}

			for (std::vector<Poisson*>::iterator it = poissons.begin(); it != poissons.end(); it++)
			{
				(*it)->avancerPhysique();
			}
		}
	}

	GLint locplanRayonsX;
	GLint locattenuation;
    GLint estSelectionne;

	// la liste des poissons
	std::vector<Poisson*> poissons;
};

FormeCube* Aquarium::cubeFil = NULL;
FormeQuad* Aquarium::quad = NULL;

#endif
