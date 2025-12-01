package h2d.col;

import h3d.Vector4;

/**
 * a common class that includes generic functions for collision checking
 * 
 * an attempt to detangle the colliders to keep them unique while leaving the general functions here
*/
class Common {
    /**
     * collision between 2 vector coordinates
     * @param p1 the first point usually with point.toVector2()
     * @param p2 the second point usually with point.toVector2()
     * @param Buffer an optional detectionf buffer, useful to prevent situations where the numbers needed are completely skipped over because of delta
     */
    public static function pointPoint(p1:Vector2, p2:Vector2, Buffer:Float = 0):Bool {
        //TODO: Implement Buffer
        return p1.x == p2.x && p1.y == p2.y;
    }

    /**
     * collision between 2 lines and their 2 points
     * @param a1 the first line's first point usually with line.p1.toVector2()
     * @param a2 the first line's second point usually with line.p2.toVector2()
     * @param b1 the second line's first point usually with line.p1.toVector2()
     * @param b2 the second line's second point usually with line.p2.toVector2()
     * @param buffer required otherwise diagonal lines won't work
     */
    public static function lineLine(a1:Vector2, a2:Vector2, b1:Vector2, b2:Vector2, buffer:Float = 0.1):Bool{
        //edge case testing
        if (linePoint(a1,a2,b1) || linePoint(a1,a2,b2) ) return true;

        var iA = ( (b2.x-b1.x)*(a1.y-b1.y)-(b2.y-b1.y)*(a1.x-b1.x) )/( (b2.y-b1.y)*(a2.x-a1.x)-(b2.x-b1.x)*(a2.y-a1.y) );
        var iB = ( (a2.x-a1.x)*(a1.y-b1.y)-(a2.y-a1.y)*(a1.x-b1.x) )/( (b2.y-b1.y)*(a2.x-a1.x)-(b2.x-b1.x)*(a2.y-a1.y) );

        if (iA >= 0 && iA <= 1 && iB >= 0 && iB <= 1){return true;};

        return false;
    }

    /**
     * collision between 2 circles and their radius
     * @param c1 the first circle's coordinates
     * @param c1r the first circle's radius
     * @param c2 the second circle's coordinates
     * @param c2r the second circle's radius
     */
    public static function circleCircle(c1:h3d.Vector, c2:h3d.Vector):Bool{
		//this should change to Vector3 once h3d.Vector is properly renamed to h3d.Vector3
		var dx = c1.x - c2.x;
		var dy = c1.y - c2.y;
		return dx * dx + dy * dy < (c1.z + c2.z) * (c1.z + c2.z);
	}

    /**
     * collision between two squares simplified to using vector4
     * @param s1 first square's coordinates, usually with square.toVector4()
     * @param s2 second square's coordinates, usually with square.toVector4() 
     */
    public static function squareSquare(s1:Vector4, s2:Vector4):Bool{
        //i'm starting to think this was a bad idea
        //z = width
        //w = height
        return s1.x + s1.z >= s2.x && s1.x <= s2.x + s2.z && s1.y + s1.w >= s2.y && s1.y <= s2.y + s2.w;
        //return this.x + this.width >= r.x && this.x <= r.x + r.width && this.y + this.height >= r.y && this.y <= r.y + r.height;
    }

    /**
     * collision between a line and a point
     * @param l1 the line's first point's coordinates
     * @param l2 the line's second point's coordinates
     * @param p the point to collide with's coordinates
     * @param buffer required otherwise diagonal lines won't work
     */
    public static function linePoint(l1:Vector2, l2:Vector2, p:Vector2, buffer:Float = 0.1):Bool{
		//distance from point to both sides of the line
		var dx = hxd.Math.distance(l1.x - p.x, l1.y - p.y);
		var dy = hxd.Math.distance(l2.x - p.x, l2.y - p.y);
		var line = hxd.Math.distance(l2.x - l1.x, l2.y - l1.y);	//the length of the line
		return (dx+dy >= line-buffer && dx+dy <= line+buffer); //return true if the answer between them is the same, this is with no buffer cause i think buffers are stupid, just make a rectangle and rotate it 
	}

