package h2d.col;

/**
 * 2D screen Coordinates as collision
 */
class Point extends Collider{

    /**
		Create new Point collider.
        @param x X position of the Circle center relative to the given parent.
        @param y Y position of the Circle center relative to the given parent.
        @param action action:Void->Void, optional continuous collision check, checks for all objects around itself
	**/
	public override function new(?parent:h2d.Object, x : Float, y : Float) {
        super(parent);
        this.x = x;
		this.y = y;
	}

    override function collision(target:Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return Common.pointPoint(this.toVector2(),point.toVector2());
            case Circle:
                var circle = cast(target,Circle);
                return Common.circlePoint(this.toVector2(), circle.toVector3());
            case Square:
                var square = cast(target,Square);
                return Common.pointSquare(this.toVector2(),square.toVector4());
            case Line:
                var line = cast(target, Line);
                return Common.linePoint(line.p1.toVector2(), line.p2.toVector2(), this.toVector2() );
            case Polygon:
                var polygon = cast(target, Polygon);
                return polygon.polyPoint(this.toVector2());
        }
        return false;
    }

    //this would be a good time to use the draw function
    public override function collisionDraw(){
        super.collisionDraw();
        debugDraw.beginFill(0xff6cc2e4, 0.5);
        //this is going to be very tiny, its literally a point on the screen. because its not a shape, its coordinates
        //just as a notice, points get more useful the smaller the resolution, hence the high use on older systems like the NES and SNES
        debugDraw.drawRect(0,0,1,1); //note: coordinates don't exactly have a middle so it's kind of impossible to properly visualize
    };

    public function toVector2(){
        return new h2d.Vector2(this.absX,this.absY);
    }
}