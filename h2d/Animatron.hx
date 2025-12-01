package h2d;
//project Animatron is not yet finished

//the animation system is being remade again, fun.
//this one is designed not to be intuitive to use, but to be as modular as possible to make it useful no matter the usecased

//the many typedefs are intended for a different strategy,
//to load the entire animation data to memory before iterating on it,
//should be faster if done correctly and should be faster than dynamically calling the JSON when needed

typedef AnimHeader = {
    var animations:Null<Array<Animation>>;
    var defaults:Null<Dynamic>; //default values that can be used for a bunch of things, by default only has defaultAtlas
}

/** * the animation itself */
typedef Animation = {
    /** * the duration of the current animation */
    var duration:Float;
    /** * the name of the current animation */
    var name:String;
    /** * the layers of the given animation */
    var layers:Array<Layer>;
    /** * the next state to move to after the animation finishes and if it doesn't loop, 
     * by default if assigned an invalid value (or just -1) it will loop the current animation, and if the value is null it or if the variable is not there it will not loop */
    var nextAnim:Null<Int>;
}
//=-GLOBALS-=\\
typedef DefaultDefaults = {var defaultAtlas:String;} //clever name i know
////====----BASIC-LAYERS-AND-ACTIONS----====\\\\
///===---LAYERS---===\\\
typedef Layer =          {var type:String; var keys:Array<Int>; var actions:Array<Action>;        var keyIndex:Int; } //really now that i think about it, there's really no reason for anything else, since casting is needed anyways
typedef ImageLayer =     {var type:String; var keys:Array<Int>; var actions:Array<ImageAction>;   var instance:h2d.Bitmap; var spriteAtlas:Null<String>;}//to get a bitmap from here you would need to use hxd.Res.load and point to your image starting from Res, then converting to tile and finally to bitmap
typedef CollisionLayer = {var type:String; var keys:Array<Int>; var actions:Array<ColAction>;     var instance:h2d.col.Collider;}
typedef ScriptLayer =    {var type:String; var keys:Array<Int>; var actions:Array<ScriptAction>;  var instance:Null<String>;} //generic script as string layer
//typedef LabelLayer =   {var type:String; var keys:Array<Int>; var actions:Array<LabelAction>;} //there's not really a reason for its existance, its not using anything special
///===---ACTIONS---===\\\
typedef Action = {var continuous:Bool;} //shared variables go here
//=-IMAGE-=\\
typedef ImageAction =  {var x:Float; var y:Float; var width:Float; var height:Float; var offsetX:Float; var offsetY:Float; var spriteAtlas:Null<String>; var alpha:Null<Int>;}
//=-LABEL-=\\
typedef LabelAction =  {var name:String;}
//=-HSCRIPT-=\\
typedef ScriptAction = {var script:String;} //generic script string action
typedef SignalAction = {var useParent:Bool; var func:String; var args:Array<Dynamic>;} //signals are a non hscript, Reflect powered alternative to call functions.
//=-COLLISION-=\
typedef ColAction =       {var triggered:Bool; var active:Bool; var type:String;}
typedef PointAction =     {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float;}
typedef LineAction =      {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float; var bx:Float; var by:Float;}
typedef SquareAction =    {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float; var w:Float; var h:Float;}
typedef CircleAction =    {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float; var radius:Float;}
typedef RectangleAction = {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float; var tl:Vector2; var tr:Vector2; var bl:Vector2; var br:Vector2;}
typedef PolygonAction =   {var triggered:Bool; var active:Bool; var type:String; var x:Float; var y:Float; var points:Array<Vector2>;}


/**
 * Animatron is an incredibly flexible animation system designed for precise tasks with a large focus on user control, 
 * turning what should be a timing nightmare scenario into a problem that can be solved.
 * 
 * it can run scripts at precise points
 * 
 * it can be used as a baseline for a state machine
 * 
 * it can be used to setup cutscenes and small and simple animations
 * 
 * it can manage visual effects through the code
 * 
 * it can make manage the frame timings of an animation to pinpoint precision
 * 
 * ========
 * 
 * /=-TEMPORARY TEXT-=\
 * 
 * yes i created another animation system
 * 
 * i can explain
 * 
 * i made the first animation system and was satisfied by how easy to use it is, until i actually went to use it.
 * 
 * and soon i realized i needed more precise control on various things
 * 
 * especially hitbox creation and scripts
 * 
 * i needed an animation system where i could fine tune every single piece to perfection, so that i'm not restricted on what point i run my scripts, collisions and general timings on,
 * allowing me to do more things without having to overcomplicate the script with random nonsense just to mimic the behavior i needed
 * 
 * the plan for the original animation system was to be as human readable as possible,
 * which caused several problems on the design stage and while it resulted in a less limited system than the heaps original but,
 * it was still limited in all places that mattered for my usecase
 * 
 * and so the plan for the new animation system is to be as flexible as possible, throwing readiblity to the side for the sake of finer control
 * 
 * that and the original animation system's code is horrible,
 * i was originally going to build this on top of the old one,
 * but at some point i realized how badly written it was and wrote this one from scratch, it lagged to hell and back if 3 objects used it at the same time
 */
class Animatron extends Layers {//used to extend drawable but that has since been moved to layers because of layer control
    //=-GENERAL-=\\
    /**
     * the animation file to animate
     */
    var animationfile:AnimHeader = {animations: [], defaults: null};
    /**
     * the sprite atlas/sheet to manipulate
     */
    var spriteAtlas:h2d.Bitmap; //this may cause issues, because you might not have all images in one place every time, because while a sprite atlas is ideal, its not always with everyone does
    //but that's a problem for later me not today me.
    
