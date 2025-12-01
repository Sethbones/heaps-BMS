package h2d.col;
import hxd.Math;

/**
	The circular hitbox implementation of a 2D Collider.
**/
class Circle extends Collider {

	/**
		Radius of the circle.
	**/
	public var ray : Float;

	/**
		Create new Circle collider.
		@param x X position of the Circle center relative to the given parent.
		@param y Y position of the Circle center relative to the given parent.
		@param ray Radius of the circle.
	**/
	public override function new(?parent:h2d.Object, x : Float, y : Float, ray : Float ) {
		this.ray = ray;
		super(parent);
		this.x = x;
		this.y = y;
	}

	//this was probably abandoned at some point, as all functions here that call a distanceSq function just call the hxd.Math one, so it begs the question, what in the fucking
	/**
		Returns a squared distance between the Circle center and the given Point `p`.
	**/
	public inline function distanceSq( p : Point ) : Float {
		var dx = p.x - x; //point's x - circle's x
		var dy = p.y - y; //points.y - circle's y
		//the problem with this thing is that, if a circle's x and y are at 0 it just returns 0, and containspoint true
		//this is a cool and functional engine
		var d = dx * dx + dy * dy - ray * ray; //black magic operator, this seems to be doing distance calculation but its like half fucked
		//like its a^2 + b^2 = c^2
		//there's no c here because you're calculating distance
		//so what's the point of ray being here?, its a static value?
		//the final outcome of calculating the square is that its always off by ray * ray
		//and thus comes this part below, because it can result in minused values which incorrectly get reported as 0,
		return d < 0 ? 0 : d; //if (d < 0) return 0 else return d;
	}

	/**
		Returns a squared distance between the Circle border and the given Point `p`.
	**/
	public inline function side( p : Point ) : Float {
		var dx = p.x - x;
		var dy = p.y - y;
		return ray * ray - (dx * dx + dy * dy);
	}

	/**
		Tests if this Circle collides with the given Circle `c`.
	**/
	public inline function collideCircle( c : Circle ) : Bool {
		//this could probably be simplified
		var dx = x - c.x;
		var dy = y - c.y;
		return dx * dx + dy * dy < (ray + c.ray) * (ray + c.ray);
	}

	/**
		Test if this Circle collides with the given Bounds `b`.
	**/
	public inline function collideBounds( b : Bounds ) : Bool {
		//damn this is a cool way to go about this, respect
		if( x < b.xMin - ray ) return false;
		if( x > b.xMax + ray ) return false;
		if( y < b.yMin - ray ) return false;
		if( y > b.yMax + ray ) return false;
		if( x < b.xMin && y < b.yMin && Math.distanceSq(x - b.xMin, y - b.yMin) > ray*ray ) return false;
		if( x > b.xMax && y < b.yMin && Math.distanceSq(x - b.xMax, y - b.yMin) > ray*ray ) return false;
		if( x < b.xMin && y > b.yMax && Math.distanceSq(x - b.xMin, y - b.yMax) > ray*ray ) return false;
		if( x > b.xMax && y > b.yMax && Math.distanceSq(x - b.xMax, y - b.yMax) > ray*ray ) return false;
		return true;
	}

	/**
		Tests if this Circle intersects with a line segment from Point `p1` to Point `p2`.
		@returns An array of Points with intersection coordinates.
		Contains 1 Point if line intersects only once or 2 points if line enters and exits the circle.
		If no intersection is found, returns `null`.
	**/
	public inline function lineIntersect(p1 : h2d.col.Point, p2:h2d.col.Point) : Array<Point> {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		var a = dx * dx + dy * dy;
		if (a < 1e-8) return null;
		var b = 2 * (dx * (p1.x - x) + dy * (p1.y - y));
		var c = hxd.Math.distanceSq(p1.x - x, p1.y - y) - ray * ray;
		var d = b * b - 4 * a * c;

		if(d < 0) return null;
		if(d == 0) {
			var t = -b / (2 * a);
			return [new h2d.col.Point(p1.x + t * dx, p1.y + t * dy)];
		}

		var t1 = (-b - Math.sqrt(d)) / (2 * a);
		var t2 = (-b + Math.sqrt(d)) / (2 * a);
		return [new h2d.col.Point(p1.x + t1 * dx, p1.y + t1 * dy), new h2d.col.Point(p1.x + t2 * dx, p1.y + t2 * dy)];
	}

	@:dox(hide)
	public override function toString() {//uh huh, yes, cause this is useful
		return '{${Math.fmt(x)},${Math.fmt(y)},${Math.fmt(ray)}}';
	}

	//chances are, this is what i need
	/**
		Tests if Point `p` is inside this Circle.
	**/
	public function containsPoint( p : Point ) : Bool {
		return hxd.Math.distance(p.absX - this.absX, p.absY - this.absY) <= ray;
	}

	override function collision(target:Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return Common.circlePoint(point.toVector2(), this.toVector3());
            case Circle:
                //i'm gonna have to do casting for these ones
                var circle = cast(target,Circle);
                return Common.circleCircle(this.toVector3(), circle.toVector3());
            case Square:
                var square = cast(target,Square);
                return Common.circleSquare(square.toVector4(), this.toVector3());
            case Line:
                var line = cast(target, Line);
                return Common.lineCircle(line.p1.toVector2(),line.p2.toVector2(), this.toVector3());
            case Polygon:
                var polygon = cast(target, Polygon);
                return polygon.polyCircle(this);
        }
        return false;
    }

	public override function collisionDraw(){
		super.collisionDraw();
        debugDraw.beginFill(0xff6cc2e4, 0.5);
        debugDraw.drawCircle(0,0,ray,32);
    };

	public function toVector3(){
		return new h3d.Vector(this.absX,this.absY,this.ray);
	}


}