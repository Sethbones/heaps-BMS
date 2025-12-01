package h2d.col;
import hxd.Math;
/**
	a container for an array of `Point`s that defines a polygonal shape that can be collision-tested against.
	@see `h2d.col.IPolygon` for something that doesn't exist
	doing an abstract would make it impossible to move, and no way in hell am i manually moving and rotating a polygon
**/
class Polygon extends Collider {

	/**
		The underlying Array of vertices.
	**/
	public var points:Array<Point>;
	/**
		The amount of vertices in the polygon.
	**/

	/**
		Create a new Polygon shape.
		@param points An optional array of vertices the polygon should use.
	**/
	public inline function new(parent:h2d.Object, vectors:Array<h2d.Vector2> ) {
		super(parent);
		points = [];
		for (v in vectors){
			points.push(new Point(this,v.x,v.y));
		}
	}

	/**
		Uses EarCut algorithm to quickly triangulate the polygon.
		This will not create the best triangulation possible but is quite solid wrt self-intersections and merged points.
		Returns the points indexes
	**/
	public function fastTriangulate() {
		return new hxd.earcut.Earcut().triangulate(cast points);
	}

	// //broken
	// /**
	// 	Returns new Segments instance containing polygon edges.
	// **/
	// public function toSegments() : Segments {
	// 	var segments = [];
	// 	var p1 = points[points.length - 1];
	// 	for( p2 in points ) {
	// 		var s = new Segment(p1, p2);
	// 		segments.push(s);
	// 		p1 = p2;
	// 	}
	// 	return segments;
	// }

	//Ipolygon has been removed
	// /**
	// 	Converts Polygon to Int-based IPolygon.
	// **/
	// public function toIPolygon( scale = 1. ) : IPolygon {
	// 	return [for( p in points ) p.toIPoint(scale)];
	// }

	//bounds have yet to be updated
	// /**
	// 	Returns bounding box of the Polygon.
	// 	@param b Optional Bounds instance to be filled. Returns new Bounds instance if `null`.
	// **/
	// public function getBounds( ?b : Bounds ) {
	// 	if( b == null ) b = new Bounds();
	// 	for( p in points )
	// 		b.addPoint(p);
	// 	return b;
	// }

	//polygoncollider has been merged into here
	// /**
	// 	Returns new `PolygonCollider` instance containing this Polygon.
	// 	@param isConvex Use simplified collision test suited for convex polygons. Results are undefined if polygon is concave.
	// **/
	// public function getCollider(isConvex : Bool = false) {
	// 	return new PolygonCollider([this], isConvex);
	// }

	/**
	 * i don't know what this does, so i'm doing vector2 on these
	 */
	inline function xSort(a : h2d.Vector2, b : h2d.Vector2) {
		if(a.x == b.x)
			return a.y < b.y ? -1 : 1;
		return a.x < b.x ? -1 : 1;
	}

	//xsort asks for points instead of vector2s
	// /**
	// 	Returns a new Polygon containing a convex hull of this Polygon.
	// 	See Monotone chain algorithm for more details.
	// **/
	// public function convexHull() {
	// 	var len = points.length;
	// 	if( points.length < 3 )
	// 		return points;

	// 	points.sort(xSort);

	// 	var hull = [];
	// 	var k = 0;
	// 	for (p in points) {
	// 		while (k >= 2 && side(hull[k - 2], hull[k - 1], p) <= 0)
	// 			k--;
	// 		hull[k++] = p;
	// 	}

	//    var i = points.length - 2;
	//    var len = k + 1;
	//    while(i >= 0) {
	// 		var p = points[i];
	// 		while (k >= len && side(hull[k - 2], hull[k - 1], p) <= 0)
	// 			k--;
	// 		hull[k++] = p;
	// 		i--;
	//    }

	//    while( hull.length >= k )
	// 		hull.pop();
	//    return hull;
	// }

	/**
		Tests if polygon points are in the clockwise order.
	**/
	public function isClockwise() {
		var sum = 0.;
		var p1 = points[points.length - 1];
		for( p2 in points ) {
			sum += (p2.x - p1.x) * (p2.y + p1.y);
			p1 = p2;
		}
		return sum < 0; // Y axis is negative compared to classic maths
	}

	/**
		Calculates total area of the Polygon.
	**/
	public function area() {
		var sum = 0.;
		var p1 = points[points.length - 1];
		for( p2 in points ) {
			sum += p2.x * p1.y - p1.x * p2.y;
			p1 = p2;
		}
		return Math.abs(sum) * 0.5;
	}