    //=-HSCRIPT-=\\
    #if hscript
    /**
     * the optional parser for hscript
     */
    var hparser:hscript.Parser;
    /**
     * the optional interpeter for hscript
     */
    var hinterp:hscript.Interp;
    #end


    //=-ANIMATION-VARIABLES-=\\
    /**
     * the current duration that's counted up to `AnimDuration`
    */
    public var currentDuration:Float = 0; //should be called currentFrame honestly
    /**
     * the global playback speed of the animation
    */
    public var timeScale:Float = 1.0;
    /**
     * Playback frame rate
    */
    public var FPS:Float = 60;
    /**
     * the variable that holds the amount of time till next update
    */
    public var accumulator:Float;

    //=-ANIM-CONTROL-=\\
    /**
     * the current animation in use given from the json's "animations" array
    */
    var currentAnim:Int = -1;
    /**
     * is the animation playing
     */
    var isPlaying:Bool = false;

    //=-CONSTRUCTOR-=\\
    /**
     * to get an idea for how to use, check the samples 
     * @param parent the object on which to animate on top of
     * @param animationJSON the JSON animation config file
     * @param atlas the sprite atlas to animate from
     * @param hscriptparser the barely documented parser for hscript from string to expression taken from the parent object
     * @param hscriptinterpreter the barely documented interpreter for hscript from expression to actual use taken from the parent object
     */
    public override function new(parent:h2d.Object, animationJSON: String, #if hscript ?hscriptparser: hscript.Parser, ?hscriptinterpreter: hscript.Interp #end){
        super(parent);
        var parsed = haxe.Json.parse(animationJSON);
        //trace(hxd.Res.load("animsheet.png"));
        //nesting time
        //import the entire JSON into memory
        //trace(animationfile.animations[0]);
        //now as it currently stands, it doesn't check for the type of layers the animation has, same to actions, currently everything is shoved into a single typedef
        animationfile.defaults = parsed.defaults;
        for (a in 0...parsed.animations.length){
            animationfile.animations.push({
                duration: parsed.animations[a].duration,
                name: parsed.animations[a].name,
                layers: parsed.animations[a].layers, //needs to be done seperately to avoid shenanigans
                nextAnim: parsed.animations[a].nextAnim,
            });
            //removed to allow additional data for layers
            // for (l in 0...parsed.animations[a].layers.length){
            //     animationfile.animations[a].layers.push({
            //         type: parsed.animations[a].layers[l].type,
            //         keys: parsed.animations[a].layers[l].keys,
            //         keyIndex: -1,
            //         actions: parsed.animations[a].layers[l].actions,
            //         params: parsed.animations[a].layers[l].params
            //     });
            // }
        }
        //spriteAtlas = new h2d.Bitmap(hxd.Res.load(animationfile.defaults.spriteAtlas).toTile(), parent);
        #if hscript
        hparser = hscriptparser ?? null;
        hinterp = hscriptinterpreter ?? null;
            if(hparser != null && hinterp != null){
                //note that these are just for communicating with Animatron itself
                //you're going to need to add your own variables and functions in your own object code 
                hinterp.variables.set("play",play);
                hinterp.variables.set("pause",pause);
                hinterp.variables.set("unpause",unpause);
                hinterp.variables.set("toggle",toggle);
                hinterp.variables.set("stop",stop);
                hinterp.variables.set("reset",reset);
                hinterp.variables.set("hscriptTest",hscriptTest);
                hinterp.variables.set("hscriptTest2",hscriptTest2);
                hinterp.variables.set("timeScale",timeScale);
            }
        #end
        //var test = hparser.parseString("hscriptTest();");
        //trace(test);
        //hinterp.execute(test);
    }


