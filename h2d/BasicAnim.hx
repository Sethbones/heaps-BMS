package h2d;

/**
	the animation system used here is very limited, if you only need to run an animation, without the need for any sort of control, then this will suffice
	
	however if you need proper control over things like the speed of each frame, or multiple animations on a single object,
	then you're going to have to write your own animation system or use `h2d.Anim`


	Displays an animated sequence of bitmap Tiles on the screen.

	Anim does not provide animation sequence management and it's up to user on how to implement it.
	Another limitation is framerate. Anim runs at a fixed framerate dictated by `Anim.speed`.
	Switching animations can be done through `Anim.play` method.

	Note that animation playback happens regardless of Anim visibility and only can be paused by `Anim.pause` flag. 
	Anim should be added to an active `h2d.Scene` in order to function.
**/
class BasicAnim extends Drawable {

	/**
		The current animation, as a list of tile frames to display.
		If the frames are empty or if a tile is frames is null, a pink 5x5 bitmap will be displayed instead.
	**/
	public var frames(default,null) : Array<Tile>;

	/**
		The current frame the animation is currently playing. Always in `[0,frames.length]` range.
		Use `Std.int(anim.currentFrame)` in order to obtain current frame index.
		Fractional value represents the progress of current frame and increases according to `Anim.speed` value.

		Setting frame to a negative value will wrap it around from the end of the animation. Setting negative value smaller than `-frames.length` lead to undefined behavior.
		Setting frame to a value greater than `frames.length` would cause to wrap around.
	**/
	public var currentFrame(get,set) : Float;

	/**
		The speed (in frames per second) at which the animation is playing.

		Settings speed to a negative value is not supported and leads to undefined behavior.
	**/
	public var speed : Float;

	/**
		Setting pause will suspend the animation, preventing automatic accumulation of `Anim.currentFrame` over time.
	**/
	public var pause : Bool = false;

	/**
		Disabling loop will stop the animation at the last frame.
	**/
	public var loop : Bool = true;

	/**
		When enabled, fading will draw two consecutive frames with alpha transition between
		them instead of directly switching from one to another when it reaches the next frame.
		This can be used to have smoother animation on some effects.
	**/
	public var fading : Bool = false;

	var curFrame : Float;

	/**
		Create a new animation with the specified frames, speed and parent object.
		@param frames An optional array of Tiles as an initial `Anim.frames` value.
		@param speed The Anim playback speed in frames per second.
		@param parent An optional parent `h2d.Object` instance to which Anim adds itself if set.
	**/
	public function new( ?frames : Array<Tile>, speed : Float = 15, ?parent : h2d.Object ) {
		super(parent);
		this.frames = frames == null ? [] : frames;
		this.curFrame = 0;
		this.speed = speed;
	}

	inline function get_currentFrame() {
		return curFrame;
	}

	/**
		Change the currently playing animation and unset the pause if it was set.
		@param frames The list of frames to play.
		@param atFrame Optional starting frame of the new animation.
	**/
	public function play( frames : Array<Tile>, atFrame = 0. ) {
		this.frames = frames == null ? [] : frames;
		currentFrame = atFrame;
		pause = false;
	}

	//a dynamic function?
	//okay so dynamic are functions that are alterable mid runtime
	//so this function can be called and traced and it wil print whatever its set to, neat
	//i get it... i don't get it.
	//okay so, it does nothing but i can override the call as like anim.onAnimEnd = function(){},
	//so that way when the callback is called, it can be overriden for whatever the usecase is
	//this is peak haxe usage
	/**
		Sent each time the animation reaches past the last frame.

		If `loop` is enabled, callback is sent every time the animation loops.
		During the call, `currentFrame` is already wrapped around and represent new frame position so it's safe to modify it.

		If `loop` is disabled, callback is sent only once when the animation reaches `currentFrame == frames.length`.
		During the call, `currentFrame` is always equals to `frames.length`.
	**/
	public dynamic function onAnimEnd() {
	}

	function set_currentFrame( frame : Float ) {
		curFrame = frames.length == 0 ? 0 : frame % frames.length;
		if( curFrame < 0 ) curFrame += frames.length;
		return curFrame;
	}

	override function getBoundsRec( relativeTo : Object, out : h2d.col.Bounds, forSize : Bool ) {
		super.getBoundsRec(relativeTo, out, forSize);
		var tile = getFrame();
		if( tile != null ) addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
	}

	//the pseudo update logic
	override function sync( ctx : RenderContext ) {
		super.sync(ctx);
		var prev = curFrame;
		if (!pause)
			curFrame += speed * ctx.elapsedTime;
		if( curFrame < frames.length )
			return;
		if( loop ) {
			if( frames.length == 0 )
				curFrame = 0;
			else
				curFrame %= frames.length;
			onAnimEnd();
		} else if( curFrame >= frames.length ) {
			curFrame = frames.length;
			if( curFrame != prev ) onAnimEnd();
		}
	}

	/**
		Returns the Tile at current frame.
	**/
	public function getFrame() : Tile {
		var i = Std.int(curFrame);
		if( i == frames.length ) i--;
		return frames[i];
	}

	//i don't even know what half of this does
	//so from my understanding you need a bitmap to draw something to the screen, but this doesn't do that?
	//okay so not really, emitTile is the drawing, its just super hyper optimized
	//it is absolute insanity how hyper optimized the engine is in all the areas that don't matter
	//its like, you can use the draw function and pass to a complex web of machinery, or you can a h2d.Bitmap, do you see the problem?
	//that and all examples on the heaps docs use h2d.Bitmap
	//so its a like a very old deprecated function but still useful for the 1% of 1% of users
	override function draw( ctx : RenderContext ) {
		var t = getFrame();
		if( fading ) {
			var i = Std.int(curFrame) + 1;
			if( i >= frames.length ) {
				if( !loop ) return;
				i = 0;
			}
			var t2 = frames[i];
			var old = ctx.globalAlpha;
			var alpha = curFrame - Std.int(curFrame);
			ctx.globalAlpha *= 1 - alpha;
			emitTile(ctx, t); //draw the one fading from
			ctx.globalAlpha = old * alpha;
			emitTile(ctx, t2); //draw the one faded into 
			ctx.globalAlpha = old;
		} else {
			emitTile(ctx,t); //just draw it
		}
	}

}