	/**
		Calculates a centroid of the Polygon and returns its position.
	**/
	public function centroid() {
		var A = 0.;
		var cx = 0.;
		var cy = 0.;

		var p0 = points[points.length - 1];
		for(p in points) {
			var a = p0.x * p.y - p.x * p0.y;
			cx += (p0.x + p.x) * a;
			cy += (p0.y + p.y) * a;
			A += a;
			p0 = p;
		}

		A *= 0.5;
		cx *= 1 / (6 * A);
		cy *= 1 / (6 * A);

		return new h2d.Vector2(cx, cy);
	}

	inline function side( p1 : Point, p2 : Point, t : Point ) {
		return (p2.x - p1.x) * (t.y - p1.y) - (p2.y - p1.y) * (t.x - p1.x);
	}

	/**
		Tests if polygon is convex or concave.

		this should be in the init function
	**/
	public function isConvex() {
		if(points.length < 4) return true;
		var p1 = points[points.length - 2];
		var p2 = points[points.length - 1];
		var p3 = points[0];
		var s = side(p1, p2, p3) > 0;
		for( i in 1...points.length ) {
			p1 = p2;
			p2 = p3;
			p3 = points[i];
			if( side(p1, p2, p3) > 0 != s )
				return false;
		}
		return true;
	}

	/**
		Reverses the Polygon points ordering. Can be used to change polygon from anti-clockwise to clockwise.
	**/
	public function reverse() : Void {
		this.reverse();
	}

	//point was replaced by vector2 and stuff is just tangled here
	// /**
	// 	Transforms Polygon points by the provided matrix.
	// **/
	// public function transform(mat: h2d.col.Matrix) {
	// 	for( i in 0...points.length ) {
	// 		points[i].transform(mat);
	// 	}
	// }

	//matrix moved to h2d.matrix
	// /**
	// 	Returns a new transformed Polygon points by the provided matrix.
	// **/
	// public function transformed(mat: h2d.col.Matrix) {
	// 	var ret = points.copy();
	// 	for( i in 0...ret.length ) {
	// 		ret[i] = ret[i].transformed(mat);
	// 	}
	// 	return new Polygon(ret);
	// }

	//for some reason isConvex is done manually instead of automatically, if i'm writing a polygon by hand, how the fuck should i know its convex?
	/**
		Tests if Point `p` is inside this Polygon.
		@param p The point to test against.
		@param isConvex Use simplified collision test suited for convex polygons. Results are undefined if polygon is concave.
	**/
	@:noDebug
	public function containsPoint( p : Point, isConvex = false ):Bool {
		if( isConvex ) {
			var p1 = points[points.length - 1];
			for( p2 in points ) {
				if( side(p1, p2, p) < 0 )
					return false;
				p1 = p2;
			}
			return true;
		} else {
			var w = 0;
			var p1 = points[points.length - 1];
			for (p2 in points) {
				if (p2.y <= p.y) {
					if (p1.y > p.y && side(p2, p1, p) > 0)
						w++;
				}
				else if (p1.y <= p.y && side(p2, p1, p) < 0)
					w--;
				p1 = p2;
			}
			return w != 0;
		}
		return false;
	}

	//distanceSq is a vector2 thing but this relies on a point
	// /**
	// 	Returns closest Polygon vertex to Point `pt` within set maximum distance.
	// 	@param pt The point to test against.
	// 	@param maxDist Maximum distance vertex can be away from `pt` before it no longer considered close.
	// 	@returns A `Point` instance in the Polygon representing closest vertex (not the copy). `null` if no vertices were found near the `pt` within `maxDist`.
	// **/
	// public function findClosestPoint(pt : Point, maxDist : Float) {
	// 	var closest = null;
	// 	var minDist = maxDist * maxDist;
	// 	for(cp in points) {
	// 		var sqDist = cp.distanceSq(pt);
	// 		if(sqDist < minDist) {
	// 			closest = cp;
	// 			minDist = sqDist;
	// 		}
	// 	}
	// 	return closest;
	// }