    /**
     * LOGIC
     */
    override function update(){
        //trace(Std.int(currentDuration), currentDuration); //clamped and raw duration, technically not relevent because literally when, but also it looks cleaner
        
        accumulator += hxd.Timer.dt;

        //this puts a cap to how much it can speed up, as high speeds will lag the fuck out of your computer, and this attempts to not do that
        if (accumulator > (1/FPS) * 5)
            accumulator = (1/FPS) * 5;
        while (accumulator >= 1/FPS){
            accumulator -= 1/FPS;
            fixedUpdate();
        }

        /**
         * updates in millisecond intervals, i no longer need this stupid thing
        */
        var animationTimer = (hxd.Timer.dt * 1000) * timeScale; //1000 in this case corrosponds to milleseconds
 

        //here if it needs to be reversed
        //layer logics
        // if (isPlaying){
        //     if (currentDuration < animationfile.animations[currentAnim].duration){//this has a "shoot first, ask later" approach, where it will check it will increase the number, and will overshoot to hell and back, and then on the loop around it will check
        //         currentDuration += animationTimer;
        //     }
        //     else{
        //         //=-PAUSE ON FINISH-=\\
        //         if(animationfile.animations[currentAnim].nextAnim == null){
        //             pause();
        //         }
        //         //=-NEXT ANIMATION-=\\
        //         else if (animationfile.animations[currentAnim].nextAnim >= 0){
        //             animSwitchAction(animationfile.animations[currentAnim].nextAnim);
        //         }
        //         //=-LOOPING-=\\
        //         else{//if nextAnim is an invalid value or -1, loop the animation, assume the next animation is the current animation
        //             animSwitchAction(currentAnim);
        //             //trace("loop");
        //         }
        //     }

        //     for (l in animationfile.animations[currentAnim].layers){
        //         //the way this currently works is that it iterates through all layers and all keys at once,
        //         //i think that's a bad idea because that means this doesn't scale well
        //         //like if animation has 2000 keys, it checks all 2000 keys at once per frame if one of them is the right one
        //         //idealy it would get 3 keys, the previous the current and the next, and then checks those, based on some sort counter
        //         //the previous for checking mistakes, the current for the action, and the next for switching to
        //         //this would also technically allow me to do reverse playback
        //         //var previousKey = (l.keyIndex - 1 < 0) ? 0 : l.keyIndex - 1 ; //stays at 0 if value doesn't exist //is not in use at the moment, but was intended to be used for reverse playback
                
        //         //in theory i don't need this, because i don't need protection anymore
        //         //nextduration is being read either way, and the keyswitch checks if it didn't loop back to 0 
        //         //okay that wasn't entirely true
        //         var nextKey = (l.keyIndex + 1 > l.keys.length - 1) ? 0 : l.keyIndex + 1; //goes to 0 if value doesn't exist //should be null if there's no next key
                
        //         //now to find a way to get rid of these 2
        //         //because some functions need the next key as its duration
        //         //while others need the next key's index 
        //         var nextDuration = (l.keyIndex != l.keys.length - 1) ? l.keys[l.keyIndex + 1] : animationfile.animations[currentAnim].duration; //necessery evil
        //         var nextKeyDuration = (nextKey != l.keys.length - 1) ? l.keys[nextKey + 1] : animationfile.animations[currentAnim].duration;
        //         //the outcome is done to prevent checking on invalid IDs before even beginning to check
        //         //trace(previousKey, l.keyIndex, nextKey);
        //         //bigger than the current key but smaller than the next key
        //         //if the currentDuration is bigger than the next key, switch to the next key
        //         //nextkey is still being read as 0, even if its null
        //         //this only checks for the 3, but what if the animation starts somewhere, away from any of these keys
        //         //trace(currentDuration >= l.keys[l.keyIndex], currentDuration < nextDuration, currentDuration, l.keyIndex, l.keys[l.keyIndex], nextDuration);
        //         if (currentDuration >= l.keys[l.keyIndex] && currentDuration < nextDuration || currentDuration - animationTimer < l.keys[l.keyIndex] && currentDuration >= l.keys[l.keyIndex]){
        //             //trace(l.keyIndex);
        //             layerAction(l, l.actions[l.keyIndex]);
        //         }
        //         //now the layers are desyncing, despite printing like they're synced
        //         //trace(l.keyIndex, l.type);
        //         //so if the current keyindex doesn't match the current frame, it will jump towards it every tick until it is, interesting
        //         //because now the issue is figuring out what to do in a scenario where the keyindex and the current frame desync
        //         if (currentDuration >= l.keys[nextKey] && nextKey != 0){
        //             //trace(nextKey);
        //             //desync checking
        //             //desync protection
        //             //checks if its bigger than the next and also if its bigger than the key after it
        //             //until only one part is bigger, essentially playing catchup

        //             //second attempt:
        //             //when it detects its not in the current key index, force iterate through all keys til it finds the correct one, to hopefully stay on track
        //             if (currentDuration >= l.keys[nextKey] && currentDuration > nextKeyDuration){
        //                 //iterate through all keys:
        //                 for (k in 0...l.keys.length){
        //                     var foundNextKey = (k != l.keys.length - 1) ? l.keys[k + 1] : animationfile.animations[currentAnim].duration;
        //                     //trace(currentDuration);
        //                     if (currentDuration >= l.keys[k] && currentDuration < foundNextKey || currentDuration - animationTimer < l.keys[k] && currentDuration >= l.keys[k]){
        //                         //layerAction(l, l.actions[l.keyIndex]);
        //                         //trace("Key Found: " + l.keys[k], l.keyIndex, k);
        //                         l.keyIndex = k;
        //                         nextKey = (l.keyIndex + 1 > l.keys.length - 1) ? 0 : l.keyIndex + 1;
        //                         nextDuration = (l.keyIndex != l.keys.length - 1) ? l.keys[l.keyIndex + 1] : animationfile.animations[currentAnim].duration;
        //                         nextKeyDuration = (nextKey != l.keys.length - 1) ? l.keys[nextKey + 1] : animationfile.animations[currentAnim].duration;
        //                         keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] ); // i need to check if the position of this matters
        //                     }
        //                 }
        //             }
        //             else{
        //                 //trace("philip"); //who?
        //                 keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] );
        //                 //trace(l.keyIndex, nextKey, nextKeyDuration, nextDuration);
        //                 if (l.keyIndex != l.keys.length - 1){
        //                     l.keyIndex++;
        //                 }
        //             }
        //             //starts to break on a timescale of 13, starts erroring at 14, dies after 15, and completely crashes past 50
        //             //okay this completely breaks on higher timescales, something the previous system didn't struggle with
        //             //and its likely because of the while loop
        //             //it should be just an if statement or a for loop that checks once through all keys from the bottom, to see if there's a match
        //             //the previous system didn't run into this issue because it was checking all keys all the time every frame, and thus it could check in parallel
        //             // while (currentDuration >= l.keys[nextKey] && currentDuration > nextKeyDuration){
        //             //     l.keyIndex++;
        //             //     //previousKey = (l.keyIndex - 1 < 0) ? 0 : l.keyIndex - 1 ;
        //             //     nextKey = (l.keyIndex + 1 > l.keys.length - 1) ? 0 : l.keyIndex + 1;
        //             //     nextDuration = (l.keyIndex != l.keys.length - 1) ? l.keys[l.keyIndex + 1] : animationfile.animations[currentAnim].duration;
        //             //     nextKeyDuration = (nextKey != l.keys.length - 1) ? l.keys[nextKey + 1] : animationfile.animations[currentAnim].duration;
        //             //     trace("all hell breaks loose");
        //             //     //trace(currentDuration, l.keys[nextKey]);
        //             // }
        //             //trace(currentDuration, l.keys[nextKey]);
        //             //trace(l.keys[l.keyIndex], currentDuration);
        //             //for some reason this is called multiple times, despite it only being called once
        //             //trace(l.keyIndex);
        //             // keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] );
        //             // //trace(l.keyIndex, nextKey, nextKeyDuration, nextDuration);
        //             // if (l.keyIndex != l.keys.length - 1){
        //             //     l.keyIndex++;
        //             // }
        //             //l.keyIndex++; //this is a key culprit, because it increases without a check
        //             //trace(currentDuration, l.keys[nextKey]);
        //             //trace("beninging");
        //         }
        //         //one checks for normal logic, the other for overshooting
        //         //trace(currentDuration, l.keys[l.keyIndex], currentDuration - animationTimer, nextDuration, l.keyIndex);
        //         //previousDuration can be at minus for some reason, despite it supposed to be impposible, oh its because currentDuration - animationTimer has no < 0 check
                
        //         // if (currentDuration >= l.keys[l.keyIndex] && currentDuration < nextDuration || currentDuration - animationTimer < l.keys[l.keyIndex] && currentDuration >= l.keys[l.keyIndex]){
        //         //     //trace(l.keyIndex);
        //         //     layerAction(l, l.actions[l.keyIndex]);
        //         // }

        //         // for (k in 0...l.keys.length){
        //         //     //black magic
        //         //     var nextKey = (k != l.keys.length - 1) ? l.keys[k + 1] : animationfile.animations[currentAnim].duration; //when the next key's duration is invalid, just get the animation duration
        //         //     //one checks for normal logic, the other for overshooting
        //         //     if (currentDuration > l.keys[k] && currentDuration < nextKey || currentDuration - animationTimer < l.keys[k] && currentDuration >= l.keys[k]) {
        //         //         if (l.keyIndex != k){ // i really do not like the use of this variable, it feels pointless
        //         //             //so i would need to check if its discrete or not
        //         //             //trace(l.keyIndex,k, (k >= l.keys.length - 1)?0:k+1); //previous key, current key, next key
        //         //             keysSwitchAction(l, l.actions[k], l.actions[l.keyIndex]); //this needs to be figured out, i need to find if i can somehow sandwich this into the layerAction function
        //         //             l.keyIndex = k;
        //         //             // if (l.actions[k].continuous){
        //         //             //     trace("moolah");
        //         //             // }
        //         //             // else{
        //         //             //     trace("mulan");
        //         //             // }
        //         //         }
        //         //         layerAction(l, l.actions[k]);
        //         //     }
        //         //     //here to check for bugs
        //         //     // else if (currentDuration - animationTimer < l.keys[k] && currentDuration >= l.keys[k]){//overshooting patchwork
        //         //     //     if (l.keyIndex != k){ //same here
        //         //     //         l.keyIndex = k;
        //         //     //         keySwitch(l); //this needs to be figured out, i need to find if i can somehow sandwich this into the layerAction function
        //         //     //     }
        //         //     //     layerAction(l, l.actions[k]);
        //         //     // }
        //         // }
        //     }
            
        //     //update last
        //     // if (previousDuration != currentDuration){ //this is still here so that i can reverse it in the case of unforeseen bugs
        //     //     trace(previousDuration, currentDuration, animationTimer, currentDuration - animationTimer, previousDuration == currentDuration - animationTimer);
        //     //     previousDuration = currentDuration;
        //     // }

        // }


    }

