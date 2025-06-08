package hxd.res;

enum Platform {
	HL;
	JS;
	Unknown;
}

/**
	Resources configuration file.
	Should be modified with --macro to be sure it's correctly setup before any code is compiled.
**/
class Config {

	/**
		Maps the extension to a given resource class. Example ["wav,mp3,ogg" => "hxd.res.Sound"]
	**/
	public static var extensions = [
		"jpg,png,jpeg,gif,tga,dds,hdr" => "hxd.res.Image",
		"fbx,hmd" => "hxd.res.Model",
		"ttf" => "hxd.res.Font",
		"fnt" => "hxd.res.BitmapFont",
		"bdf" => "hxd.res.BDFFont",
		"wav,mp3,ogg" => "hxd.res.Sound",
		"tmx" => "hxd.res.TiledMap",
		//"world" = "hxd.res.TiledWorld", //soon
		"atlas" => "hxd.res.Atlas",
		"grd" => "hxd.res.Gradients",
		#if hide
		"prefab,fx,fx2d,l3d" => "hxd.res.Prefab",
		//"world" => "hxd.res.World", //res.world was removed in jan2 2024, yet this stayed, the hell?
		"animgraph" => "hxd.res.AnimGraph",
		#end
	];

	public static function addExtension( extension, className) {
		extensions.set(extension, className);
	}

	/**
		File extensions ignored by the resource scan
		
		Fork Note: figure out why whatever happend here happend
	**/
	public static var ignoredExtensions = [
		"gal" => true, // graphics gale source
		"lch" => true, // labchirp source
		"fla" => true, // Adobe flash
	];


	/**
		Directory names not explored by the resource scan
		Example: `ignoredDirs = [ "backups"=>true ]`
	**/
	public static var ignoredDirs : Map<String,Bool> = [];

	//should probably have a directory whitelist option too 


	/**
		Paired extensions are files that can have the same name but different extensions.
		Only the "main" one will be accessible through hxd.Res.
		Example : ["fbx" => "png,jpg,jpeg,gif"]
	**/
	public static var pairedExtensions = [
		"fnt" => "png",
		"fbx" => "png,jpg,jpeg,gif,tga",
		"cdb" => "img",
		"atlas" => "png",
		"ogg" => "wav",
		"mp3" => "wav",
		"l3d" => "bake",
		"css" => "less,css.map",
	];

	public static function addPairedExtension( main, shadow) {
		if (pairedExtensions.exists(main))
			pairedExtensions.set(main, pairedExtensions.get(main) + "," + shadow);
		else
			pairedExtensions.set(main, shadow);
	}

	//this is erroring in vscode, but only in here, odd.
	static function defined( name : String ) {
		return haxe.macro.Context.defined(name);
	}

	static function init() {
		var pf =
			if( defined("js") ) JS else
			if( defined("hl") ) HL else
			Unknown;
		switch( pf ) {
		case HL:
			#if !heaps_enable_hl_mp3
			ignoredExtensions.set("mp3", true);
			#end
		default:
			//so from what i gather, .ogg playback is not natively supported in javascript, and from what i gather some other engines either use a unique library to read oggs
			//or just convert them to another format on compile.
			//as for what are those other engines, i have no idea, i found this information on reddit.
			#if !stb_ogg_sound
			ignoredExtensions.set("ogg", true);
			#end
		}
		return pf;
	}

	public static var platform : Platform = init();

}