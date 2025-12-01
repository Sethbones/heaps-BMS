package h2d.col;

/**
 * 
 * Quick and Cheap fixed Square collider
 * 
 * can't rotate, but is much faster and simpler than `h2d.col.NeoPolyRect`
 * 
 * meant to be used if performance is a key factor or if you need a square that doesn't rotate
 * 
 */
class Square extends Collider{

    /**
     * width of the square
     */
    public var width:Float;
    /**
     * height of the square
     */
    public var height:Float;

	/**
	 * wow, they have it, S Q U A R E.
	 * @param parent 
	 * @param x 
	 * @param y
	 * @param w width of the square
	 * @param h height of the square
	 */
	public override function new(?parent:h2d.Object, x : Float, y : Float, w:Float, h:Float) {
        this.width = w;
        this.height = h;
        super(parent);
        this.x = x;
		this.y = y;
	}


	override function collision(target:Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return Common.pointSquare(point.toVector2(), this.toVector4());
            case Circle:
                var circle = cast(target,Circle);
                return Common.circleSquare(this.toVector4(), circle.toVector3());
            case Square:
                var square = cast(target,Square);
                return Common.squareSquare(this.toVector4(), square.toVector4());
            case Line:
                var line = cast(target, Line);
                return Common.lineSquare(line.p1.toVector2(),line.p2.toVector2(), this.toVector4());
            case Polygon:
                var polygon = cast(target, Polygon);
                return polygon.polySquare(this);
        }
        return false;
    }


    public override function collisionDraw(){
        super.collisionDraw();
        debugDraw.beginFill(0xff6cc2e4, 0.5);
        debugDraw.drawRect(0,0,width,height); //theoratically i could put this into the draw loop. if i knew how it worked that is, i think it needs something else
    };

    //really only used to simplify collision checks
    public function toVector4(){
        return new h3d.Vector4(absX,absY,width,height);
    }
    
}