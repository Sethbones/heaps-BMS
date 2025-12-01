package h2d.col.old;

/**
 * an integer based point coordinates on the screen for IObject
 * 
 * scrapped for now, with the problem being that objects in the engine are almost entirely designed around being float based.
 * and that basically means there needs to be an IObject to support it
 * 
 * well that's not entirely true, workarounds can be made, however the second a workaround is made this stops being an integer based point
 * and just becomes a float based point with rounding to the nearest whole pixel
 * 
 * that explains why collision was its own thing completely seperated from the rest of the engine
 * to "fake" flexibility, which is smart, however not convinient in the slightest to work with
 * 
 * might come back to this eventually
 * 
*/
class NeoIPoint extends NeoCollider{

    //yes this is stupid, but what else am i supposed to do?
    //rounding the float could still result float point errors
    //public var x:Int = 0;
    //public var y:Int = 0;
    //yes this is stupid but i'm trying to avoid float point shenanigans. but you might say, just use a unique class and i say, no.
    public var ix:Int = 0;
    public var iy:Int = 0;

    //issue number one, how do i move these coordinates with the parent object
    /**
		Create new Point collider.
        @param x X position of the Circle center relative to the given parent.
        @param y Y position of the Circle center relative to the given parent.
        @param action action:Void->Void, optional continuous collision check, checks for all objects around itself
	**/
	public override function new(?parent:h2d.Object, x : Int, y : Int) {
		this.x = x;
		this.y = y;
        super(parent);
	}

    //this technically works but its not efficient
    override function update() {
        if (ix != Math.round(x)) {ix = Math.round(x);};
        if (iy != Math.round(y)) {iy = Math.round(y);};
    }

    override function collision(target:h2d.col.NeoCollider) : Bool{
        switch Type.getClass(target){
            case NeoPoint:
                if (target.x == this.x && target.y == this.y){
                    trace("scripulous fingore");
                    return true;
                }
            //case NeoIPoint
            case NeoCircle:
                //i'm gonna have to do casting for these ones
                var circle = cast(target,h2d.col.NeoCircle);
                //return circle.containsPoint(this);
            
            case NeoRectangle:
                var rectangle = cast(target,NeoRectangle);
                //return rectangle.rectPointCollide(this);
            //case NeoIRectangle
            //case NeoBounds
            //case NeoCapsule
            //case NeoPolygonCollider
            //case NeoIPolygonCollider
            //case Segment
            //case NeoLine
            //case NeoILine
            //case NeoRaycast
            //case NeoTriangle //will likely get axed, if you must have a triangle, just use polygons
            //case something else i don't know about
        }
        return false;
    }

    //this would be a good time to use the draw function
    public override function collisionDraw(){
        trace("enabling debug hitbox draw");
        var debugDraw = new h2d.Graphics(this);
        debugDraw.beginFill(0xff6cc2e4, 0.5);
        //this is going to be very tiny, but its literally a point on the screen. its not a shape, its coordinates
        //just as a notice, points get more useful the smaller the resolution, hence the (frankly excessive) use on older
        debugDraw.drawRect(this.x - 1,this.y - 1,2,2); //should be middle enough, should always be half of width and half of height
        //this or may or may not be very stupid
    };
}