class Main extends hxd.App {

    public static var app : Main; //mainly to access to manipulate from outside
    
    public var animcontrol:h2d.Anim;

    override function init() {
        //create an object to act as the animation system's container
        var obj = new h2d.Object();
        s2d.add(obj);
        //add the animation system to the object
        animcontrol = new h2d.Anim(obj, hxd.Res.anim.entry.getText(), new h2d.Bitmap(hxd.Res.animsheet.toTile(), obj));
        //move the object to the middle of the screen
        obj.x = s2d.width/2;
        obj.y = s2d.height/1.5;
        //scale the object, not the animation system
        obj.scale(10);
    }


    // on each frame
    override function update(dt:Float) {}

    static function main() {
        hxd.Res.initEmbed();
        app = new Main();
    }
}