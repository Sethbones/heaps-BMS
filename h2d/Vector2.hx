package h2d;
using hxd.Math;


/**
	A 2 Float vector2. Everytime a Vector is returned, it means a copy is created.
	@see `h2d.col.Vector2I` for an integer based Vector2
**/
class Vector2Impl #if apicheck implements h2d.impl.PointApi<Vector2,Matrix> #end {

	/**
		The horizontal position of the Vector2.
	**/
	public var x : Float;
	/**
		The vertical position of the Vector2.
	**/
	public var y : Float;

	// -- gen api

	/**
		Create a new Vector2 instance.
		@param x The horizontal position of the Vector.
		@param y The vertical position of the Vector.
	**/
	public inline function new(x = 0., y = 0.) {
		this.x = x;
		this.y = y;
	}

	/**
		Returns squared distance between this Vector and the given Vector `Vec2`.
	**/
	public inline function distanceSq( Vec2 : Vector2 ) {
		var dx = x - Vec2.x;
		var dy = y - Vec2.y;
		return dx * dx + dy * dy;
	}

	/**
		Returns a distance between this Vector and the given Vector `Vec2`.
	**/
	public inline function distance( Vec2 : Vector2 ) : Float {
		return Math.sqrt(distanceSq(Vec2));
	}

	@:dox(hide)
	public function toString() : String {
		return "{" + Math.fmt(x) + "," + Math.fmt(y) + "}";
	}

	/**
		Substracts Vector `Vec2` from this Vector and return a new Vector with the result.
	**/
	public inline function sub( Vec2 : Vector2 ) : Vector2 {
		return new Vector2(x - Vec2.x, y - Vec2.y);
	}

	/**
		Adds Vector `Vec2` to this Vector and return a new Vector with the result.
	**/
	public inline function add( Vec2 : Vector2 ) : Vector2 {
		return new Vector2(x + Vec2.x, y + Vec2.y);
	}

	/**
		Returns a new Vector with the position of this Vector multiplied by the given scalar `v`.
	**/
	public inline function scaled( v : Float ) {
		return new Vector2(x * v, y * v);
	}

	/**
		Tests if this Vector's position is equal to `other` Vector's position.
	**/
	public inline function equals( other : Vector2 ) : Bool {
		return x == other.x && y == other.y;
	}

	/**
		Returns a dot product between this Vector and the given Vector `Vec2`.
	**/
	public inline function dot( Vec2 : Vector2 ) : Float {
		return x * Vec2.x + y * Vec2.y;
	}

	/**
		Returns a squared length of the current Vector.
	**/
	public inline function lengthSq() {
		return x * x + y * y;
	}

	/**
		Returns the length (distance from `0,0`) of this Vector.
	**/
	public inline function length() : Float {
		return Math.sqrt(lengthSq());
	}

	/**
		Normalizes the Vector.
	**/
	public inline function normalize() {
		var k = lengthSq();
		if( k < Math.EPSILON2 ) k = 0 else k = Math.invSqrt(k);
		x *= k;
		y *= k;
	}

	/**
		Returns a new Vector with the normalized values of this Vector.
	**/
	public inline function normalized() {
		var k = lengthSq();
		if( k < Math.EPSILON2 ) k = 0 else k = Math.invSqrt(k);
		return new Vector2(x*k,y*k);
	}

	/**
		Sets the Vector's `x,y` values to the given values.
	**/
	public inline function set(x=0.,y=0.) {
		this.x = x;
		this.y = y;
	}

	/**
		Copies `x,y` from the given Vector `Vec2` to the current Vector.
	**/
	public inline function load( Vec2 : Vector2 ) {
		this.x = Vec2.x;
		this.y = Vec2.y;
	}

	/**
		Multiplies `x,y` by the scalar `f`.
	**/
	public inline function scale( f : Float ) {
		x *= f;
		y *= f;
	}

	/**
		Returns a copy of this Vector.
	**/
	public inline function clone() : Vector2 {
		return new Vector2(x, y);
	}

	/**
		Returns a cross product between this Vector and a given Vector `Vec2`.
	**/
	public inline function cross( Vec2 : Vector2 ) {
		return x * Vec2.y - y * Vec2.x;
	}

	/**
		Sets this Vector's position to the result of the linear interpolation between Vectors `v1` and `v2` at the interpolant position of `k`.
	**/
	public inline function lerp( v1 : Vector2, v2 : Vector2, k : Float ) {
		x = hxd.Math.lerp(v1.x, v2.x, k);
		y = hxd.Math.lerp(v1.y, v2.y, k);
	}

	/**
		Applies the given Matrix's `m` transformation to this Vector's position.
	**/
	public inline function transform( m : Matrix ) {
		var mx = m.a * x + m.c * y + m.x;
		var my = m.b * x + m.d * y + m.y;
		this.x = mx;
		this.y = my;
	}

	/**
		Returns a new Vector with the result of applying the Matrix `m` to this Vector's position.
	**/
	public inline function transformed( m : Matrix ) {
		var mx = m.a * x + m.c * y + m.x;
		var my = m.b * x + m.d * y + m.y;
		return new Vector2(mx,my);
	}

	/**
		Applies a given 2x2 Matrix `m` transformation to this Vector's position.
	**/
	public inline function transform2x2( m : Matrix ) {
		var mx = m.a * x + m.c * y;
		var my = m.b * x + m.d * y;
		this.x = mx;
		this.y = my;
	}

	/**
		Returns a new Vector with the result of applying a 2x2 Matrix `m` to this Vector's position.
	**/
	public inline function transformed2x2( m : Matrix ) {
		var mx = m.a * x + m.c * y;
		var my = m.b * x + m.d * y;
		return new Vector2(mx,my);
	}


	// -- end

	/**
		Converts this Vector to an integer based Vector2I scaled by provided scalar `scale` (rounded).
		which currently doesn't exist
		i.e W.I.P
	**/
	public inline function toIPoint( scale = 1. ) {
		return new h2d.col.IPoint(Math.round(x * scale), Math.round(y * scale));
	}

	/**
		Rotates this Vector around `0,0` by a given `angle`.
	**/
	public inline function rotate( angle : Float ) {
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		var x2 = x * c - y * s;
		var y2 = x * s + y * c;
		x = x2;
		y = y2;
	}

}



