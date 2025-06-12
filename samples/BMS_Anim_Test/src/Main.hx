class Main extends hxd.App {

    public static var app : Main; //mainly to access to manipulate from outside
    
    public var animcontrol:h2d.Anim;

    override function init() {
        //create the player
        var player = new h2d.Object();
        s2d.add(player);
        //add the animation system to the player
        animcontrol = new h2d.Anim(player, hxd.Res.anim.entry.getText(), new h2d.Bitmap(hxd.Res.animsheet.toTile(), player));
        //move the player to the middle of the screen
        player.x = s2d.width/2;
        player.y = s2d.height/1.5;
        //scale the player, not the animation system
        player.scale(10);
    }


    // on each frame
    override function update(dt:Float) {
        //will not be needed soon as updates to objects will be done by the scene, but its here for now because i'm still porting stuff
        animcontrol?.update(); //if its not null, update.
    }

    static function main() {
        hxd.Res.initEmbed();
        app = new Main();
    }
}