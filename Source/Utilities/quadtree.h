/*
 * Filename      : quadtree.cpp
 * Author(s)     : Matt Zweig (thezweig@gmail.com)
 * Date Created  : Tuesday, November 24 2009
 * Last Modified : Tuesday, November 24 2009
 * Purpose       : 
 * Notes         :
 */

#include "includes.h"
#include "Sprites/sprite.h"

enum QuadPosition{ UPPER_LEFT, UPPER_RIGHT,
                   LOWER_LEFT, LOWER_RIGHT };

class QuadTree {
	public:
		QuadTree(Coordinate center, int radius,unsigned int maxobjects);
		~QuadTree();
		void Build(list<Sprite*> *sprites);

		unsigned int Count();
		bool Contains(Coordinate point);

		void Insert(Sprite* obj);
		bool Delete(Sprite* obj);

		list<Sprite*> *GetSprites();
		//list<Sprite*> GetObjects(Coordinate point, int radius);

		void Update();
		void Draw();

	private:
		QuadPosition SubTreeThatContains(Coordinate point);
		void CreateSubTree(QuadPosition pos);
		void InsertSubTree(Sprite* obj);

		void ReBallance();

		QuadTree* subtrees[4];
		list<Sprite*> *objects;
		Coordinate center;
		int radius;
		unsigned int maxobjects;
		bool isLeaf;
};

