package hxd;

/**
	Base class for a Heaps application.

	This class contains code to set up a typical Heaps app,
	including 3D and 2D scene, input, update and loops.

	It's designed to be a base class for an application entry point,
	and provides several methods for overriding, in which we can plug
	custom code. See API documentation for more information.
**/
class App implements h3d.IDrawable {

	/**
		The rendering engine.
	**/
	public var engine(default,null) : h3d.Engine;

	/**
		The Default 3D scene.
	**/
	public var s3d(default,null) : h3d.scene.Scene; //this needs to be figured out, this is not clean, why is scene in its own folder while its not like that in h2d?

	/**
		The Default 2D scene.
	**/
	public var s2d(default,null) : h2d.Scene;

	/**
		The default HUD and GUI scene.

		meant as a draw layer on top of s2d
	**/
	// public var sui(default,null) : h2d.Scene;

	/**
		The final render scene, draws all other scenes on top of it

		meant as a containter for screen shaders.
	*/
	//public var rnd(default,null) : h2d.Scene;

	/**
		Input event listener collection.
		Both 2D and 3D scenes are added to it by default.
	**/
	public var sevents(default,null) : hxd.SceneEvents;

	/**
	 * the manager for all countdown based events
	 * 
	 * see `hxd.TimerManager`
	 */
	public var timer(default,null): hxd.TimerManager;

	/**
	 * is the engine kaput or not
	 */
	var isDisposed : Bool;

	public function new() {
		var engine = h3d.Engine.getCurrent();
		if( engine != null ) {
			this.engine = engine;
			engine.onReady = setup;
			haxe.Timer.delay(setup, 0);
		} else {
			hxd.System.start(function() {
				this.engine = engine = @:privateAccess new h3d.Engine();
				engine.onReady = setup;
				engine.init();
			});
		}
	}

	/**
		Screen resize callback.

		By default does nothing. Override this method to provide custom on-resize logic.
	**/
	@:dox(show)
	function onResize() {
	}

	/**
		Switch either the 2d or 3d scene with another instance, both in terms of rendering and event handling.
		If you call disposePrevious, it will call dispose() on the previous scene.
	**/
	public function setScene( scene : hxd.SceneEvents.InteractiveScene, disposePrevious = true ) {
		var new2D = Std.downcast(scene, h2d.Scene);
		var new3D = Std.downcast(scene, h3d.scene.Scene);
		timer.removeAllTimers();
		if( new2D != null ) {
			sevents.removeScene(s2d);
			sevents.addScene(scene, 0);
		} else if( new3D != null ) {
			sevents.removeScene(s3d);
			sevents.addScene(scene);
		}
		if( disposePrevious ) {
			if( new2D != null )
				s2d.dispose();
			else if( new3D != null )
				s3d.dispose();
			else
				throw "Can't dispose previous scene";
		}
		if( new2D != null )
			this.s2d = new2D;
		if( new3D != null )
			this.s3d = new3D;
	}

	/**
	 * When using multiple hxd.App, this will set the current App (the one on which update etc. will be called)
	**/
	public function setCurrent() {
		engine = h3d.Engine.getCurrent(); // if was changed
		isDisposed = false;
		engine.onReady = staticHandler; // in case we have another pending app
		engine.onContextLost = onContextLost;
		engine.onResized = function() {
			if( s2d == null ) return; // if disposed
			s2d.checkResize();
			onResize();
		};
		hxd.System.setLoop(mainLoop);
	}

	function onContextLost() {
		if( s3d != null ) s3d.onContextLost();
	}

	// //what the heck is the point of these 2 functions, setScene already does both and this is private for some reason
	// function setScene2D( s2d : h2d.Scene, disposePrevious = true ) {
	// 	sevents.removeScene(this.s2d);
	// 	sevents.addScene(s2d,0);
	// 	if( disposePrevious )
	// 		this.s2d.dispose();
	// 	this.s2d = s2d;
	// 	s2d.mark = mark; //oh hi mark
	// }

	// function setScene3D( s3d : h3d.scene.Scene, disposePrevious = true ) {
	// 	sevents.removeScene(this.s3d);
	// 	sevents.addScene(s3d);
	// 	if ( disposePrevious )
	// 		this.s3d.dispose();
	// 	this.s3d = s3d;
	// }

	public function render(e:h3d.Engine) {
		s3d.render(e);
		s2d.render(e);
		//sui.render(e);
	}

	/**
	 * this likely either has something to do with HIDE or with some sort of profiler, what they are i don't know:
	 * 
	 * s2d does: mark("s2d"); and mark("vsync");
	 * 
	 * while s3d does: mark("sync"); and mark("emit");
	 * 
	 * this while also mentioning something by the name of sceneprof, which looks to be some sort of profiler
	 * @param name 
	 */
	function mark(name : String) {
		s3d.mark(name);
	}

	function setup() {
		var initDone = false;
		engine.onReady = staticHandler;
		engine.onContextLost = onContextLost;
		engine.onResized = function() {
			if( s2d == null ) return; // if disposed
			s2d.checkResize();
			if( initDone ) onResize();
		};
		timer = new hxd.TimerManager();
		s3d = new h3d.scene.Scene();
		s2d = new h2d.Scene();
		s2d.mark = mark; //pass app.mark to s2d.mark?
		sevents = new hxd.SceneEvents();
		sevents.addScene(s2d);
		sevents.addScene(s3d);
		loadAssets(function() {
			initDone = true;
			init();
			hxd.Timer.skip();
			mainLoop();
			hxd.System.setLoop(mainLoop);
			hxd.Key.initialize();
		});
	}

	function dispose() {
		engine.onResized = staticHandler;
		engine.onContextLost = staticHandler;
		isDisposed = true;
		if( s2d != null ) s2d.dispose();
		if( s3d != null ) s3d.dispose();
		if( sevents != null ) sevents.dispose();
	}

	/**
		Load assets asynchronously.

		Called during application setup. By default immediately calls `onLoaded`.
		Override this method to provide asynchronous asset loading logic.

		@param onLoaded a callback that should be called by the overriden
		                method when loading is complete
	**/
	@:dox(show)
	function loadAssets( onLoaded : Void->Void ) {
		onLoaded();
	}

	/**
		Initialize application.

		Called during application setup after `loadAssets` completed.
		By default does nothing. Override this method to provide application initialization logic.
	**/
	@:dox(show)
	function init() {
	}

	/**
	 * seems to be similar to update(), except it runs on a seperate function to avoid conflicts when overriding
	 */
	function mainLoop() {
		hxd.Timer.update();
		sevents.checkEvents();
		if( isDisposed ) return;
		update(hxd.Timer.dt);
		if( isDisposed ) return;
		var dt = hxd.Timer.dt; // fetch again in case it's been modified in update()
		if( s2d != null ) s2d.setElapsedTime(dt);
		if( s3d != null ) s3d.setElapsedTime(dt);
		engine.render(this);
		if( timer != null ) timer.update();
		//updates the children of the currently active scene.
		if( s2d != null ) s2d.mainLoop();
		if( s3d != null ) s3d.mainLoop();
		//if( sui != null ) sui.update();
	}

	/**
		Update application.

		Called each frame right before rendering.
		First call is done after the application is set up (so `loadAssets` and `init` are called).

		@param dt Time elapsed since last frame, normalized.
	**/
	@:dox(show)
	function update( dt : Float ) {
	}

	static function staticHandler() {}

}
