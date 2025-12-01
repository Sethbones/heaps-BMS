package h2d;

/**
    JSON variable explanation:

    "tile_resolution": [Int,Int] default: [null,null] // each animation tile's resolution
    "default_offset" : [Int,Int] default: [null,null] // the draw offset of the sprite
    "animations": [
        {
            "name": `String`                 default: null                   // an optional identifier for the current animation, makes it easier to find when making changes
            "resolution_override": [Int,Int] default: null                   // optional override for the current animation's resolution
            "offset_override": [Int,Int]     default: null                   // optional override for the current sprite's draw offset 
            "frame_step":[Int,Int]           default: [tile_resolution[0],0] // optional override for how far the next tile is from the current one
            "frames": [Int,...]              default: [100]                  // how many individual images does the current animation have, and their duration in milliseconds 
            "loop": `Bool`                   default: false                  // should the animation loop?
            "next_state": `Int`              default: 0                      // the state to go to after the animation ends if it doesn't loop 
            "script": [String,...]           default: [null]#requires hscript// the hscript code to execute when the current animation frame is reached, corrosponding to frames
        }
    ]
*/



/**
 * now, heaps has its own animation system... and i don't like it very much, its intentionally very limited and is better suited for iteration.
 * 
 * however i needed an animation system that i can just: drop a spritesheet on top of an object and not think about it too hard.
 * 
 * with that said:
 * 
 * BMS animation system, a flexible animation system that is designed for ease of creation and readability while maintaining flexibility
 * 
 * basically a state machine as an animation system, the old animation system is still there for simpler things like projectiles under `h2d.BasicAnim`
 */
class Anim extends Drawable{//do not attempt to use this as a base for an object, as it relies on being parented to another object

    /**
     * the location to add when going to the next frame, is technically a vector but vectors are not a thing in JSON
     */
    var currentFrameStep:Array<Int> = null;

    /**
     * the current animation frame displayed
    */
    var currentFrame:Int = 0;
    /**
     * the static version of the current animation frame displayed
    */
    var currentNumberofFrames:Int = 0;
    /**
     * time between frames
    */
    var frameTime = 100; //gets overwritten almost immediately
    /**
     * static version of the time between frames
    */
    var timeTillAnimationEnd:Float; //= frameTime at start
    /**
     * handles animation looping
    */
    var animShouldLoop:Bool = false;
    /**
     * the current state in use given from the json's "animations" array
    */
    var currentState:Int = 0;
    /**
     * stores the last used state
    */
    var previousState:Int;
    /**
     * the animation properties file assigned by the constructor.
    */
    var animJSON:Dynamic;

    /**
     * the spritesheet to animate
     */
    var spritesheet:h2d.Bitmap;

    // hscript's nonsense
    var hparser:hscript.Parser;
    var hinterp:hscript.Interp;


    override function update(){
        if (previousState != currentState){
            previousState = currentState;
            animSwitch();
        }

        var animationTimer = hxd.Timer.dt * 1000;

        //=-ANIMATION LOGIC-=\\
        if (animJSON.animations[currentState].frames != null){//when its not empty
            if (timeTillAnimationEnd >= 0){
                timeTillAnimationEnd -= animationTimer;
            }
            else{
                if (currentFrame == currentNumberofFrames){
                    if (animShouldLoop){
                        currentFrame = 0;
                        timeTillAnimationEnd = (animJSON.animations[currentState].frames[currentFrame]:Int ) ;  //the first time in my life i have ever seen "haxe error:Can't cast hl.types.ArrayDyn to hl.types.ArrayBytes..."
                        //=-SCRIPT CONTROLS-=\\
                        #if hscript
                        if (hparser != null && hinterp != null){
                            if (animJSON.animations[currentState].script != null){//when its empty
                                if (animJSON.animations[currentState].script[currentFrame] != null){
                                    hinterp.execute(hparser.parseString(animJSON.animations[currentState].script[currentFrame]));
                                }
                            }
                        }
                        #end
                    }
                    else{
                        currentState = animJSON.animations[currentState].next_state;
                        animSwitch(); //band aid solution for now
                    }
                    
                }
                else {
                    currentFrame += 1;
                    timeTillAnimationEnd = (animJSON.animations[currentState].frames[currentFrame]:Int);
                    //=-SCRIPT CONTROLS-=\\
                    #if hscript
                    if (hparser != null && hinterp != null){
                        if (animJSON.animations[currentState].script != null){//when its empty
                            if (animJSON.animations[currentState].script[currentFrame] != null){
                                hinterp.execute(hparser.parseString(animJSON.animations[currentState].script[currentFrame]));
                            }
                        }
                    }
                    #end

                }

            }
            spritesheet.tile.setPosition(currentFrame * currentFrameStep[0], (currentFrame * currentFrameStep[1]) + (animJSON.tile_resolution[1] * currentState) );            
        }
    }

