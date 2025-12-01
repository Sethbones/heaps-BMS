package h2d;
//=-UNFINISHED-=\\
//will probably be removed next version, as A. i don't think this is a good idea and B. its currently much easier to just call the shape itself
/**
 * a component macro class that acts as `h2d.Prim` + `h2d.col.Collider` that is meant to be attached to another object that acts as its collision
*/
class Collision extends Object {

    /**the collision shape*/
    public var colShape:h2d.col.NeoCollider;

    //for debug display, will make sense when the compiler argument -D gets implemented
    private var primShape:h2d.Graphics;

    /**
     * @param parent the parent for the collision to follow
     * @param shape the collision shape to use
     * @param x the x offset to spawn it in
     * @param y the y offset to spawn it in
     */
    override public function new(parent:h2d.Object, shape:h2d.col.Collider, ?x:Int = 0, ?y:Int = 0){
        super(parent);
        colShape = shape;
    }


    override function init(){
        //i despise this being self contained like this, why not just h2d.prim.circle?, and keep h2d.prim to containerize all of them?
        primShape = new h2d.Graphics(this);
        primShape.beginFill(0x9c62afee,0.65);
        primShape.drawCircle(8,8,16);
    }

    override function update() {
        //colShape.x = parent.x;
        //colShape.y = parent.y;
        //trace(colShape.x,colShape.y);
    }


}