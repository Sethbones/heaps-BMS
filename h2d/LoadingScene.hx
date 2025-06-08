package h2d;

/**
 * i have no idea, no info on it either, and it was added kind of recently too, and it seems to be maintained, i just have no idea what it does
 * 
 * https://github.com/HeapsIO/heaps/issues/533 this might give a clue
 * 
 * my educated guess would be that it doesn't render the screen until a timer is done and once its done, it starts rendering
 * 
 * no idea why this would be here like this, this should be a part of a game, or a sample, not a part of the engine
 */
class LoadingScene extends h2d.Scene {
	var renderTarget : h3d.mat.Texture;
	var presentCooldown : Float;
	public function new(presentCooldown : Float) {
		super();
		this.presentCooldown = presentCooldown;
		renderTarget = new h3d.mat.Texture(width, height, [Target]);
	}

	var lastPresentTime : Float = 0.0;
	public override function render( engine : h3d.Engine ) {
		var time = haxe.Timer.stamp();
		if ( time - lastPresentTime < presentCooldown)
			return;
		lastPresentTime = time;
	
	//some black magic shit
	#if usesys
		haxe.System.emitEvents(@:privateAccess hxd.Window.inst.event);
	#elseif hldx
		dx.Loop.processEvents(@:privateAccess hxd.Window.inst.onEvent);
	#elseif hlsdl
		sdl.Sdl.processEvents(@:privateAccess hxd.Window.inst.onEvent);
	#end

		if ( renderTarget.width != engine.width || renderTarget.height != engine.height) {
			renderTarget.dispose();
			renderTarget = new h3d.mat.Texture(engine.width, engine.height, [Target]);
		}

		
		engine.pushTarget(renderTarget);
		super.render(engine);
		engine.popTarget();
		h3d.pass.Copy.run(renderTarget, null);
		engine.driver.present();
	}

	override function onRemove() {
		super.onRemove();
		if ( renderTarget != null )
			renderTarget.dispose();
	} 
}
