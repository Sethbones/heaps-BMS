package h2d.col;
//UNFINISHED
/**
 * a basic 4 point rectangle collider
 * 
 * basically a polygon collider just without the control and locked to a square's shape
 */
class Rectangle extends Collider{

    /**
     * width of the square
     */
    public var width:Float;
    /**
     * height of the square
     */
    public var height:Float;


    //makeshift polygon
    var p1:Point;//top left
    var p2:Point;//top right
    var p3:Point;//bottom left
    var p4:Point;//bottom right

	/**
	 * well they no longer have it, since this in a different store
	 * @param parent 
	 * @param x 
	 * @param y
	 * @param w width of the square
	 * @param h height of the square
	 */
	public override function new(?parent:h2d.Object, x : Float, y : Float, w:Float, h:Float) {
        super(parent);
        this.x = x;
		this.y = y;
        p1 = new Point(this,0,0);//top left
        p2 = new Point(this,w,0);//top right
        p3 = new Point(this,0,h);//bottom left
        p4 = new Point(this,w,h);//bottom right
	}


    override function collision(target:h2d.col.Collider) : Bool{
        switch Type.getClass(target){
            case Point:
                var point = cast(target,Point);
                return rectPoint(point);
            case Circle:
                throw "Not Implemented yet";
            case Square:
                var rectangle = cast(target,Square);
                return rectCollide(rectangle);
            //case Capsule
        }
        return false;
    }


    /**
     * from rect to point
    */
    public function rectPoint(p: Point):Bool{
        //this ugly
        //seperate into lines and run checks
        //p1->p2
        if (((p1.absY >= p.y && p2.absY < p.y) || (p1.absY < p.y && p2.absY >= p.y)) && (p.x < (p2.absX-p1.absX)*(p.y-p1.absY) / (p2.absY-p1.absY)+p1.absX)){
            return true;
        }
        //p2->p3
        if (((p2.absY >= p.y && p3.absY < p.y) || (p2.absY < p.y && p3.absY >= p.y)) && (p.x < (p3.absX-p2.absX)*(p.y-p2.absY) / (p3.absY-p2.absY)+p2.absX)){
            return true;
        }
        //p3->p4
        if (((p3.absY >= p.y && p4.absY < p.y) || (p3.absY < p.y && p4.absY >= p.y)) && (p.x < (p4.absX-p3.absX)*(p.y-p3.absY) / (p4.absY-p3.absY)+p3.absX)){
            return true;
        }
        //p4->p1
        if (((p4.absY >= p.y && p4.absY < p.y) || (p4.absY < p.y && p4.absY >= p.y)) && (p.x < (p4.absX-p1.absX)*(p.y-p4.absY) / (p4.absY-p4.absY)+p4.absX)){
            return true;
        }
        return false;
        //return this.x + this.width >= p.x && this.x <= p.x && this.y + this.height >= p.y && this.y <= p.y;
    }

    public function rectLine(l:Line):Bool{
        return false;
    }

    /**
     * from Polyrect to Polyrect
    */
    function rectCollide(r:Square):Bool{
        //so from understanding how collision works between polygons,
        //it straight up checks if one of the lines of a polygon is intersecting with one of the lines of the other polygon
        //here's me thinking there would be complex math for this but i guess not.
        return this.x + this.width >= r.x && this.x <= r.x + r.width && this.y + this.height >= r.y && this.y <= r.y + r.height;
        //return xmin + xmax >= r.x && xmin <= r.x + r.width && ymin + ymax >= r.y && ymin <= r.y + r.height;
    }


    public override function collisionDraw(){
        super.collisionDraw();
        debugDraw.beginFill(0xff6cc2e4, 0.5);
        debugDraw.drawRect(0,0,width,height);
    };

    /**
	 * generic collision between two lines
	*/
	function lineLine(a1:Point,a2:Point,b3:Point,b4:Point):Bool{
		var iA = ( (b4.x-b3.x)*(a1.y-b3.y)-(b4.y-b3.y)*(a1.x-b3.x) )/( (b4.y-b3.y)*(a2.x-a1.x)-(b4.x-b3.x)*(a2.y-a1.y) );
		var iB = ( (a2.x-a1.x)*(a1.y-b3.y)-(a2.y-a1.y)*(a1.x-b3.x) )/( (b4.y-b3.y)*(a2.x-a1.x)-(b4.x-b3.x)*(a2.y-a1.y) );

		if (iA >= 0 && iA <= 1 && iB >= 0 && iB <= 1){return true;};

		return false;
	}



    //=-HYPOTHETICAL-=\\

    /**
     * check if hitting the top 2 points at the same time
    */
    public function up(target:Collider):Bool{return false;};
    /**
     * check if hitting the bottom 2 points at the same time
    */
    public function down(target:Collider):Bool{return false;};
    /**
     * check if hitting the left 2 points at the same time
    */
    public function left(target:Collider):Bool{return false;};
    /**
     * check if hitting the right 2 points at the same time
    */
    public function right(target:Collider):Bool{return false;};
    /**
     * check if hitting one or both sides of the rectangle
    */
    public function side(target:Collider):Bool{return false;};
    
}