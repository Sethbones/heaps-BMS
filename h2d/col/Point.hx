package h2d.col;
import hxd.Math;

/**
	idea 3:

	A simple 2D collision point

	idea 2:

	the current idea is to completely make this child based.

	the theory is, i'm already making it follow something, might as well attach it to it to save a couple lines of code

	this is what most game engines do, you can't just create a collision shape and have it run around on its own, it has to be attached to something in order to function

	bro what the fuck is this engine, why isn't this just a vector2?
	it basically is just a vector2 

	NEW Description idea:

	A stripped down Vector2, designed to serve a specific purpose.

	old:

	A simple 2D position/vector container, that is attached to an object of one's choice.
	@see `h2d.col.IPoint` for an integer based Point
**/
class PointImpl #if apicheck implements h2d.impl.PointApi<Point,Matrix> #end {

	/**
		The horizontal position of the point.
	**/
	public var x : Float;
	/**
		The vertical position of the point.
	**/
	public var y : Float;

	// -- gen api, yes sir.

	/**
		Create a new Point instance.
		@param x The horizontal position of the point.
		@param y The vertical position of the point.
	**/
	public inline function new(x = 0., y = 0.) {
		this.x = x;
		this.y = y;
	}

	/**
		Returns squared distance between this Point and given Point `p`.
	**/
	public inline function distanceSq( p : Point ) {
		var dx = x - p.x;
		var dy = y - p.y;
		return dx * dx + dy * dy;
	}

	/**
		Returns a distance between this Point and given Point `p`.
	**/
	public inline function distance( p : Point ) : Float {
		return Math.sqrt(distanceSq(p));
	}

	@:dox(hide)
	public function toString() : String {
		return "{" + Math.fmt(x) + "," + Math.fmt(y) + "}";
	}

	/**
		Substracts Point `p` from this Point and returns new Point with the result.
	**/
	public inline function sub( p : Point ) : Point {
		return new Point(x - p.x, y - p.y);
	}

	/**
		Adds Point `p` to this Point and returns new Point with the result.
	**/
	public inline function add( p : Point ) : Point {
		return new Point(x + p.x, y + p.y);
	}

	/**
		Returns a new Point with the position of this Point multiplied by a given scalar `v`.
	**/
	public inline function scaled( v : Float ) {
		return new Point(x * v, y * v);
	}

	/**
		Tests if this Point position equals to `other` Point position.
	**/
	public inline function equals( other : Point ) : Bool {
		return x == other.x && y == other.y;
	}

	/**
		Returns a dot product between this Point and given Point `p`.
	**/
	public inline function dot( p : Point ) : Float {
		return x * p.x + y * p.y;
	}

	/**
		Returns squared length of this Point.
	**/
	public inline function lengthSq() {
		return x * x + y * y;
	}

	/**
		Returns length (distance to `0,0`) of this Point.
	**/
	public inline function length() : Float {
		return Math.sqrt(lengthSq());
	}

	/**
		Normalizes the Point.
	**/
	public inline function normalize() {
		var k = lengthSq();
		if( k < Math.EPSILON2 ) k = 0 else k = Math.invSqrt(k);
		x *= k;
		y *= k;
	}

	/**
		Returns a new Point with the normalized values of this Point.
	**/
	public inline function normalized() {
		var k = lengthSq();
		if( k < Math.EPSILON2 ) k = 0 else k = Math.invSqrt(k);
		return new h2d.col.Point(x*k,y*k);
	}

	/**
		Sets the Point `x,y` with given values.
	**/
	public inline function set(x=0.,y=0.) {
		this.x = x;
		this.y = y;
	}

	/**
		Copies `x,y` from given Point `p` to this Point.
	**/
	public inline function load( p : h2d.col.Point ) {
		this.x = p.x;
		this.y = p.y;
	}

	/**
		Multiplies `x,y` by scalar `f`.
	**/
	public inline function scale( f : Float ) {
		x *= f;
		y *= f;
	}

	/**
		Returns a copy of this Point.
	**/
	public inline function clone() : Point {
		return new Point(x, y);
	}

	/**
		Returns a cross product between this Point and a given Point `p`.
	**/
	public inline function cross( p : Point ) {
		return x * p.y - y * p.x;
	}

	/**
		Sets this Point position to a result of linear interpolation between Points `p1` and `p2` at the interpolant position `k`.
	**/
	public inline function lerp( a : Point, b : Point, k : Float ) {
		x = hxd.Math.lerp(a.x, b.x, k);
		y = hxd.Math.lerp(a.y, b.y, k);
	}

	/**
		Applies a given Matrix `m` transformation to this Point position.
	**/
	public inline function transform( m : Matrix ) {
		var mx = m.a * x + m.c * y + m.x;
		var my = m.b * x + m.d * y + m.y;
		this.x = mx;
		this.y = my;
	}

	/**
		Returns a new Point with a result of applying a Matrix `m` to this Point position.
	**/
	public inline function transformed( m : Matrix ) {
		var mx = m.a * x + m.c * y + m.x;
		var my = m.b * x + m.d * y + m.y;
		return new Point(mx,my);
	}

	/**
		Applies a given 2x2 Matrix `m` transformation to this Point position.
	**/
	public inline function transform2x2( m : Matrix ) {
		var mx = m.a * x + m.c * y;
		var my = m.b * x + m.d * y;
		this.x = mx;
		this.y = my;
	}

	/**
		Returns a new Point with a result of applying a 2x2 Matrix `m` to this Point position.
	**/
	public inline function transformed2x2( m : Matrix ) {
		var mx = m.a * x + m.c * y;
		var my = m.b * x + m.d * y;
		return new Point(mx,my);
	}


	// -- end

	/**
		Converts this point to integer point scaled by provided scalar `scale` (rounded).
	**/
	public inline function toIPoint( scale = 1. ) {
		return new IPoint(Math.round(x * scale), Math.round(y * scale));
	}

	/**
		Rotates this Point around `0,0` by a given `angle`.
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

@:forward abstract Point(PointImpl) from PointImpl to PointImpl {

	public inline function new(x=0.,y=0.) {
		this = new PointImpl(x,y);
	}

	@:op(a - b) public inline function sub(p:Point) return this.sub(p);
	@:op(a + b) public inline function add(p:Point) return this.add(p);
	@:op(a *= b) public inline function transform(m:Matrix) this.transform(m);
	@:op(a * b) public inline function transformed(m:Matrix) return this.transformed(m);

	@:op(a *= b) public inline function scale(v:Float) this.scale(v);
	@:op(a * b) public inline function scaled(v:Float) return this.scaled(v);
	@:op(a * b) static inline function scaledInv( f : Float, p : Point ) return p.scaled(f);

}