	//asks for segments, segments are not finished, i don't know why it even asks for segments considering segments are something completely different
	// /**
	// 	Return the closest point on the edges of the polygon
	// 	@param pt The point to test against.
	// 	@param out Optional Point instance to which closest point is written. If not provided, returns new Point instance.
	// 	@returns A `Point` instance of the closest point on the edges of the polygon.
	// **/
	// public function projectPoint(pt: h2d.Vector2, ?out : h2d.Vector2) {
	// 	var p1 = points[points.length - 1];
	// 	var closest = new h2d.Vector2();
	// 	if (out == null) out = new h2d.Vector2();
	// 	var minDistSq = 1e10;
	// 	for(p2 in points) {
	// 		new Segment(p1, p2).project(pt, out);
	// 		var distSq = out.distanceSq(pt);
	// 		if (distSq < minDistSq) {
	// 			closest.load(out);
	// 			minDistSq = distSq;
	// 		}
	// 		p1 = p2;
	// 	}
	// 	out.load(closest);
	// 	return out;
	// }


	//uses segments for some reason
	// /**
	// 	Return the distance of `pt` to the closest edge.
	// 	If outside is `true`, only return a positive value if `pt` is outside the polygon, zero otherwise
	// 	If outside is `false`, only return a positive value if `pt` is inside the polygon, zero otherwise
	// **/
	// public function distance(pt : Point, ?outside : Bool) {
	// 	return Math.sqrt(distanceSq(pt, outside));
	// }

	// /**
	//  * Same as `distance` but returns the squared value
	//  */
	// public function distanceSq(pt : Point, ?outside : Bool) {
	// 	var p1 = points[points.length - 1];
	// 	var minDistSq = 1e10;
	// 	for(p2 in points) {
	// 		var s = new Segment(p1, p2);
	// 		if(outside == null || s.side(pt) < 0 == outside) {
	// 			var dist = s.distanceSq(pt);
	// 			if(dist < minDistSq)
	// 				minDistSq = dist;
	// 		}
	// 		p1 = p2;
	// 	}
	// 	return minDistSq == 1e10 ? 0. : minDistSq;
	// }

	//unfinished
	// public function rayIntersection( r : h2d.col.Ray, bestMatch : Bool, ?oriented = false ) : Float {
	// 	var dmin = -1.;
	// 	var p0 = points[points.length - 1];

	// 	for(p in points) {
	// 		if(r.side(p0) * r.side(p) > 0) {
	// 			p0 = p;
	// 			continue;
	// 		}

	// 		var u = ( r.lx * (p0.y - r.py) - r.ly * (p0.x - r.px) ) / ( r.ly * (p.x - p0.x) - r.lx * (p.y - p0.y) );
	// 		var x = p0.x + u * (p.x - p0.x);
	// 		var y = p0.y + u * (p.y - p0.y);
	// 		var v = new h2d.Vector2(x - r.px, y - r.py);

	// 		if(!oriented || r.getDir().dot(v) > 0) {
	// 			var d = Math.distanceSq(v.x, v.y);
	// 			if(d < dmin || dmin < 0) {
	// 				if( !bestMatch ) return Math.sqrt(d);
	// 					dmin = d;
	// 			}
	// 		}
	// 		p0 = p;
	// 	}

	// 	return dmin < 0 ? dmin : Math.sqrt(dmin);
	// }

	// find orientation of ordered triplet (p, q, r).
	// 0 --> p, q and r are colinear
	// 1 --> Clockwise
	// 2 --> Counterclockwise
	inline function orientation(p : Point, q : Point, r : Point) {
		var v = side(p, q, r);
		if (v == 0)	return 0;  		// colinear
		return v > 0 ? 1 : -1; 	// clock or counterclock wise
	}

	/**
		p, q, r : must be colinear points!
		checks if 'r' lies on segment 'pq'
	**/
	inline function onSegment(p : Point, q : Point, r : Point) {
		if(r.x > Math.max(p.x, q.x)) return false;
		if(r.x < Math.min(p.x, q.x)) return false;
		if(r.y > Math.max(p.y, q.y)) return false;
		if(r.y < Math.min(p.y, q.y)) return false;
		return true;
	}

	/**
		check if segment 'p1q1' and 'p2q2' intersect.
	**/
	function intersect(p1 : Point, q1 : Point, p2 : Point, q2 : Point) {
		var s1 = orientation(p1, q1, p2);
		var s2 = orientation(p1, q1, q2);
		var s3 = orientation(p2, q2, p1);
		var s4 = orientation(p2, q2, q1);

		if (s1 != s2 && s3 != s4) return true;

		if((s1 == 0 && onSegment(p1, q1, p2))
		|| (s2 == 0 && onSegment(p1, q1, q2))
		|| (s3 == 0 && onSegment(p2, q2, p1))
		|| (s4 == 0 && onSegment(p2, q2, q1)))
			return true;

		return false;
	}

