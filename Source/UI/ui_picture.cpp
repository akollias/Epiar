/**\file			ui_picture.cpp
 * \author			Matt Zweig
 * \date			Created: Tuesday, November 2, 2009
 * \date			Modified: Friday, November 14, 2009
 * \brief			Widget for displaying Images
 * \details
 */

#include "includes.h"
#include "Graphics/video.h"
#include "Graphics/image.h"
#include "UI/ui.h"
#include "UI/ui_picture.h"
#include "Utilities/log.h"

/**\class Picture
 * \brief UI picture. */

void Picture::Default( int x, int y, int w, int h ){
	this->x=x;
	this->y=y;

	this->w=w;
	this->h=h;
	this->name="";
	rotation=0.;
	bitmap = NULL;

	color = Color::Get(0,0,0);
	alpha = 0.0f;
}

Picture::Picture( int x, int y, int w, int h, Image* pic ){
	Default(x,y,w,h);
	bitmap = pic;
}

Picture::Picture( int x, int y, int w, int h, string filename ){
	Default(x,y,w,h);
	bitmap = Image::Get(filename);
}

void Picture::Rotate(double angle){
	rotation=angle;
}

void Picture::Draw( int relx, int rely ){
	// DEBUG lines to see the difference between the Picture and the Image.
	Video* vid = Video::Instance();
	// The Picture size
	vid->DrawRect( GetX()+relx, GetY()+rely,
					w,h,
					color.r,color.g,color.b,alpha );
	/*
	// The Image
	if(bitmap!=NULL)
	vid->DrawRect( GetX()+relx+w/2 - bitmap->GetWidth()/2, GetY()+rely+h/2 - bitmap->GetHeight()/2,
					bitmap->GetWidth(), bitmap->GetHeight(),
					1.0,1.0,1.0,0.1 );
	*/
	if(bitmap!=NULL)
		bitmap->DrawFit( this->x+relx, this->y+rely, w, h, static_cast<float>(rotation));
}

void Picture::Set( Image *img ){
	// Potential Memory Leak
	// If the previous bitmap was created from new,
	// then that image is now lost.
	// We can't delete it though, since it could be shared (eg, Ship Model).
	bitmap = img;
}

void Picture::Set( string filename ){
	// Potential Memory Leak
	// If the previous bitmap was created from new,
	// then that image is now lost
	bitmap = Image::Get(filename);
}

void Picture::SetColor( float r, float g, float b, float a) {
	color = Color::Get(r,g,b);
	alpha = a;
}