    /**
     * between circle and point
     * @param p the points x and y coordinates usually with point.toVector2()
     * @param c the circle's coordinates and radius usually with circle.toVector3()
     * @return Bool
     */
    public static function circlePoint(p:Vector2, c:h3d.Vector):Bool{
        return hxd.Math.distance(p.x - c.x, p.y - c.y) <= c.z;
    }

    //i gave up on writing descriptions

    public static function lineCircle(l1:Vector2, l2:Vector2, c:h3d.Vector):Bool{
        //this could definitely be improved, but not right now
		if (circlePoint(l1, c) || circlePoint(l2, c) ) {return true;};

		var line = hxd.Math.distance(l1.x - l2.x, l1.y - l2.y);
		var dot = ( ((c.x - l1.x)*(l2.x - l1.x)) + ( (c.y - l1.y)*(l2.y-l1.y)) ) / Math.pow(line, 2); //black magic

		var closestX = l1.x + (dot * (l2.x-l1.x) );
		var closestY = l1.y + (dot * (l2.y-l1.y) );

		if (!linePoint(l1,l2, new Vector2(closestX,closestY))){return false;};

		var distance = hxd.Math.distance(closestX - c.x, closestY - c.y);
		if (distance <= c.z){return true;};

		return false;
	}

    public static function pointSquare(p:Vector2, s:Vector4):Bool{
        //z = width
        //w = height
        return s.x + s.z >= p.x && s.x <= p.x && s.y + s.w >= p.y && s.y <= p.y;
    }

    public static function lineSquare(l1:Vector2, l2:Vector2, s:Vector4):Bool{
		//account for if the line is completely inside a square
		if (pointSquare(l1, s) || pointSquare(l2, s) ) return true;

        //behold, a mess, mostly because i have probably approached done this wrong
		var top = lineLine(l1,l2,new h2d.Vector2(s.x, s.y), new h2d.Vector2(s.x + s.z, s.y)); //this will start drawing extra lines, but its needed for collision
		var bottom = lineLine(l1,l2,new h2d.Vector2(s.x, s.y + s.w), new h2d.Vector2(s.x+s.z, s.y+s.w));
		var left = lineLine(l1,l2,new h2d.Vector2(s.x, s.y), new h2d.Vector2(s.x, s.y+s.w));
		var right = lineLine(l1,l2,new h2d.Vector2(s.x + s.z,s.y), new h2d.Vector2(s.x + s.z, s.y + s.w));
		return left || right || top || bottom;
	}

    public static function circleSquare(s:Vector4, c:h3d.Vector):Bool{
        //this is fine, but its kind of unreadable. but hey, its reusing code from bounds.
        if( c.x < s.x - c.z ) return false;
		if( c.x > (s.x + s.z) + c.z ) return false;
		if( c.y < s.y - c.z ) return false;
		if( c.y > (s.y + s.w) + c.z ) return false;
		if( c.x < s.x && c.y < s.y && hxd.Math.distanceSq(c.x - s.x, c.y - s.y) > c.z*c.z ) return false;
		if( c.x > (s.x + s.z) && c.y < s.y && hxd.Math.distanceSq(c.x - (s.x + s.z), c.y - s.y) > c.z*c.z ) return false;
		if( c.x < s.x && c.y > (s.y + s.w) && hxd.Math.distanceSq(c.x - s.x, c.y - (s.y + s.w)) > c.z*c.z ) return false;
		if( c.x > (s.x + s.z) && c.y > (s.y + s.w) && hxd.Math.distanceSq(c.x - (s.x + s.z), c.y - (s.y + s.w)) > c.z*c.z ) return false;
		return true;
    }
}