	/**
		get intersection point between ab and cd
	**/
	function getIntersectionPoint(a : Point, b : Point, c : Point, d : Point) : h2d.Vector2 {
		if (!intersect(a, b, c, d))
			return null;

		var a1 = b.y - a.y;
   	 	var b1 = a.x - b.x;
   	 	var c1 = a1 * a.x + b1 * a.y;

		var a2 = d.y - c.y;
		var b2 = c.x - d.x;
		var c2 = a2 * c.x + b2 * c.y;

		var determinant = a1 * b2 - a2 * b1;
		if (determinant == 0)
			return null;

		var x = (b2 * c1 - b1 * c2) / determinant;
        var y = (a1 * c2 - a2 * c1) / determinant;
        return new h2d.Vector2(x, y);
	}

	/**
		Check if polygon self-intersect
	**/
	public function selfIntersecting() {
		if(points.length < 4) return false;

		for(i in 0...points.length - 2) {
			var p1 = points[i];
			var q1 = points[i+1];
			for(j in i+2...points.length) {
				var p2 = points[j];
				var q2 = points[(j+1) % points.length];
				if(q2 != p1 && intersect(p1, q1, p2, q2))
					return true;
			}
		}

		return false;
	}

	/**
		think of this like in blender how you can auto merge verticies by distance, or at least i think this is what this does	

		Creates a new optimized polygon by eliminating almost colinear edges according to epsilon distance.
	**/
	public function optimize( epsilon : Float ) : Polygon {
		var out = [];
		optimizeRec(points, 0, points.length - 1, out, epsilon);
		return new Polygon(this.parent, out);
	}

	static function optimizeRec( points : Array<Point>, start : Int, end : Int, out : Array<h2d.Vector2>, epsilon : Float ) {
		var dmax = 0.;

		inline function distPointSeg(p0:Point, p1:Point, p2:Point) {
			var A = p0.x - p1.x;
			var B = p0.y - p1.y;
			var C = p2.x - p1.x;
			var D = p2.y - p1.y;

			var dot = A * C + B * D;
			var dist = C * C + D * D;
			var param = -1.;
			if (dist != 0)
			  param = dot / dist;

			var xx, yy;

			if (param < 0) {
				xx = p1.x;
				yy = p1.y;
			}
			else if (param > 1) {
				xx = p2.x;
				yy = p2.y;
			}
			else {
				xx = p1.x + param * C;
				yy = p1.y + param * D;
			}

			var dx = p0.x - xx;
			var dy = p0.y - yy;
			return dx * dx + dy * dy;
		}

		var pfirst = points[start];
		var plast = points[end];
		var index = 0;
		for( i in start + 1...end ) {
			var d = distPointSeg(points[i], pfirst, plast);
			if(d > dmax) {
				index = i;
				dmax = d;
			}
		}

		if( dmax >= epsilon * epsilon ) {
			optimizeRec(points, start, index, out, epsilon);
			out.pop();
			optimizeRec(points, index, end, out, epsilon);
		} else {
			out.push(new h2d.Vector2(points[start].x,points[start].y));
			out.push(new h2d.Vector2(points[end].x,points[end].y));
		}
	}

	/**
	 * makes a circle?, was likely just made as a test to see if a circle can be created from pure polygons
	 * @param x 
	 * @param y 
	 * @param radius 
	 * @param npoints = 0 
	 */
	public static function makeCircle(parent:h2d.Object, x : Float, y : Float, radius : Float, npoints = 0 ) {
		if( npoints == 0 )
			npoints = Math.ceil(Math.abs(radius * 3.14 * 2 / 4));
		if( npoints < 3 ) npoints = 3;
		var angle = Math.PI * 2 / npoints;
		var points = [];
		for( i in 0...npoints ) {
			var a = i * angle;
			points.push(new h2d.Vector2(Math.cos(a) * radius + x, Math.sin(a) * radius + y));
		}
		return new Polygon(parent.parent,points);
	}


	//=-COLLISION CHECKS-=\\

