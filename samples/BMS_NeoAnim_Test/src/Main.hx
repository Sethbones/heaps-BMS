class Main extends hxd.App {

    public static var app : Main; //mainly to access to manipulate from outside
    
    private var animcontrol:h2d.Animatron;

    public var pointA:h2d.col.Collider;
    public var pointB:h2d.col.Collider;
    public var pointC:h2d.col.Line;
    public var pointD:h2d.col.Square;
    public var pointE:h2d.col.Circle;
    public var polygon:h2d.col.Polygon;
    public var polygon2:h2d.col.Polygon;
    public var elipse:h2d.Graphics;
    public var hparse:hscript.Parser;
    public var hinterp:hscript.Interp;

    var fpscounter:h2d.Text;

    override function init() {
        //create an object to act as the animation system's container
        //pointA = new h2d.col.Square(s2d,0,0,16,16);
        //pointB = new h2d.col.Square(s2d,50,50,16,16);
        // pointA.rotate(45);
        // pointA = new h2d.col.Line(s2d,new h2d.Vector2(50,100),new h2d.Vector2(250,300));
        //pointB = new h2d.col.Line(s2d,new h2d.Vector2(200,100),new h2d.Vector2(250,300));
        // pointD = new h2d.col.Square(s2d,0,0,16,16);
        // pointE = new h2d.col.Circle(s2d,100,100,16);
        // pointB = new h2d.col.Polygon(s2d, [
        //     new h2d.Vector2(20,10),
        //     new h2d.Vector2(40,10),
        //     new h2d.Vector2(35,30),
        //     new h2d.Vector2(25,30)
        // ]);
        // pointA = new h2d.col.Polygon(s2d, [
        //     new h2d.Vector2(350,100),
        //     new h2d.Vector2(250,100),
        //     new h2d.Vector2(200,400),
        //     new h2d.Vector2(500,400)
        // ]);
        // elipse = new h2d.Graphics(s2d);
        // elipse.beginFill(0xffffffff,0.5);
        // elipse.drawEllipse(50,100,16,24);//neat, still useless
        // elipse = null; //okay so that doesn't work
        // elipse.remove(); //but this does?
        // trace(polygon.points[0].parent);
        fpscounter = new h2d.Text(hxd.res.DefaultFont.get());
        fpscounter.textAlign = Center;
        fpscounter.x = 20;
        fpscounter.scale(2);
        s2d.add(fpscounter);
        var obj = new h2d.Object(s2d);
        hinterp = new hscript.Interp();
        hparse  = new hscript.Parser();
        s2d.add(obj);
        //add the animation system to the object
        animcontrol = new h2d.Animatron(obj, hxd.Res.animRework.entry.getText(), hparse, hinterp );
        //move the object to the middle of the screen
        obj.x = s2d.width/3;
        obj.y = s2d.height/4;
        //scale the object, not the animation system
        obj.scale(10);
        animcontrol.play(0, false, false, 250); //only starts rendering from frane 375, which is after 175,
        animcontrol.FPS = 60; //visual studio code really does not like this line for some reason
        animcontrol.timeScale = 1;
        // function test(){
        //     animcontrol.FPS = 60;
        // }
        //haxe.Timer.delay(test, 5000);
        //hxd.Window.getInstance();
        //hxd.Window.getInstance().vsync = false;
    }


    // on each frame
    override function update(dt:Float) {
        if (fpscounter != null){
            //fpscounter.text = Std.string( Std.int(hxd.Timer.fps()));

            fpscounter.text = Std.string( Std.int(animcontrol.currentDuration) );
            //trace(Std.int(hxd.Timer.fps()) );
        }
        if (hxd.Key.isPressed(hxd.Key.LSHIFT)){
            animcontrol.playLabel("beninging");
        }


        if (hxd.Key.isPressed(hxd.Key.TAB)){
            animcontrol.stop();
        }
        if (hxd.Key.isPressed(hxd.Key.ENTER)){
            animcontrol.unpause();
        }
        if (hxd.Key.isPressed(hxd.Key.BACKSPACE)){
            animcontrol.reset();
        }

        if (hxd.Key.isPressed(hxd.Key.UP)){
            animcontrol.timeScale += 1.0;
        }
        if (hxd.Key.isPressed(hxd.Key.DOWN)){
            if (animcontrol.timeScale <= 1.0){
                animcontrol.timeScale = 1.0;
            }
            else{
                animcontrol.timeScale -= 1.0;
            }
        }
        if (hxd.Key.isPressed(hxd.Key.LEFT)){
            if (animcontrol.timeScale <= 1.0){
                animcontrol.timeScale = 1.0;
            }
            else{
                animcontrol.timeScale -= 5.0;
            }
        }
        if (hxd.Key.isPressed(hxd.Key.RIGHT)){
            animcontrol.timeScale += 5.0;
        }
        //trace(hxd.Timer.fps());
        //testing testing, collision hell
        //pointA.collides(pointB);
        //trace(pointA.collides(pointB));
        //trace(pointD.rectCircle(pointE));
        //pointD.containsPoint(pointE);
        // trace(pointC.collides(pointB));
        // trace(pointC.collides(pointE));
        //trace(pointA.collides(pointB));
    }

    static function main() {
        hxd.Res.initEmbed();
        app = new Main();
    }
}