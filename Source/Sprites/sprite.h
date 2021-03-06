/**\file			sprite.h
 * \author			Chris Thielen (chris@epiar.net)
 * \date			Created: Unknown (2006?)
 * \date			Modified: Saturday, January 5, 2008
 * \brief
 * \details
 */

#ifndef __h_sprite__
#define __h_sprite__

#include "Graphics/image.h"
#include "Graphics/video.h"
#include "Engine/models.h"
#include "Utilities/coordinate.h"

// With the draw order, higher numbers are drawn later (on top)
// By using non-overlapping bits we can bit mask during searches
#define DRAW_ORDER_PLANET              0x0001 ///< Draw order for Planet Sprites
#define DRAW_ORDER_GATE_BOTTOM         0x0002 ///< Draw order for Gate Sprites (Below all Ship Sprites)
#define DRAW_ORDER_WEAPON              0x0004 ///< Draw order for Projectile Sprites
#define DRAW_ORDER_SHIP                0x0008 ///< Draw order for Ship Sprites
#define DRAW_ORDER_PLAYER              0x0010 ///< Draw order for Player Sprites
#define DRAW_ORDER_GATE_TOP            0x0020 ///< Draw order for Gate Sprites (Above all Ship Sprites)
#define DRAW_ORDER_EFFECT              0x0040 ///< Draw order for Effect Sprites (Explosions)
#define DRAW_ORDER_ALL                 0xFFFF ///< Default DRAW_ORDER for searches that filter.

class Sprite {
	public:
		Sprite();
		virtual ~Sprite() {};
		
		Coordinate GetWorldPosition( void ) const;
		void SetWorldPosition( Coordinate coord );
		
		virtual void Update( void );
		virtual void Draw( void );
		
		int GetID( void ) { return id; }

		float GetAngle( void ) const {
			return( angle );
		}
		void SetAngle( float angle ) {
			this->angle = angle;
		}
		Coordinate GetMomentum( void ) const {
			return momentum;
		}
		void SetMomentum( Coordinate momentum ) {
			this->momentum = momentum;
		}
		Coordinate GetAcceleration( void ) const {
			return acceleration;
		}
		void SetImage( Image *image ) {
			assert(image);
			this->image = image;
			this->radarSize = ( image->GetWidth() + image->GetHeight() ) /(2);
		}
		void SetRadarColor( Color col ){
			this->radarColor = col;
		}
		Image *GetImage( void ) const {
			return image;
		}
		int GetRadarSize( void ) { return radarSize; }
		virtual Color GetRadarColor( void ) { return radarColor; }
		virtual int GetDrawOrder( void ) = 0;
		
	private:
		static int sprite_ids; ///< The ID for the next Sprite.

		int id; ///< The unique ID of this Sprite.
		Coordinate worldPosition; ///< The Current position of this Sprite.
		Coordinate momentum; ///< The current Speed and Direction that this Sprite is moving (not pointing).
		Coordinate acceleration; ///< The ammount that the Sprite accelerated during the previous Update.
		Coordinate lastMomentum; ///< The momentum that this Sprite had after the previous Update.
		Image *image; ///< The current Image that this Sprite is using.
		float angle; ///< The current direction that this Sprite is pointing (not moving).
		int radarSize; ///< A Rough appoximation of this Sprite's size.
		Color radarColor; ///< The color of this Sprite.
		
};

bool compareSpritePtrs(Sprite* a, Sprite* b);

/**\brief Creates a binary comparison object that can be passed to stl sort.
 * Sprites will be sorted by distance from the point in ascending order.
 * \relates Sprite
 */
struct compareSpriteDistFromPoint
	: public std::binary_function<Sprite*, Sprite*, bool>
{
	compareSpriteDistFromPoint(const Coordinate& c) : point(c) {} ///< Default Constructor(?)

    /**\brief Compare two sprites by their distance from a Coordinate (c).
     * \details This uses GetMagnitudeSquared to calculate the distance from a
     *          Sprite so that we don't have to run a costly sqrt.
     * \param a A pointer to a Sprite.
     * \param b A pointer to another Sprite.
     * \returns True if Sprite a is closer than Sprite b to point c.
     *
     */
	bool operator() (Sprite* a, Sprite* b) {
		return (point - a->GetWorldPosition()).GetMagnitudeSquared()
		     < (point - b->GetWorldPosition()).GetMagnitudeSquared() ;
	}

	Coordinate point;
};

#endif // __h_sprite__
