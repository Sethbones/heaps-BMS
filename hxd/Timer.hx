package hxd;

/**
	The Time class acts as a global time measurement that can be accessed from various parts of the engine.
	These three values are representation of the same underlying calculus: tmod, dt, fps
	dt - Delta Time
	tmod - Time MODifier, and not terraria mod loader, needs a new name
	fps - Frames Per Second

**/
class Timer {

	/**
	 	the targetFPS for which world phsyics are based on,
		now one thing that's important is that other engines use 1/50FPS for their physics calculations
		for which the only reason i can find for is some deep optmization,
		it being an even fixed value of 0.02 probably removes inconsistency and makes results more stable and easy to predict
		for which i can't verify the why and how, because isn't 1/60 a consistent number too or is that because the number is lost in floating point hell?

		The FPS on which "tmod" have values are based on.
		Can be freely configured if your gameplay runs at a different speed.
		Default : 60
	**/
	public static var wantedFPS = 60.;

	/**
		The maximum amount of time between two frames (in seconds).
		If the time exceed this amount, Timer will consider these lags are to be ignored.
		Default : 0.5
	**/
	public static var maxDeltaTime = 0.5; //this number feels too high, this currently stops delta from outputing if the frame rate dips below 2FPS,
	//and its used to not output whatever the last delta was but to instead do 1/wantedFPS?, that sounds it will cause more problems than it will fix

	/**
		tested different numbers and it doesn't seem to do much other than create more randomness, but i could be wrong

		The smoothing done between frames. A smoothing of 0 gives "real time" values, higher values will smooth
		the results for tmod/dt/fps over frames using the formula  dt = lerp(elapsedTime, dt, smoothFactor)
		Default : 0 on HashLink, 0.95 on other platforms
	**/
	public static var smoothFactor = #if hl 0. #else 0.95 #end;

	/**
		The last timestamp in which update() function was called.
	**/
	public static var lastTimeStamp(default,null) = haxe.Timer.stamp();

	/**
		The amount of time (unsmoothed) that was spent since the last frame.
	**/
	public static var elapsedTime(default,null) = 0.;

	/**
		A frame counter, increases on each call to update()
	**/
	public static var frameCount = 0;

	/**
		The smoothed elapsed time (in seconds).

	**/
	public static var dt : Float = 1 / wantedFPS;

	/**
		The smoothed elapsed time (in seconds).

	**/
	public static var fixedDT(get,null):Float = 1/60;

	/**
		The smoothed frame modifier, based on wantedFPS. Its value is the same as dt/wantedFPS
		Allows to express movements in terms of pixels-per-frame-at-wantedFPS instead of per second.
	**/
	public static var tmod(get,set) : Float;

	static var currentDT : Float = 1 / wantedFPS;

	/**
	 * time accumulator for fixed delta playback
	 */
	static var accumulator:Float = 0;

	/**
		Update the timer calculus on each frame. This is automatically called by hxd.App
	**/
	public static function update() {
		frameCount++; //this is not attached to anything here, but it is used by a lot of things outside of this file

		//this thing, note the outcome is still being evaluated as more research is done, but that's the one for now
		//i spent several months trying to figure out why the delta time is not consistent, going through articles and ass loads of reddit posts
		//the end conclusion of the escapade is that haxe.Timer.stamp is returning the wrong value or at least not the values that are good for delta calculation
		//to put simply haxe.Timer.Stamp returns a float based on Sys.Time(), the problem of which is that floats are not consistent values by the nature of their existence
		//by comparison to something like SDL or GLFW, they use an Int to get the current time being used for delta calculation, Integers are always consistent thus leading to a more consistent result
		//if you want to see this the easiest, use raylib, because raylib has support for a bunch of things
		//so, what do? well the values needed for the calculation are not exposed to haxe at the base level
		//which means i either have to fork haxe, figure out the problem and fix it
		//or
		//ditch hlsdl and go full native sdl with a custom implemenation (what Lime does)
		//or
		//say fuck it and switch game engine
		//or
		//ignore the problem, which may cause other timing related issues in the future if avoided for too long, potentially mitigated with a fixedUpdate loop
		var newTime = haxe.Timer.stamp();
		
		elapsedTime = newTime - lastTimeStamp; //this is the raw delta value
		lastTimeStamp = newTime; //set laststamp back to the current stamp

		if( elapsedTime < maxDeltaTime ) //this in theory should always happen unless your uncapped frame rate is above 2000
			currentDT = Math.lerp(elapsedTime, currentDT, smoothFactor); //this is "interpolated" delta, what interpolated means in this context i have no idea, because it doesn't look like its doing anything
		else
			elapsedTime = 1 / wantedFPS;
		dt = currentDT;


		//failed fixed delta
		// accumulator += elapsedTime;
		// if (accumulator > (1/wantedFPS) * 5)
        //     accumulator = (1/wantedFPS) * 5;
		// fixedDT = 0; //it should only pass a value if there's actually something there, otherwise don't
		// //in general fixedUpdate (and update in general) should only update if the dt is not 0, else you'd be having division by 0 errors
		
		//while (accumulator >= 1/wantedFPS){
        //	fixedUpdate();
		// 	accumulator -= 1/wantedFPS;
        //}
		// accumulator += elapsedTime; 

	}

	inline static function get_tmod() {
		return dt * wantedFPS;
	}

	inline static function set_tmod(v:Float) {
		dt = v / wantedFPS;
		return v;
	}

	public static function get_fixedDT(){
		return fixedDT;
	}

	/**
		The current smoothed FPS.
	**/
	public static function fps() : Float {
		// use currentDT to prevent gameplay change of dt to affect the displayed fps
		return 1. / currentDT;
	}

	/**
		After some loading / long processing, call skip() in order to prevent
		it from impacting your smoothed values.
	**/
	public static function skip() {
		lastTimeStamp = haxe.Timer.stamp();
	}

	/**
		Similar as skip() but also reset dt to default value.
		Can be used when starting a new game if you want to discard any previous measurement.
	**/
	public static function reset() {
		lastTimeStamp = haxe.Timer.stamp();
		dt = currentDT = 1. / wantedFPS;
	}

}


