/*
 * Filename      : image2.h
 * Author(s)     : Chris Thielen (chris@epiar.net)
 * Date Created  : Saturday, January 31, 2009
 * Purpose       : Image loading and display
 * Notes         : You don't have to worry about OpenGL's power of 2 image dimension requirements.
 *                 This class will scale for you while still displaying correctly.
 *                 When editing this class, there are a number of curious variables and conventions to
 *                 pay attention to. The real width/height of the image (rw, rh) is rarely used - it is
 *                 the true width and height of the image according to OpenGL. However, as we often expand
 *                 images whose dimensions weren't a power of two, but must be for proper OpenGL texture
 *                 size requirements, we may internally expand the dimensions of the image (thus the rw,rh grow)
 *                 but the w/h is still effectively (at least as far as we care on the outside) whatever non-
 *                 power of two dimensions, and these effective, "fake" dimensions are called it's _virtual_
 *                 dimensions, or virtual width/height, stored in w, h.
 */

#ifndef __H_IMAGE2__
#define __H_IMAGE2__

#include "includes.h"

class Image2 {
	public:
		// Create instance by loading image from file
		Image2( string filename );

		// Load image from file
		bool Load( string filename );
		// Load image from buffer
		bool Load( unsigned char *buf, int bufSize );

		// Get information about image dimensions (always the virtual/effective size)
		int GetWidth( void ) { return w; };
		int GetHeight( void ) { return h; };
		int GetHalfWidth( void ) { return w / 2; };
		int GetHalfHeight( void ) { return h / 2; };

		// Draw the image
		void Draw( int x, int y, float angle = 0. );
		// Draw the image centered on (x,y)
		void DrawCentered( int x, int y, float angle = 0. );

	private:
		// Expands surface 's' to width/height of w/h, keeping the original image in the upper-left
		SDL_Surface *ExpandCanvas( SDL_Surface *s, int w, int h );

		int w, h; // virtual w/h (effective, same as original file)
		int rw, rh; // real w/h, size of expanded canvas (image) should expansion be needed
		            //   to meet power of two requirements
		GLuint image; // OpenGL pointer to texture
};

#endif // __H_IMAGE2__