	public function polyPoint(p:h2d.Vector2):Bool{
		var collision = false;

		var next:Int = 0;

		for (v in 0...points.length){
			var next:Int = v+1;
			if (next == points.length) next = 0;
			var vc = new h2d.Vector2(points[v].absX, points[v].absY); //current
			var vn = new h2d.Vector2(points[next].absX, points[next].absY); //next

			//this if statement is diabolical, but hey that's the kind of code expected from reading tutorials
			//a case of usability over readability, because good lord.
			if (((vc.y >= p.y && vn.y < p.y) || (vc.y < p.y && vn.y >= p.y)) && (p.x < (vn.x-vc.x)*(p.y-vc.y) / (vn.y-vc.y)+vc.x)){
				collision = !collision;
			}
		}

		return collision;

	}

	public function polyCircle(c:Circle):Bool{
		var next:Int = 0;

		for (v in 0...points.length){
			var next:Int = v+1;
			if (next == points.length) next = 0;
			var vc = new h2d.Vector2(points[v].absX, points[v].absY);
			var vn = new h2d.Vector2(points[next].absX, points[next].absY);
			if (Common.lineCircle(vc,vn,c.toVector3())) return true;
		}

		if (polyPoint(new h2d.Vector2(c.absX,c.absY))) return true;
		
		return false;
	}

	public function polySquare(s:Square):Bool{
		var next:Int = 0;

		for (v in 0...points.length){
			var next:Int = v+1;
			if (next == points.length) next = 0;
			var vc = new h2d.Vector2(points[v].absX, points[v].absY);
			var vn = new h2d.Vector2(points[next].absX, points[next].absY);
			if (Common.lineSquare(vc,vn, s.toVector4())) return true;
		}

		if (polyPoint(new h2d.Vector2(s.x,s.y))) return true;
		
		return false;
	}

	public function polyLine(l:Line):Bool{

		if (polyPoint(l.p1.toVector2()) || polyPoint(l.p2.toVector2())  ) return true;

		var next:Int = 0;
		for (v in 0...points.length){
			var next:Int = v+1;
			if (next == points.length) next = 0;
			var vc = new h2d.Vector2(points[v].absX, points[v].absY);
			var vn = new h2d.Vector2(points[next].absX, points[next].absY);

			if (Common.lineLine(new h2d.Vector2(l.p1.absX, l.p1.absY),new h2d.Vector2(l.p2.absX,l.p2.absY),vc,vn)) return true;
		}
		
		return false;
	}

	public function polyPoly(p:Polygon):Bool{
		var next:Int = 0;
		for (v in 0...points.length){
			var next:Int = v+1;
			if (next == points.length) next = 0;
			var vc = new h2d.Vector2(points[v].absX, points[v].absY);
			var vn = new h2d.Vector2(points[next].absX, points[next].absY);

			////at some point the philosophy of how collision is done here has changed, this is a remnant i couldn't be assed to change it right now
			////i have game jam to participate in
			//time to do something incredibly stupid, because i can't use the functions above this,
			//simply due to the fact that they're designed to be as easy to use as possible,
			//the second i touch them, they stop being easy to use
			//so i have to remake them in here

			function polyPolyLine():Bool{
				var next:Int = 0;
				for (v in 0...p.points.length){
					var next:Int = v+1;
					if (next == p.points.length) next = 0;
					var vc2 = new h2d.Vector2(p.points[v].absX, p.points[v].absY);
					var vn2 = new h2d.Vector2(p.points[next].absX, p.points[next].absY);

					if (Common.lineLine(vc2,vn2,vc,vn)) return true;
				}
				return false;
			}
			if (polyPolyLine() ) return true;
			//trace(p.polyPoint(new h2d.Vector2(points[0].absX, points[0].absY)));
			//this is probably not even being read
			//weird, its like its not even being read
			if (polyPoint(new h2d.Vector2(p.points[0].absX, p.points[0].absY))) return true;
		}
		return false;
	}


	override function collision(target:Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return polyPoint(point.toVector2());
            case Circle:
                var circle = cast(target,Circle);
                return polyCircle(circle);
            case Square:
                var square = cast(target,Square);
                return polySquare(square);
            case Line:
                var line = cast(target, Line);
                return polyLine(line);
            case Polygon:
                var polygon = cast(target, Polygon);
                return polyPoly(polygon);
        }
        return false;
    }

	public override function collisionDraw(){
        super.collisionDraw();
        debugDraw.beginFill(0xff6cc2e4, 0.5);
		for (p in points){debugDraw.lineTo(p.absX,p.absY);} //this just works, i expected to debug this for a couple of hours
		//though i have noticed some internal functions use addvertex instead, needs to be investigated
		debugDraw.endFill();
    };

}