    /**
     * the logic to switch between animations
     */
    function animSwitch(){

        //=-resolution_override-=\\
        if (animJSON.animations[0].resolution_override == null){//when its empty
            spritesheet.tile.setSize(animJSON.tile_resolution[0], animJSON.tile_resolution[1]);
        }
        else{//when its not empty
            spritesheet.tile.setSize(animJSON.animations[currentState].resolution_override[0], animJSON.animations[currentState].resolution_override[1]);
        }

        //=-offset_override-=\\
        if (animJSON.animations[0].offset_override == null){//when its empty
            spritesheet.setPosition(-animJSON.default_offset[0], -animJSON.default_offset[1]);
        }
        else{//when its not empty
            spritesheet.setPosition(-animJSON.animations[currentState].offset_override[0], -animJSON.animations[currentState].offset_override[1]);
        }

        //=-frame_step-=\\
        currentFrameStep = animJSON.animations[currentState].frame_step ?? [animJSON.tile_resolution[0],0];

        //=-frames-=\\
        currentNumberofFrames = Std.int(animJSON.animations[currentState].frames.length - 1) ?? 0; //note to self, in JSON 1 is still a float, which could probably be a haxe bug, but i don't if JSON can do "1."
        currentFrame = 0;
        frameTime = animJSON.animations[currentState].frames[currentFrame] ?? 100;
        timeTillAnimationEnd = frameTime;

        //=-loop-=\\
        animShouldLoop = animJSON.animations[currentState].loop ?? false;

        //=-script-=\\
        #if hscript
        if (hparser != null && hinterp != null){
            if (animJSON.animations[currentState].script != null){//when its empty
                if (animJSON.animations[currentState].script[currentFrame] != null){
                    hinterp.execute(hparser.parseString(animJSON.animations[currentState].script[currentFrame]));
                }
            }
        }
        #end

    }


    //=-PUBLIC HELPER FUNCTIONS-=\\
    /**
     * gets the current state in use
     */
    public function getCurrentState():Int {
        return currentState;
    }

    /**
     * forcefullly change the state
     */
    public function setCurrentState(state:Int) {
        currentState = state;
    }

    /**
     * get the state's name for easier identification
     */
    public function getCurrentStateName():String{
        return ("animation: " + animJSON.animations[currentState].name + " | state number: " + currentState);
    }


    //=-CONSTRUCTOR-=\\
    /**
     * to get an idea for how to use, check the samples 
     * @param parent the object on which to animate
     * @param animationJSON the JSON animation config file
     * @param sheet the spritesheet to manipulate for animating
     * @param hscriptparser the barely documented parser for hscript from string to expression taken from the parent object
     * @param hscriptinterpreter the barely documented interpreter for hscript from expression to actual use taken from the parent object
     */
    public override function new(parent:h2d.Object, animationJSON: String, sheet: h2d.Bitmap, ?hscriptparser: hscript.Parser, ?hscriptinterpreter: hscript.Interp){
        super(parent);
        animJSON = haxe.Json.parse(animationJSON);
        spritesheet = sheet;
        animSwitch();
        hparser = hscriptparser ?? null;
        hinterp = hscriptinterpreter ?? null;
        //side tangent: why does hscript need parser and interpreter on two different classes?, they're both required to be used together anyways.
        //it's like its a component with components instead of a drop in component with optional addons.
        //modularity my ass, when the core of a modular library requires the use of multiple parts in order to function:
        //it stops being modular and starts becoming a nuisance (or ECS).
        //parser does nothing on its own and requires interpreter to function
        //interpreter does nothing on its own as it requires an expr that are given from parser
    }
}