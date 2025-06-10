package hxd;

/**
 * @param loops how many times the timer should go off. -1 means it will keep looping forever, use with caution.
 * @param paused pause or unpause a timer, a paused timer does not process til its unpaused
 * @param endEvent an optional event that kicks off when a timer is finished
 * @param keep optionally choose to keep the timer between scenes
 * @param autostart optionally set if the timer should start on its own or not, overrides paused if false
 * @param identifier an optional identifier for tracking a specific timer by string name
 * @param delay an optional delay dictating how long before a timer actually starts
 * @param ignoreTimeScale currently there is no time scale implemented but that's on the roadmap
 * 
*/
typedef TimerOptions = {
	var ?endEvent: Void->Void;
	var ?loops:Int; //copied from flxtimer, where one is one loop and 0 means infinite loops
	var ?paused:Bool;
	var ?keep:Bool; //keeps the timer from being destroyed during scene switches, use if needed.
	var ?autostart:Bool; //if it should start on its own or not
	var ?identifier: String; //the timer's unique identifier name
	
	var ?delay: Float; //unimplemented //delay till timer start
	var ?ignoreTimeScale: Bool; //time scale is not implemented in this engine to my knowledge

	var ?duration: Float; //duration override, to be used after a timer has already started
	var ?mainEvent: Void->Bool; //main event override, to be used after a timer has already started

}


/**
 * @param duration the duration of the timer
 * @param event the main function that acts every end of loop.
 * @param loops optionally set how many times the timer should loop. -1 means it will keep looping forever, use with caution.
 * @param paused optionally pause or unpause a timer, a paused timer does not process til its unpaused
 * @param endEvent an optional event that kicks off when a timer is completed.
 * @param keep optionally choose to keep the timer between scenes. //untested
 * @param identifier an optional identifier for tracking a specific timer by string name
 * @param delay an optional delay dictating how long before a timer actually starts
 * @param ignoreTimeScale currently there is no time scale implemented but that's on the roadmap
 * @param durationOverride an override for duration that will be changed to at the end of a loop
*/
typedef TimeEvent = {
	var duration: Float;
	var event: Void->Void;

	var ?endEvent:Void->Void;
	var ?loops:Int;
	var ?paused:Bool;
	var ?keep:Bool;
	var ?identifier:String;
	var ?delay:Float;
	
	var ?ignoreTimeScale:Bool; //time scale is not implemented in this engine to my knowledge
	var ?durationOverride:Float; //i'll be honest, this is only here because i needed a way to keep a static duration variable for loops
}


/**
 * TimerManager is a container for all things countdown related
 * 
 * Call this from main and use addTimer in a way that suits your needs.
 * 
 * It is designed to be flexible to suit as many situations as possible, while keeping performance in mind.
 */
class TimerManager {
	/**
	 * The list of all the timers, not to be accessed directly.
	 */
	var eventList : Array<TimeEvent>;

	public function new() {
		eventList = []; //kind of pointless, but the class needs a constructor, makes me consider making this fully global, but i still want to keep it as a component
	}

	/**
	 * Checks if the event list is empty or not, if it is return true, if it isn't return false.
	 */
	public inline function isEmpty() {
		return eventList.length > 0;
	}

	/**
	 * Check if a specific timer still exists 
	 */
	public function find(identifier:String):TimeEvent {
		for( e in eventList ){
			if (e.identifier == identifier){
				return e;
			}
		}
		return null;
	}

	/**
	 * Deletes all timers by clearing the event array, use with caution.
	 */
	public function clear() {
		eventList = [];
	}

	/**
	 * Check if a specific event still exists and remove it.
	 */
	public function removeTimer( identifier:String ) {
		for( e in eventList ){
			if (e.identifier == identifier){
				eventList.remove(e);
			}
		}
	}

	/**
	 * Removes all timers, except for timers that are assigned to be kept between scenes, they have to be removed manually, otherwise use `clear`
	 */
	public function removeAllTimers(){
		for( e in eventList ){
			if (e.keep == false){
				eventList.remove(e);
			}
		}
	}

	/**
	 * Pause an existing timer
	 */
	public function pauseTimer(identifier:String){
		for (e in eventList){
			if (e.identifier == identifier){
				e.paused = true;
			}
		}
	}

	/**
	 * Pauses ALL existing timers
	*/
	public function pauseAllTimers(){
		for (e in eventList){
			e.paused = true;
		}
	}

	/**
	 * Resume a paused timer
	 */
	public function resumeTimer(identifier:String){
		for (e in eventList){
			if (e.identifier == identifier){
				e.paused = false;
			}
		}
	}

	/**
	 * Resumes ALL paused timers 
	 */
	public function resumeAllTimers(){
		for (e in eventList){
			e.paused = false;
		}
	}

	/**
	 * Manually add an externally created timer into the event list, use with caution.
	 * 
	 * to create a brand new timer see `addTimer`
	 */
	public function addExisting(timer:TimeEvent){
		if (!eventList.contains(timer) ){
			eventList.push(timer);
		}
	};

	/**
	 * Creates a new timer
	 * 
	 * example of usage:
	 * ```
	 * timer.addTimer({
	 * 	duration: 0.1,
	 *	event: ()->{
	 *		trace("event");
	 *	}
	 * });
	 * ```
	 */
	public function addTimer(timer:TimeEvent) {
		//variable initialization and to make up for ignored options
		timer.delay = timer.delay ?? 0;
		timer.duration = timer.duration ?? 1;
		timer.durationOverride = timer.duration ?? 1;
		timer.event = timer.event ?? ()->{};
		timer.endEvent = timer.endEvent ?? ()->{};
		timer.identifier = timer.identifier ?? Std.string(Std.random(999));
		timer.ignoreTimeScale = timer.ignoreTimeScale ?? false; //doesn't do anything yet
		timer.keep = timer.keep ?? false;
		timer.loops = timer.loops ?? 1;
		timer.paused = timer.paused ?? false;
		eventList.push(timer);
		return timer;
	}

	public function update() {
		var i = 0;
		//not sure a while loop is the right choice here, but sure why not.
		while (i < eventList.length) {
			var timer = eventList[i];

			if(timer.loops == 0) { //if the loop count reaches 0, remove the timer
				eventList.remove(timer);
				timer.endEvent();
			}
			else{
				if (!timer.paused){//unpausing logic
					if (timer.delay > 0){
						timer.delay -= hxd.Timer.dt;
					}
					else{

						timer.duration -= hxd.Timer.dt;
						if (timer.duration < 0){
							timer.event();
							--timer.loops;
							timer.duration = timer.durationOverride;
						}
					}
				}
				++i; //increment and repeat
			}
		}
	}

}