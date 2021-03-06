/**\filename		simulation.h
 * \author			Chris Thielen (chris@epiar.net)
 * \date			Created: July 2006
 * \date			Modified: Tuesday, June 23, 2009
 * \brief			Contains the main game loop
 * \details
 */

#ifndef __H_SIMULATION__
#define __H_SIMULATION__

#include "Engine/commodities.h"
#include "Engine/alliances.h"
#include "Engine/engines.h"
#include "Engine/models.h"
#include "Sprites/planets.h"
#include "Engine/weapons.h"
#include "Engine/technologies.h"
#include "Sprites/player.h"
#include "Audio/music.h"
#include "Utilities/camera.h"
#include "Input/input.h"
#include "Engine/console.h"

class Simulation : public XMLFile {
	public:
		Simulation();
		
		bool Load( string filename );
		bool Save();
		bool Run();

		bool HandleInput();

		static void pause();
		static void unpause();
		static bool isPaused() {return paused;}

	private:
		bool Parse( void );

		// Pointers to Singletons
		// TODO: These should all be rewritten to not be singletons
		SpriteManager *sprites;
		Commodities *commodities;
		Planets *planets;
		Engines *engines;
		Models *models;
		Weapons *weapons;
		Alliances *alliances;
		Technologies *technologies;
		Outfits *outfits;
		Players *players;
		Camera *camera;

		// Simulation specific variables
		Song* bgmusic;
		Input inputs;
		Console console;

		float currentFPS;
		static bool paused;
};

#endif // __H_SIMULATION__
