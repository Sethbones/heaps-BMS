package hxd;

//i don't know what this does
//my original thought would've been a timer, but its for functions?
//this was added in 2015 and, while it is maintained, has no documentation, nice.

//okay so riddle me this, whats the point of it having an array despite timers basically being designed for single use occasions
//what is the point of this file
//why doesn't it have documentation
//why does this engine just not make any sense sometimes?.
//why am i yapping, i had to option to choose a normal engine and i chose pain
//also this thing is not self containted and requires manual operation
//i need to find a way so that it auto updates instead of requiring manual insertion of the update function 
//now that i'm thinking about it, this works better as a component for the engine, rather than an object attached to another object

/**
 * W.I.P
 * 
 * currently requires manually attaching to an object's update function.
 * considering turning it into an object, that would make handling things easier later down the line.
 * 
 * WaitTimer is a container for all things countdown related, attach this to your object of choice, and use events in a way that suits your needs.
 * 
 * it is designed to be flexible to suit as many situations as possible
 */
class WaitTimer {

	//calls dt despite it not being referenced anywhere
	//float -> bool?, guess that means a function that takes a float and outputs a bool?
	//yes that was correct
	var updateList : Array<Float -> Bool> ;

	public function new() {
		updateList = [];
	}

	/**
	 * checks of the event list is empty or not, if it is return true, if it isn't return false.
	 */
	public inline function isEmpty() {
		return updateList.length > 0;
	}

	/**
	 * check if a specific event still exists 
	 */
	public function find(callb : Float->Bool) {
		for( e in updateList )
			if( Reflect.compareMethods(e, callb) ) {
				return true;
			}
		return false;
	}

	/**
	 * clears all events, use with caution.
	 */
	public function clear() {
		updateList = [];
	}

	//i don't get what this does, as it just pushes the callback to the list with seemingly no way to control the timer it takes
	//this asks for a float, but what it actually wants is deltatime or timemod
	public function manualCreate( callb : Float -> Bool ) {
		updateList.push(callb);
	}

	/**
	 * check if a specific event still exists and if it is, remove it.
	 */
	public function remove( callb : Float->Bool ) {
		for( e in updateList )
			if( Reflect.compareMethods(e, callb) ) {
				updateList.remove(e);
				return true;
			}
		return false;
	}

	/**
	 * currently unfinished
	 * 
	 * pauses an existing event
	 */
	public function pauseEvent(){

	}

	/**
	 * currently unfinished
	 * 
	 * resets an existing event
	 */
	public function resetEvent(){

	}

	/**
	 * Creates a new event
	 * 
	 * example of usage:
	 * ```
	 * event.wait(6. function(){
	 *		trace("event is done");
	 * });
	 * ```
	 */
	public function createEvent( time : Float, callb : Void -> Void, paused:Bool = false, autostart:Bool = true) {
		function tmp(dt:Float) {
			time -= dt;
			if( time < 0 ) {
				callb();
				return true;
			}
			return false;
		}
		updateList.push(tmp);
	}

	public function update(dt:Float) {
		var i = 0;
		//not sure a while loop is the right choice here, but sure why not.
		while (i < updateList.length) {
			var f = updateList[i];
			//if the event returns true(i.e if its done)
			if(f(dt))
				updateList.remove(f);
			else
				//this threw me for a loop for a bit, didn't there was a difference between i++ and ++i
				++i; //increment and repeat
		}
	}
}