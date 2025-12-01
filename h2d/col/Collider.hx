package h2d.col;

//it probably shouldn't extend Object honestly, i should probably try creating a stripped down object that acts similar, but i need to think about it first
//for performance reasons
/**
	A common class for 2D Shapes to hit-test against the mouse or a specific point in space.
**/
class Collider extends Object{

	var debugDraw:h2d.Graphics;
	/**
	 * track all colliders in the scene to compare between them
	 */
	var activeCollisions:Array<Collider>;

	//collider is lacking a lot of basic features like coordinates, which are for some reason done manually by the the shapes themselves
	//why not just cut out the middle man?
	//i know why now
	//why the hell is this an abstract class?
	//it doesn't work, because it means the common interface lacks basic features and so collision can't be identified from outside the seperate shape instance, which makes this class completely fucking useless
	//i mean i understand the vision, but i don't understand the usecase
	//if each do their own thing, then each can have their own optimization
	//however since they do their own thing they do not have a way to communicate between each other through a common class
	//these abstract functions only prove this point further, because it can just be done in each class seperately 


	override function init(){
        #if debug
		//delay the drawing to next frame, for certain colliders to catch up to speed on their variables
		haxe.Timer.delay(collisionDraw, 0); //huh, haxe.Timer is asynchronous, didn't know that, that's convenient 
        //collisionDraw();
        #end
    }


	/**
	 * the main collision check meant to be ran continuously
	 * @param target the collision shape to compare to, each shape has its own method of implementation
	 * @param group Array input is also allowed if you want to compare an array of collisions
	 * @param startEvent runs right when collision just begins to collide
	 * @param overlapEvent runs continuously as long as there is collision
	 * @param exitEvent runs when the collision leaves for milk 
	 * @return Bool returns true if a hit is found, return false otherwise
	*/
	public function collides(?target: Collider, ?group: Array<Collider>, ?notifyEvent: Void->Void, ?overlapEvent: Void->Bool):Bool {
		if (target != null){
            return collision(target);
        }
        else if (group != null){//needs testing, i think it will just return on the first instance of collision instead of returning on each of them
			//shouldn't be an issue, but it is an edge case that needs testing
            for (t in group){
                return collision(t);
            }
        }
		return false;
	};

	/**
	 * the actual collision detection between each of the colliders
	 */
	function collision(target:Collider):Bool {return false;};


	/**
	 * debug draw
	 */
	public function collisionDraw(){
		if (debugDraw == null){
            debugDraw = new h2d.Graphics(this);
        }
        else{//clear/reset it if its already there, to allow updating collision shapes
            debugDraw.clear();//quality
        }
	};

}