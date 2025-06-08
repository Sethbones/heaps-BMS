package h2d;
import hxd.Math;

/**
	An integer-based Vector2.
	@see `h2d.Vector2`
**/
class Vector2I #if apicheck implements h2d.impl.PointApi.IPointApi<Vector2I> #end {

	/**
		Horizontal position of the point.
	**/
	public var x : Int;
	/**
		Vertical position of the point.
	**/
	public var y : Int;

	// -- gen api

	/**
		Create a new integer Point instance.
		@param x Horizontal position of the point.
		@param y Vertical position of the point.
	**/
	public inline function new(x = 0, y = 0) {
		this.x = x;
		this.y = y;
	}

	/**
		Copy the position from the given Vector2I `v` into this Vector2I.
	**/
	public inline function load( v : Vector2I ) {
		this.x = v.x;
		this.y = v.y;
	}

	/**
		Multiplies the position of this Vector2I by a given scalar `s`. Modifies this instance.
	**/
	public inline function scale( s : Int ) {
		x *= s;
		y *= s;
	}

	/**
		Returns a new Vector2I with the position of this Vector2I multiplied by a given scalar `s`.
	**/
	public inline function scaled( s : Int ) {
		return new Vector2I(x * s, y * s);
	}

	/**
		Returns squared distance between this Vector2I and given Vector2I `v`.
	**/
	public inline function distanceSq( v : Vector2I ) : Int {
		var dx = x - v.x;
		var dy = y - v.y;
		return dx * dx + dy * dy;
	}

	/**
		Returns a distance between this Vector2I and given Vector2I `v`.
	**/
	public inline function distance( v : Vector2I ) : Float {
		return Math.sqrt(distanceSq(v));
	}

	@:dox(hide)
	public function toString() : String {
		return "{" + x + "," + y + "}";
	}

	/**
		Subtracts Vector2I `v` from this Vector2I and returns new Point with the result.
	**/
	public inline function sub( v : Vector2I ) : Vector2I {
		return new Vector2I(x - v.x, y - v.y);
	}

	/**
		Adds Vector2I `v` to this Vector2I and returns new Point with the result.
	**/
	public inline function add( v : Vector2I ) : Vector2I {
		return new Vector2I(x + v.x, y + v.y);
	}

	/**
		Tests if this Vector2I position equals to `other` Vector2I position.
	**/
	public inline function equals( other : Vector2I ) : Bool {
		return x == other.x && y == other.y;
	}

	/**
		Returns a dot product between this Vector2I and given Vector2I `v`.
	**/
	public inline function dot( v : Vector2I ) : Int {
		return x * v.x + y * v.y;
	}

	/**
		Returns squared length of this Vector2I.
	**/
	public inline function lengthSq() : Int {
		return x * x + y * y;
	}

	/**
		Returns length (distance to `0,0`) of this Vector2I.
	**/
	public inline function length() : Float {
		return Math.sqrt(lengthSq());
	}

	/**
		Sets the Vector2I `x, y` with given values.
	**/
	public inline function set(x=0,y=0) {
		this.x = x;
		this.y = y;
	}

	/**
		Returns a copy of this Vector2I.
	**/
	public inline function clone() : Vector2I {
		return new Vector2I(x, y);
	}

	/**
		Returns a cross product between this Vector2I and a given Vector2I `v`.
	**/
	public inline function cross( v : Vector2I ) {
		return x * v.y - y * v.x;
	}

	// -- end gen api

	/**
		Converts this Vector2I to floating point-based `Vector2` scaled by provided scalar `scale`.
	**/
	public inline function toPoint( scale = 1. ) {
		return new h2d.Vector2(x * scale, y * scale);
	}

	//Godot and Unity have these and i like using them, performance be damned
	public static var UP:Vector2I = new Vector2I(0,-1);
	public static var LEFT:Vector2I = new Vector2I(-1,0);
	public static var DOWN:Vector2I = new Vector2I(0,1);
	public static var RIGHT:Vector2I = new Vector2I(1,0);
	public static var ZERO:Vector2I = new Vector2I(0,0);
	public static var POSITIVE:Vector2I = new Vector2I(1,1);
	public static var NEGATIVE:Vector2I = new Vector2I(-1,-1);
	public static var INF_POSITIVE:Vector2I = new Vector2I(Std.int(hxd.Math.POSITIVE_INFINITY), Std.int(hxd.Math.POSITIVE_INFINITY) );
	public static var INF_NEGATIVE:Vector2I = new Vector2I(Std.int(hxd.Math.NEGATIVE_INFINITY), Std.int(hxd.Math.NEGATIVE_INFINITY) );

}