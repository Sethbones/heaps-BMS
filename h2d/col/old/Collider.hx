package h2d.col.old;


//abstract class in this basically acts like ECS, its not not a component but its not a component
/**
	A common interface for 2D Shapes to hit-test again the mouse or a specific point in space.
**/
abstract class Collider {
	//collider is lacking a lot of basic features like coordinates, which are for some reason done manually by the the shapes themselves
	//why not just cut out the middle man?
	// public var x : Float;
	// public var y : Float;
	//i know why now
	//why the hell is this an abstract class?
	//i doesn't work, because it means the common interface lacks basic features and so collision can't be identified from outside the seperate shape instance, which makes this class completely fucking useless
	//i mean i understand the vision, but i don't understand the usecase
	//if each do their own thing, then each can have their own optimization
	//however since they do their own thing they do not have a way to communicate between each other through a common class
	//these abstract functions only prove this point further, because it can just be done in each class seperately 

	/**
		Tests if Point `p` is inside the Collider.
	**/
	public abstract function contains( p : Point ) : Bool;
	public abstract function collideCircle( c : Circle ) : Bool;
	public abstract function collideBounds( b : Bounds ) : Bool;

}