/**
	A 2 Float Vector. Everytime a Vector is returned, it means a copy is created.
**/
@:forward abstract Vector2(Vector2Impl) from Vector2Impl to Vector2Impl {

	public inline function new( x = 0., y = 0. ) {
		this = new Vector2Impl(x,y);
	}

	@:op(a - b) public inline function sub(v:Vector2) return this.sub(v);
	@:op(a + b) public inline function add(v:Vector2) return this.add(v);
	// @:op(a *= b) public inline function transform(m:h2d.col.Matrix) this.transform(m);
	// @:op(a * b) public inline function transformed(m:h2d.col.Matrix) return this.transformed(m);

	// to deprecate at final refactoring. //this code chunk is about a year old, i have no idea what this means 
	public inline function toPoint() return this.clone(); //pointless atm and will likely be removed soon
	public inline function toVector3() return new h3d.Vector(this.x,this.y,0);
	public inline function toVector4() return new h3d.Vector4(this.x,this.y);

	@:op(a *= b) public inline function scale(v:Float) this.scale(v);
	@:op(a * b) public inline function scaled(v:Float) return this.scaled(v);
	@:op(a * b) static inline function scaledInv( f : Float, v : Vector2 ) return v.scaled(f);

	public static inline function fromArray(a : Array<Float>) { //i have yet to validate if this works, there's no reason it shouldn't but stil
		var r = new Vector2();
		if(a.length > 0) r.x = a[0];
		if(a.length > 1) r.y = a[1];
		return r;
	}

	//Godot and Unity have these and i like using them, performance be damned
	public static var UP:Vector2 = new Vector2(0,-1);
	public static var LEFT:Vector2 = new Vector2(-1,0);
	public static var DOWN:Vector2 = new Vector2(0,1);
	public static var RIGHT:Vector2 = new Vector2(1,0);
	public static var ZERO:Vector2 = new Vector2(0,0);
	public static var POSITIVE:Vector2 = new Vector2(1,1);
	public static var NEGATIVE:Vector2 = new Vector2(-1,-1);
	public static var INF_POSITIVE:Vector2 = new Vector2(hxd.Math.POSITIVE_INFINITY, hxd.Math.POSITIVE_INFINITY);
	public static var INF_NEGATIVE:Vector2 = new Vector2(hxd.Math.NEGATIVE_INFINITY, hxd.Math.NEGATIVE_INFINITY);

}