    /**
     * the desyncs come from rendering lags that are basically not visible because of how fast everything updates
     * 
     * its supposed to update every fixed frame, yet it finds a way to not update every fixed frame
     */
    override function fixedUpdate() {
        //trace(accumulator);
        if (isPlaying){
            for (l in animationfile.animations[currentAnim].layers){
                //var currentKey = l.keyIndex; //just for ease of visualizing
                var nextKey = (l.keyIndex + 1 > l.keys.length - 1) ? 0 : l.keyIndex + 1; //goes to 0 if value doesn't exist //should be null if there's no next key
                var nextDuration = (l.keyIndex != l.keys.length - 1) ? l.keys[l.keyIndex + 1] : animationfile.animations[currentAnim].duration; //necessery evil
                var nextKeyDuration = (nextKey != l.keys.length - 1) ? l.keys[nextKey + 1] : animationfile.animations[currentAnim].duration;
                //trace(l.keyIndex, nextKey, currentDuration, l.keys[nextKey], nextKeyDuration);
                //well this thing is completely worthless
                //trace(currentDuration >= l.keys[l.keyIndex],currentDuration < nextDuration, currentDuration, nextDuration);
                // if (currentDuration >= l.keys[l.keyIndex] && currentDuration < nextDuration || currentDuration - ((1/this.FPS) * 1000) < l.keys[l.keyIndex] && currentDuration >= l.keys[l.keyIndex]){
                //     //trace(l.keyIndex);
                //trace("play",l.keyIndex,l.actions[l.keyIndex],nextKey,nextKeyDuration,nextDuration);
                //trace(l.keyIndex);
                layerAction(l, l.actions[l.keyIndex]); //its like its skipped every once in a while
                // }
                //now the layers are desyncing, despite printing like they're synced
                //trace(l.keyIndex, l.type);
                //so if the current keyindex doesn't match the current frame, it will jump towards it every tick until it is, interesting
                //because now the issue is figuring out what to do in a scenario where the keyindex and the current frame desync
                if (currentDuration >= l.keys[nextKey] && nextKey != 0){ //this is redundent
                    //desync protection/key switching:
                    //when it detects its not in the current key index, force iterate through all keys til it finds the correct one, to hopefully stay on track
                    //so this causes a problem, because it just jumps to whatever it is, it completely skips the ones before it.
                    //so ideally it would iterate through the keys of the skipped keys, the problem is that this is not what this does, because it just finds the key it needs and goes there
                    if (currentDuration >= l.keys[nextKey] && currentDuration > nextKeyDuration){
                        //iterate through all keys:
                        for (k in 0...l.keys.length){
                            var foundNextKey = (k != l.keys.length - 1) ? l.keys[k + 1] : animationfile.animations[currentAnim].duration;
                            //trace(currentDuration, l.keys[k], currentDuration >= l.keys[k], currentDuration, foundNextKey, currentDuration < foundNextKey);
                            //trace(currentDuration - ((1/this.FPS)*1000), l.keys[k],currentDuration - ((1/this.FPS)*1000) < l.keys[k], currentDuration, l.keys[k], currentDuration >= l.keys[k]);
                            if (currentDuration >= l.keys[k] && currentDuration < foundNextKey){
                            //if (currentDuration >= l.keys[k] && currentDuration < nextKeyDuration || currentDuration - ((1/this.FPS)*1000) < l.keys[k] && currentDuration >= l.keys[k]){
                                //layerAction(l, l.actions[l.keyIndex]);
                                //trace("Key Found: " + l.keys[k], l.keyIndex, k);
                                keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] ); // i need to check if the position of this matters
                                while (l.keyIndex < k-1){
                                    //trace(l.keyIndex, k, l.keyIndex+1);
                                    l.keyIndex++;
                                }
                                // l.keyIndex = k;
                                //trace(l.keyIndex);
                                nextKey = (l.keyIndex + 1 > l.keys.length - 1) ? 0 : l.keyIndex + 1;
                                nextDuration = (l.keyIndex != l.keys.length - 1) ? l.keys[l.keyIndex + 1] : animationfile.animations[currentAnim].duration;
                                nextKeyDuration = (nextKey != l.keys.length - 1) ? l.keys[nextKey + 1] : animationfile.animations[currentAnim].duration;
                                //keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] ); // i need to check if the position of this matters
                                break;
                            }
                        }
                    }
                    else{
                        keySwitchAction(l, l.actions[nextKey], l.actions[l.keyIndex] );
                        //trace(l.keyIndex, nextKey, nextKeyDuration, nextDuration);
                        //trace(l.keyIndex, nextKey);
                        if (l.keyIndex != l.keys.length - 1){//this in theory is impossible, but in theory the sky is blue
                            l.keyIndex++;
                        }

                    }

                }
                
            }
            if (currentDuration < animationfile.animations[currentAnim].duration){//this has a "shoot first, ask later" approach, where it will check it will increase the number, and will overshoot to hell and back, and then on the loop around it will check
                currentDuration += ((1/this.FPS) * 1000); //this would need to be resolved in the overshoot mechanism
            }
            else{
                //=-PAUSE ON FINISH-=\\
                if(animationfile.animations[currentAnim].nextAnim == null){
                    pause();
                }
                //=-NEXT ANIMATION-=\\
                else if (animationfile.animations[currentAnim].nextAnim >= 0){
                    animSwitchAction(animationfile.animations[currentAnim].nextAnim);
                }
                //=-LOOPING-=\\
                else{//if nextAnim is an invalid value or -1, loop the animation, assume the next animation is the current animation
                    animSwitchAction(currentAnim);
                    //trace("loop");
                }
            }

        }

        // if (accumulator >= 1/this.FPS){
        //     //accumulator -= 1/FPS;
        //     fixedUpdate();
        // }
    }

    /**
     * the logic that switches between animations
     * @param ID the animation to switch to
    */
    function animSwitchAction(ID:Int){
        //panic handler for starting on invalid number i.e on load
        if (currentAnim < 0 || currentAnim >= animationfile.animations.length){
            currentAnim = 0;
        }

        for (l in animationfile.animations[currentAnim].layers){loadAction(l,ID);} //clear the last layers
        currentDuration = 0; //reset the duration
        //previousDuration = currentDuration;
        currentAnim = ID;
        isPlaying = true; //i'll put a pin on this one, might cause a hyper specific issue long term
        //this part is a hotfix but its also bloating, i don't want this here, but the alternative is letting the first frame play out like normal, but only the first frame
        // for (l in animationfile.animations[currentAnim].layers){
        //     loadAction(l); //meant to fix a bug with loading an animation while paused, this will ensure it will load with at least some visual
        //     //however it is still a hotfix instead of an actual fix, this works but its need a solution
        // }
    }



    //=-ACTION EXECUTION-=\\
    /**
     * executes right before everything else, useful for clearing layers before the current animation changes
     * @param layer the layers to clear
     * @param ID the next anim's ID to pass to
     */
    public function loadAction(layer:Layer, nextAnim:Int){
        layer.keyIndex = 0; //reset the keyindex of all layer
        switch layer.type{
            case "image":
                //recycling the image, don't clear the imageLayer when the path is identical on both animations, just pass it onwards
                //just passes to the first instance using the same path, otherwise it gets removed
                //this should in theory be faster although i don't really have a profiler at hand to check for performance diffs, so i'm going by knowledge
                //problem A: if the next animation doesn't have an image layer that begins at frame 0, which will pass the image on to a frame that has yet to play
                //problem B: if that's the case then i can only check if the key to go to starts at frame 0, which helps in most cases, but this isn't intended for most cases, its intended for all cases
                //fuck
                var imgLayer:ImageLayer = cast layer;
                if (nextAnim != currentAnim){//checks if its not just passing between itself to itself, because it should do nothing if that's the case
                    for (l in animationfile.animations[nextAnim].layers){
                        if (l.type == "image"){
                            var nextimg:ImageLayer = cast l;
                            //only checks if the layer even uses the spriteAtlas variable,
                            //if not it either does nothing as its not being replaced or in keysSwitchActions it checks every key if the key has a SpriteAtlas variable that's not empty
                            if (nextimg.spriteAtlas == imgLayer.spriteAtlas && imgLayer.instance != null && nextimg.instance == null){//checks if the instance has been passed or not to make sure its not accidentally passed twice
                                nextimg.instance = imgLayer.instance;
                                this.add(nextimg.instance, animationfile.animations[nextAnim].layers.indexOf(l)); //this should work
                                imgLayer.instance = null; //pass it through
                                if (nextimg.keys[0] != 0){//explained below
                                    nextimg.instance.alpha = 0;
                                }
                            }
                        }
                    }
                    if(imgLayer.instance != null){//checks again if the instance has been passed around or not
                        imgLayer.instance.remove();
                        imgLayer.instance = null;
                    }
                }
                else{
                    //alpha hiding the transfered image instance if the first key of the next instance does not start at 0
                    if (imgLayer.keys[0] != 0 && imgLayer.instance != null){
                        imgLayer.instance.alpha = 0;
                    }
                }
            case "collision":
                //collisions are a different matter, while technically i could pass the collisions through,
                //collisions just function completely different for me to actually consider passing one through
                //fuck it we ball
                //not yet
                // if (nextAnim != currentAnim){
                //     if (l.type == "collision"){
                        
                //     }
                // }
                var colLayer:CollisionLayer = cast layer;
                if (colLayer.instance != null){
                    colLayer.instance.remove();
                    colLayer.instance = null;
                }
            case "hscript":
                var hscriptlayer:ScriptLayer = cast layer;
                if (hscriptlayer.instance != null){
                    hscriptlayer.instance = null;
                }
            }
    }

    /**
     * executes when a key in a layer changes
     * 
     * keeps values that haven't changed, resulting in less jumps
     * @param layer the layer for which actions reside in
     * @param currentAction the current action being switched into
     * @param previousAction the action being switched from
     */
    public function keySwitchAction(layer:Layer, currentAction:Action, previousAction:Action){//a part of me feels like its confusing to have the previousAction be the secondary value
        switch layer.type{
            case "image":
                //check if current atlas is the one in use
                //reminder that the sprite atlas can be set per frame too
                //handle action spriteAtlas switches
                //it should do nothing if no atlas is set, so i can just check if the previous and current use the same Atlas
                // var imgLayer:ImageLayer = cast layer;
                // if (imgLayer.instance != null){
                //     imgLayer.instance.remove();
                //     imgLayer.instance = null;
                // }
            case "collision":
                //check if current shape is the same as the one active, and just move the variables around
                //it has been officially proven doable, so that's nice
                //the question comes, is this practical, now i have no idea because the headcannon idea of constantly creating new references is affecting performance where its not easily visible, thus i did this
                //the second arrives on the form of, should i object pooling?, as in have an array keep them around instead of deleting them, and if a layer needs one just call that one? too complicated  
                var colLayer:CollisionLayer = cast layer;
                var currentCast:ColAction = cast currentAction;
                var previoustCast:ColAction = cast previousAction;
                //trace(currentCast.type, previoustCast.type);
                if (colLayer.instance != null){//this only checks if it isn't empty, but its very possible for this to be empty because it only runs every key switch
                    if (currentCast.type == previoustCast.type){
                        switch currentCast.type{
                            case "circle":
                                trace("soon");
                            case "square":
                                var currentSquare:SquareAction = cast currentCast;
                                var squareLayer:h2d.col.Square = cast colLayer.instance;
                                squareLayer.x = currentSquare.x; squareLayer.y = currentSquare.y;
                                squareLayer.width  = currentSquare.w; squareLayer.height = currentSquare.h;
                                //trace(currentSquare.x, currentSquare.y, currentSquare.w, currentSquare.h, layer.keyIndex, currentDuration, currentAction, previousAction);
                        }
                    }
                    else{
                        colLayer.instance.remove();
                        colLayer.instance = null;
                    }
                }
                #if debug
                    if (colLayer.instance != null){//handles redrawing the collision draw every change, because otherwise it'll just stay the same shape
                        colLayer.instance.collisionDraw();
                    }
                #end
            case "hscript":
                var hscriptlayer:ScriptLayer = cast layer;
                if (hscriptlayer.instance != null){
                    hscriptlayer.instance = null;
                }
                //something needs to stop the script from running and switch to the next one
            case "signal":
                var scriptlayer:ScriptLayer = cast layer;
                if (scriptlayer.instance != null){
                    scriptlayer.instance = null;
                }
                //same here
        }
        //okay so for some reason it always reads false from keyHasSwitched
        //yet its fine with reading the raw variable
        //trace(keyHasSwitched);
    }

    /**
     * preforms the layer's actions, playback type relies on the action's continuous variable
     */
    function layerAction(layer:Layer, action:Action){
        if (action == null){//this is not finished
            return;
        }
        switch layer.type{
            case "image":
                var imglayer:ImageLayer = cast layer;
                var image:ImageAction = cast action;
                if (imglayer.instance == null){
                    //check if the action has an atlasoverride
                    //if (image.spriteAtlas != null)
                    //check if the layer has a spriteAtlas set
                    //else if (imglayer.spriteAtlas != null){
                    if (imglayer.spriteAtlas != null){imglayer.instance = new h2d.Bitmap(hxd.Res.load(imglayer.spriteAtlas).toTile(), parent);}
                    //otherwise just use the default
                    else if (animationfile.defaults.spriteAtlas != null){imglayer.instance = new h2d.Bitmap(hxd.Res.load(animationfile.defaults.spriteAtlas).toTile(), parent);}
                    //but what if there is no default assigned? (panic handler)
                    else{imglayer.instance = new h2d.Bitmap(null, parent);}
                    
                    imglayer.instance.tile.setSize(image.width, image.height); //the size of the tile
                    imglayer.instance.tile.setPosition(image.offsetX,image.offsetY); //the draw offset of the tile
                    imglayer.instance.setPosition(image.x,image.y);
                    imglayer.instance.alpha = 0; //well if its just spawning an empty one why should it spawn with visuals?
                    this.add(imglayer.instance, animationfile.animations[currentAnim].layers.indexOf(layer));// needs testing
                }
                
                if (!action.continuous){
                    imglayer.instance.tile.setSize(image.width, image.height); //the size of the tile
                    imglayer.instance.tile.setPosition(image.offsetX,image.offsetY); //the draw offset of the tile
                    imglayer.instance.setPosition(image.x,image.y);
                    imglayer.instance.alpha = (image.alpha == null) ? 255 : image.alpha/255; //boy do i hate having a 0-1 float on a 0-255 int
                }

                if (action.continuous){
                    //so now to do the continuous action, alright so, morphin time.
                    //basically i have to figure how other engines do morphing between keys on their animation systems,
                    //because as far as i care it just lerps between 2 points, the current frame and next frame, with its duration based on the currentduration
                    //so i need a 0-1
                    //offset testing up first, i need to lerp between 2 points
                    //imglayer.instance.tile.setPosition(hxd.Math.lerp(currentimage.x, nextimage.x, currentduration),  );//pseudo code visualizing of the idea
                    //i need like a clamped value of the current key til the next key between 0-1
                    //more specifically i need a value between the current key and the next key, clamped based on the currentDuration
                    //looked it up, its supposed to be something like (currentDuration - currentKey) / (nextKey - currentKey)
                    //so (t - a) / (b-a) basically
                    
                    //okay first check if the current and next values are different, because if they're the same, then its wasting time
                    var currentKey = layer.actions.indexOf(action);
                    var currentKeyDuration = layer.keys[currentKey];
                    var nextKey = layer.keyIndex + 1;
                    var nextDuration = (layer.keyIndex != layer.keys.length - 1) ? layer.keys[layer.keyIndex + 1] : animationfile.animations[currentAnim].duration;
                    var nextAction:ImageAction = cast layer.actions[nextKey];
                    if (nextKey < layer.keys.length){
                        //note, its very unoptimized right now, but i don't have a use for it for my current project, so it'll stay this way for now
                        //when i do, expect this to be updated
                        //because currently this has no options for control, no tween options, and whatever else it might need.
                        var k = (currentDuration - currentKeyDuration) / (nextDuration - currentKeyDuration);
                        imglayer.instance.tile.setSize(hxd.Math.lerp(image.width,nextAction.width,k), hxd.Math.lerp(image.height,nextAction.height,k));
                        imglayer.instance.tile.setPosition(hxd.Math.lerp(image.offsetX,nextAction.offsetX,k),hxd.Math.lerp(image.offsetY,nextAction.offsetY,k));
                        imglayer.instance.setPosition(hxd.Math.lerp(image.x,nextAction.x,k),hxd.Math.lerp(image.y,nextAction.y,k));
                        var currentAlpha = (image.alpha == null) ? 255 : image.alpha/255;
                        var nextAlpha = (nextAction.alpha == null) ? 255 : nextAction.alpha/255;
                        imglayer.instance.alpha = hxd.Math.lerp(currentAlpha,nextAlpha,k);
                    }

                }

            case "collision":
                var colLayer:CollisionLayer = cast layer;
                var colAction:ColAction = cast action;
                if (colLayer.instance == null){
                    switch colAction.type{
                        case "circle":
                            var circle:CircleAction = cast action;
                                colLayer.instance = new h2d.col.Circle(parent, circle.x, circle.y, circle.radius);
                        case "square":
                            var square:SquareAction = cast action;
                                //okay now i need some way to clear this
                                colLayer.instance = new h2d.col.Square(parent, square.x, square.y, square.w, square.h);
                    }
                    //executes post creation
                    if (colLayer != null){this.add(colLayer.instance, animationfile.animations[currentAnim].layers.indexOf(layer));}
                    //collision doesn't have any continuous action yet, and probably wont have for a good while
                    //because the continuous action is supposed to a morph, for which i would need to check what shape it is, and do a unique implementation for each one, too much work for now
                }
            case "hscript":
                #if hscript
                var hscriptLayer:ScriptLayer = cast layer;
                var hscriptAction:ScriptAction = cast action;
                //in hscript's case (and signal), the purpose of instance is purely for checking the continuous variable
                if (hscriptLayer.instance == null){
                    hscriptLayer.instance = hscriptAction.script;
                    if (!action.continuous){
                        var parsed = hparser.parseString(hscriptLayer.instance);
                        hinterp.execute(parsed);
                    }
                }
                if (action.continuous){
                    var parsed = hparser.parseString(hscriptLayer.instance);
                    hinterp.execute(parsed);
                }
                #end
            case "signal":
                //yes it and hscript share the same layer data, because they're basically the same
                var scriptLayer:ScriptLayer = cast layer;
                var signalAction:SignalAction = cast action;
                if (scriptLayer.instance == null){
                    scriptLayer.instance = signalAction.func; //purely visual
                    if (!action.continuous){
                        var fakeArgs:Array<Dynamic> = [signalAction.args[0], false,true, 300];// so using the array directly doesn't work but specifying it manually does
                        Reflect.callMethod((signalAction.useParent) ? parent : this, Reflect.field((signalAction.useParent) ? parent : this, signalAction.func),signalAction.args );
                    }
                }
                if (action.continuous){
                    var fakeArgs:Array<Dynamic> = [signalAction.args[0], false,true, 300];// so using the array directly doesn't work but specifying it manually does
                    Reflect.callMethod((signalAction.useParent) ? parent : this, Reflect.field((signalAction.useParent) ? parent : this, signalAction.func),signalAction.args );
                }
        }

    }



    //=-HELPER FUNCTIONS-=\\
    /**
     * play the given animation 
     * 
     * its recommended to have an enum on whatever object you're using this on to visualize what animation you're playing
     * @param ID the id of the animation to play starting from 0
     */
    public function play(ID:Int, force:Bool = false, paused:Bool = false, startFrame:Null<Float> = null){
        if (currentAnim == ID && !force){
            //trace("well its already playing");
            return;
        }
        animSwitchAction(ID);
        //this doesn't work because starting at a specifc frame paused doesn't do anything
        if (startFrame != null && startFrame >= 0) currentDuration = startFrame; //no minus numbers
        
        if (!paused){
            isPlaying = true;
        }
        else {
            isPlaying = false;
            //play the very first frame to at least have some visual
            for (l in animationfile.animations[currentAnim].layers){
                // i need to get the key that's in that frame
                //easier said then done
                trace(currentDuration);
                var indexKey = 0;
                for (k in 0...l.keys.length){
                    //no need for overshoot protection if it starts paused
                    if (currentDuration >= l.keys[k] && currentDuration < ((k + 1 < l.keys.length ) ? l.keys[k+1] : animationfile.animations[currentAnim].duration)) indexKey = k;
                    //trace(l.keys[k], currentDuration , (k + 1 < l.keys.length ) ? l.keys[k+1] : animationfile.animations[currentAnim].duration );
                }
                layerAction(l, l.actions[indexKey]);
            }
        }
    }
    //=-PAUSING AND UNPAUSING
    public function pause(){ if (isPlaying != false) isPlaying = false; }
    public function unpause(){ if (isPlaying != true) isPlaying = true; }
    public function toggle(){ if (isPlaying == true) pause(); if (isPlaying == false) unpause(); }
    public function stop(){play(currentAnim, true,true); } //in this case, stopping is replaying the animation but preventing it from playing
    public function reset(){play(currentAnim, true, false); }//i was planning to write a wrapper GUI around this animation system so that it can be easily created and modified from outside, so this is part of it
    //public function reverse({return "how the fuck do you even begin to do this one"}); //needless to say i gave up on that one 

    //=-GETTERS-=\\
    public function getCurrentAnimation(){return animationfile.animations[currentAnim];}
    public function getCollisionInstances(){//UNTESTED //Returns all currently instantiated collisions for checking, meant to be called recursively, as collisions can change every frame
        var colliders:Array<h2d.col.Collider> = [];
        for (l in animationfile.animations[currentAnim].layers){
            switch l.type{
                case "collision":
                    var colLayer:CollisionLayer = cast l;
                    if (colLayer.instance != null){
                        colliders.push(colLayer.instance);
                    }
            }
        }
        return colliders;
    }

    //in case you need a function that checks if the animation ended for some hyper specific manual actions
    //UNIMPLEMENTED, and en route to be scrapped
    public dynamic function onAnimEnd(){};

    /** * go to and play the label by its name
     * @param identifier the name of the label*/
    public function playLabel(identifier:String){//there's no simple way to go about this (as far as i am aware), and that's the best i could come up with
        for (l in animationfile.animations[currentAnim].layers){
            if (l.type == "label"){//get the label layers
                for (k in 0...l.keys.length){
                    var label:LabelAction = cast l.actions[k];
                    if (label.name == identifier){
                        play(currentAnim, true,false, l.keys[k]);
                    }
                }
            }
        }
        //play(currentAnim, true,true);
    }

    //=-TESTING VARIABLES TO REMOVE-=\\
    public function hscriptTest(){
        trace("this is an hscript test");
    }

    public function hscriptTest2(){
        trace("could be hscript could be something else");
    }

}