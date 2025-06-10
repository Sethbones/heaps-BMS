package h2d;

/**
	Displays a single bitmap Tile on the screen.

	It is a most primitive Drawable and easiest to use, but vastly inferior to others in terms of performance when used for rendering of many tiles.
	When dealing with many images at once, it is recommended to use batched renderers, like `h2d.SpriteBatch` or `h2d.TileGroup`.
**/
class Bitmap extends Drawable {

	/**
		The tile to display. See `h2d.Tile` documentation for details.
		If the tile is null, a pink 5x5 bitmap will be displayed instead.
	**/
	public var tile(default,set) : Tile;

	/**
		If set, rescale the tile to match the given width, keeping the aspect ratio unless `height` is also set.

		Note that both `width` and `height` are `null` by default and in order to retrieve bitmap dimensions with
		scaling accurately, call `getSize` method or address `tile.width/height` to get unscaled dimensions.
	**/
	public var width(default,set) : Null<Float>;

	/**
		If set, rescale the tile to match the given height, keeping the aspect ratio unless `width` is also set.

		Note that both `width` and `height` are `null` by default and in order to retrieve bitmap dimensions with
		scaling accurately, call `getSize` method or address `tile.width/height` to get unscaled dimensions.
	**/
	public var height(default,set) : Null<Float>;

	//there doesn't seem to be a way to directly load an image from the source code directory, so base64 is used for now, at least until a better solution is found
	/**
	 * a placeholder image that is loaded when a null tile is given, that should be a very occurance but it could still be an occurance
	 */
	var placeholder(default, null):String = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAOZJREFUOI2lkzsOwjAMhr9UdOC9tIfhBhyJI7BwCjbExsLIxgl6CcqCKqgojzCYQGkcGPBiJfL/+3PkGMDih1Hu0GoNYKvV85BIjkeekQW4bOVwXkruzaD1Yb+X7ArjkS70CGwBl43OXAXub1nCcL0nCswKwDWDKP1WUZuxSXHNPgvvud8dMCpBUwxhEmdgTD8sbpq47nUDwdyFxe+atkpgbfEdVehEfBgnuN1Q30AzceJmvPbgvFBw87DY5t3fexCl4c4uWuB3rzYiGsxLoOQ09UlMenwb6MLXiHQm8mCnaekb/fudH9p/YHVXjw4OAAAAAElFTkSuQmCC";


	/**
		Create a Bitmap with specified tile and parent object.
		@param tile A Tile that should be rendered by this Bitmap.
		@param parent An optional parent `h2d.Object` instance to which Bitmap adds itself if set.
	**/
	public function new( ?tile : Tile, ?parent : h2d.Object ) {
		super(parent);
		if (tile != null){
			this.tile = tile;
		}
		else{
			//there doesn't seem to be a way to directly load an image from the source code's directory
			//chances you won't ever see this, but it in rare occasions it could still show up.
			this.tile = hxd.res.Any.fromBytes("", haxe.crypto.Base64.decode(placeholder) ).toTile();
		}
	}

	override function getBoundsRec( relativeTo : Object, out : h2d.col.Bounds, forSize : Bool ) {
		super.getBoundsRec(relativeTo, out, forSize);
		if( tile != null ) {
			if( width == null && height == null )
				addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
			else
				addBounds(relativeTo, out, tile.dx, tile.dy, width != null ? width : tile.width * height / tile.height, height != null ? height : tile.height * width / tile.width);
		}
	}

	function set_width(w) {
		if( width == w ) return w;
		width = w;
		onContentChanged();
		return w;
	}

	function set_height(h) {
		if( height == h ) return h;
		height = h;
		onContentChanged();
		return h;
	}

	function set_tile(t) {
		if( tile == t ) return t;
		tile = t;
		onContentChanged();
		return t;
	}

	override function draw( ctx : RenderContext ) {
		if( width == null && height == null ) {
			emitTile(ctx,tile);
			return;
		}
		if( tile == null ) tile = h2d.Tile.fromColor(0xFF00FF);
		var ow = tile.width;
		var oh = tile.height;
		@:privateAccess {
			tile.width = width != null ? width : ow * height / oh;
			tile.height = height != null ? height : oh * width / ow;
		}
		emitTile(ctx,tile);
		@:privateAccess {
			tile.width = ow;
			tile.height = oh;
		}
	}

}
