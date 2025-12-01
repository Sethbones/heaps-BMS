package h2d.col;

/**
	An 2D collision line between two specified Points.
**/
class Line extends Collider {
	/**
		The first line point.
	**/
	public var p1 : Point;//its a point because it needs to have automatically moving and rotating coordinates, otherwise it would've been a vector2
	/**
		The second line point.
	**/
	public var p2 : Point;

	/**
		Create a new Line instance.
		@param p1 The first line point.
		@param p2 The second line point.
	**/
	public inline function new(parent:h2d.Object,a:h2d.Vector2,b:h2d.Vector2) {
		super(parent);
		this.p1 = new Point(this, a.x,a.y);
		this.p2 = new Point(this, b.x,b.y);
	}

	/**
		Returns a positive value if Point `p` is on the right side of the Line axis and negative if it's on the left.
	**/
	public inline function side( p : Point ) {
		return (p2.x - p1.x) * (p.y - p1.y) - (p2.y - p1.y) * (p.x - p1.x);
	}

	/**
		Projects Point `p` onto the Line axis and return new Point instance with a result.
	**/
	public inline function project( p : Point ) {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		var k = ((p.x - p1.x) * dx + (p.y - p1.y) * dy) / (dx * dx + dy * dy);
		return new Point(dx * k + p1.x, dy * k + p1.y);
	}

	/**
		Returns an intersection Point between given Line `l` and this Line with both treated as infinite lines.
		Returns `null` if lines are almost colinear (less than epsilon value difference)
	**/
	public inline function intersect( l : Line ) {
		var d = (p1.x - p2.x) * (l.p1.y - l.p2.y) - (p1.y - p2.y) * (l.p1.x - l.p2.x);
		if( hxd.Math.abs(d) < hxd.Math.EPSILON2 )//but theoratically speaking line intersects can still happen at values this low
			return null; //was probably done for performance reasons
		var a = p1.x*p2.y - p1.y * p2.x;
		var b = l.p1.x*l.p2.y - l.p1.y*l.p2.x;
		//why does it need to return a point?, why not just do the math here and now? ah yes read the function me.
		return new Point( (a * (l.p1.x - l.p2.x) - (p1.x - p2.x) * b) / d, (a * (l.p1.y - l.p2.y) - (p1.y - p2.y) * b) / d );
	}

	/**
		Tests for intersection between given Line `l` and this Line with both treated as infinite lines.
		Returns `false` if lines are almost colinear (less than epsilon value difference).
		Otherwise returns `true`, and fill Point `pt` with intersection point.
	**/
	public inline function intersectWith( l : Line, pt : Point ) {
		var d = (p1.x - p2.x) * (l.p1.y - l.p2.y) - (p1.y - p2.y) * (l.p1.x - l.p2.x);
		if( hxd.Math.abs(d) < hxd.Math.EPSILON2 )
			return false;
		var a = p1.x*p2.y - p1.y * p2.x;
		var b = l.p1.x*l.p2.y - l.p1.y*l.p2.x;
		pt.x = (a * (l.p1.x - l.p2.x) - (p1.x - p2.x) * b) / d;
		pt.y = (a * (l.p1.y - l.p2.y) - (p1.y - p2.y) * b) / d;
		return true;
	}

	/**
		Returns a squared distance from Line axis to Point `p`.
		Cheaper to calculate than `distance` and can be used for more optimal comparison operations.
	**/
	public inline function distanceSq( p : Point ) {
		//this feels over engineered, i can't even read this
		//i'm going to keep this as is until i have the IQ to understand this
		//the line calculation
		var dx = p2.x - p1.x; //the distance between both x values
		var dy = p2.y - p1.y; //the distance between both y values
		//the projection
		var k = ((p.x - p1.x) * dx + (p.y - p1.y) * dy) / (dx * dx + dy * dy); //some sort of scalar?
		//the values post projection to the point
		var mx = dx * k + p1.x - p.x; //x distance post projection
		var my = dy * k + p1.y - p.y; //y distance post projection
		trace(dx,dy,k,mx,my, p1.x, p1.y, p2.x,p2.y, p.x,p.y, hxd.Math.sqrt(mx * mx + my * my));
		return mx * mx + my * my; //the distance to the power of 2
	}

	/**
		Returns a distance from Line axis to Point `p`.
	**/
	public inline function distance( p : Point ) {
		//so if the point is at 0,0 it returns a 0 but if its on the line, it also returns a 0?
		//something is either this is wrong or i just don't get it
		//considering how outdated this file is, i'm leaning towards wrong
		return hxd.Math.sqrt(distanceSq(p));
	}

	/**
	 * The angle between a line and the x-axis
	 */
	public inline function angle():Float {
		var dx = p2.absX - p1.absX;
		var dy = p2.absY - p1.absY;
		return hxd.Math.atan2(dy, dx);
	}

	/**
	 * The angle between a line and the x-axis in degrees
	 * 
	 * meant for reading only
	 */
	public inline function angleDeg():Float {
		var dx = p2.absX - p1.absX;
		var dy = p2.absY - p1.absY;
		var rad = hxd.Math.atan2(dy, dx);
		return rad * 180 / Math.PI;
	}

	/**
		ended up being done manually during collision detection so it ended up useless
		
		The distance between Line starting Point `p1` and ending Point `p2`.
	**/
	public inline function length():Float {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		return hxd.Math.distance(dx, dy);
	}

	override function collision(target:Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return Common.linePoint(p1.toVector2(), p2.toVector2(), point.toVector2());
            case Circle:
                //i'm gonna have to do casting for these ones
                var circle = cast(target,Circle);
                return Common.lineCircle(p1.toVector2(), p2.toVector2(), circle.toVector3());
            case Square:
                var square = cast(target,Square);
                return Common.lineSquare(p1.toVector2(), p2.toVector2(), square.toVector4());
            case Line:
                var line = cast(target, Line);
                return Common.lineLine(p1.toVector2(),p2.toVector2(), line.p1.toVector2(),line.p2.toVector2());
            case Polygon:
                var polygon = cast(target, Polygon);
                return polygon.polyLine(this);
        }
        return false;
    }

    public override function collisionDraw(){
		if (debugDraw == null){
            debugDraw = new h2d.Graphics(p1);
        }
        else{//clear/reset it if its already there, to allow updating collision shapes
            debugDraw.clear();//quality
        }
		debugDraw.beginFill(0xffdf3232, 0.5);
		debugDraw.lineStyle(1.5,0x9defff0c,0.25); //there's no way for me to draw it "perfectly", as most lines just vanish at certain angles, so i'm going to say fuck that and just do this
		debugDraw.drawRect(0,0,length(),0); //speaking of which 2 lines are not a true shape, so i need a square anyway, just cut out the middle
		debugDraw.rotation = angle();
    };

	

}