package hxd.res;
import haxe.xml.Access;

/**
 * note, map reading is kind of slow currently, and will likely stay that way until some major optimization is done
 * 
 * 
 * TODO: Check for x and y coordinates that can be floats
 * 
 * Currently Missing Features that i can note:
 * 
 * for file formats:
 * xml support, it was cut because of its deprecated status, i don't know if it will get removed at some point to actually bother with it
 * json support the irony here is that updating the parser broke support for json, is funny, it was intended for json use initially
 * zstd compression support in haxe is non existent, i either have to create my own library, or hope format gets support for zst, either way, no way
 * 
 * for maps:
 * class spawning, can be used to assign as a scene, i think at least?, i'll likely have to run into it at some point
 * isomatric tileset and staggered variant
 * hexagonal map
 * background color
 * compression level //i think it does work, just need to validate it
 * Custom Properties
 * parallax origin //whatever that means
 * tile side length //whatever that means
 * stagger index //i have no idea
 * embadding tilesets //shouldn't be too hard, but not a lot of reasons to implement
 * 
 * for tilesets:
 * tile classes 
 * object alignment
 * drawing offset
 * tile render size
 * fill mode
 * background color //i understand it in map terms, but this is a tileset
 * orientation //for some reason you can just change oriantation in the tileset itself, for some reason
 * allowed transformations //okay, i don't understand what that's for, but sure
 * tile animations, they will likely be scrapped for the current project for shaders over things like water, but it could still be useful
 * 
 * for collision:
 * all of it, i need to figure out the what and how 
 * 
 * for objects: 
 * the entire thing
 * 
 * class spawning
 * draw offsets
 * hitboxes/polygons
 * Custom Properties
 * templates //in the works
 * 
 */
//

typedef TiledTemplateData = {//okay so for some reason template data doesn't include class info, so much for cutting out the middle man, gonna have to route it into the required tileset file and get the class info from there, it's so dumb.
	var firstgid: Int;
	var source: String;
	var gid: Int;
	var width: Int;
	var height: Int;
	var properties: Array<{name:String, type:Dynamic, value: Dynamic}>;

	//=-UNDOCUMENTED, EVEN IN TILED ITSELF, ALSO KNOWN AS PUSH BETA AS MAIN-=\\
	//i guess these are here for future proofing?
	var ?x: Float; //this is a variable you can edit inside of tiled, but it always returns back to its original position of -width /2
	var ?y: Float; //this is a variable you can edit inside of tiled, but it always returns back to its original position of height /2
}

typedef TiledObjectData = {
	var id:Int;
	var gid:Int; //some map files have gid attached to them, other's don't, that's tiled for ya
	var x:Int; var y:Int;
	var width:Int; var height:Int;
	var ?Properties:Array<{name:String, value: Dynamic}>;
	var type:String; //if type is empty go to template
	var template:String; //path to file
}

//object groups are layers, the implementation of tiled here is so scuffed, objectgroup is seen as a layer
typedef TiledObjectGroup = {
	var id:Int;
	var name:String;
	var parallaxFactorX:Float; //should probably be optional
	var parallaxFactorY:Float; //should probably be optional
	var objects:Array<TiledObjectData>;
}

/**world file data, not sure the uses of it but sure*/
typedef TiledWorldData = {//for some reason the world file is a json despite all other files are csv, tiled being tiled again
	var maps : Array<{filename: String, width:Int, height:Int,  x: Int, y : Int}>;
	var onlyShowAdjacentMaps: Bool;
	var type: String;
}

/**Infinite map Chunk data*/
typedef TiledChunkData = {
	var x: Int; var y: Int;
	var width: Int; var height: Int;
	var data : Array<Int>;
}

/**
 * Tileset File Info
 * 
 * so something unusual is that some tilesets can have data embedded on the map file
 * essentially making map specific changes, as for why this is i have no idea, this should be noted as its not implemented yet
 */
typedef TiledTilesetData = {
    /** the name of the tileset */
    var name:String; 
	/** the path of the image file used by the tileset */
    var source:String; 
    /** the width of the tiles in the tileset */
    var tileWidth:Int;
    /** the width of the tiles in the tileset */
    var tileHeight:Int;
    /** the amount of tiles in the tileset */
    var tileCount:Int;
    /** the amount of columns in the image of the tileset */
    var columns:Int;
	/** the starting number id of the tileset */
	var firstgid:Int;
    /** the space in pixels from the top left corner to the first tile*/
    var margin:Int;
	/** the space in pixels between each tile*/
    var spacing:Int;
	/** the tile draw offset X*/
	var offsetX:Int;
	/** the tile draw offset Y*/
	var offsetY:Int;
	
	var tileClasses:Array<{id: Int, type:String}>;

}


/**
 * TiledLayerInfo
 */
typedef TiledMapLayer = {
	var data : Array<Int>;
	var name : String;
	var opacity : Float;
	var chunks : Array<TiledChunkData>;
	var objects : Array<{ x: Int, y : Int, name : String, type : String }>;
}

/**
 * map related data, stuff like a map's width and height or more technical things like layers and their info or which render order is used
 * 
 * 
 */
typedef TiledMapData = { 
	/** map width, becomes chunk width in infinite maps. */
	var width : Int;
	/** map height, becomes chunk height in infinite maps. */
	var height : Int;
	/** get the info from a specified layer see `TiledMapLayer`. */
	var layers : Array<TiledMapLayer>;
	/** get the info from a specified tileset see `TiledTilesetData`. */
	var tilesets : Array<TiledTilesetData>;
	/** is it an infinite map? */
	var infinite: Bool;
	/** the width of a tile in the map */
	var tileWidth : Int;
	/** the width of a tile in the map */
	var tileHeight : Int;

	//=-UNIMPLEMENTED/SOONtm-=\\
	//var renderOrder
}

/**
 * note: this is only the reader for .tmx format, you're going to have to do the rendering part yourself.
 * 
 * tiled tmx map file reader, can find and import .tmx files without needing to export to another format
 * 
 * supports both normal and infinte maps
 * 
 * currently lacks support for a bunch of things namely, isomatric and hexagonal maps
 * 
 * supports all compression types with exception of zstandard
 * 
 * zlib compression is recommended due to its speed but you can use the default csv setting if you don't care and just expect it to work
 */
class TiledMap extends Resource {

	/**
	 * convert the tiled map data to a readable format, in this case a typedef of typedefs
	 */
	public function toMap() : TiledMapData {
		var data = entry.getText();
		var x = new Access(Xml.parse(data).firstElement());
		var layers = [];
		var tilesets = [];
		var layerdata:Array<Int> = []; //to replace data since it changes constantly, and its not supposed to do that

		//=-COMPRESSION TYPE READING-=\\
		var encoding:String = x.nodes.layer[0].node.data.att.encoding;
		var compression:String = if (x.nodes.layer[0].node.data.has.compression) x.nodes.layer[0].node.data.att.compression else null;

		for( l in x.nodes.layer ) {
			if(Std.parseInt(x.att.infinite) != 0){//if the map is infinite
				//=-CHUNK DATA-=\\
				var chunkinfo = []; //the info in a chunk, such as xy and width height
				var chunkdata:Array<Int> = []; //the data inside a given chunk
				for (c in 0...l.node.data.nodes.chunk.length){
					//trace(l.node.data.nodes.chunk.length);
					chunkdata = []; //reset the chunkdata before writing to it 
					//layer logic
					//note, this is not an elegant solution, and would probably not some rewrites 
					var data = StringTools.trim(l.node.data.nodes.chunk[c].innerData);
					if (encoding != "csv"){
						var bytes = Decode(data, encoding, compression);
						var input = new haxe.io.BytesInput(bytes);
						//push to layer
						for( i in 0...bytes.length >> 2 )
							chunkdata.push(input.readInt32());
					}
					else{
						var splitdata = data.split(",");
						for( i in 0...splitdata.length){
							chunkdata.push(Std.parseInt(splitdata[i]) );
						}
					}
					//trace(chunkdata);
					chunkinfo.push({
						x: Std.parseInt(l.node.data.nodes.chunk[c].att.x),
						y: Std.parseInt(l.node.data.nodes.chunk[c].att.y),
						width: Std.parseInt(l.node.data.nodes.chunk[c].att.width),
						height: Std.parseInt(l.node.data.nodes.chunk[c].att.height),
						data : chunkdata
					});
				}
				layers.push( {
					name : l.att.name,
					opacity : l.has.opacity ? Std.parseFloat(l.att.opacity) : 1.,
					objects : null, //i'm not sure what this even does
					data : null,
					chunks : chunkinfo //it has already been pushed by the push above it
				});
				chunkinfo = []; //reset the final data, as its no longer final
				//trace(layers);
			}
			else{//if its a normal map
				var data = StringTools.trim(l.node.data.innerData);
				if (encoding != "csv"){
					var bytes = Decode(data, encoding, compression);
					var input = new haxe.io.BytesInput(bytes);
					//push to layer
					for( i in 0...bytes.length >> 2 )
						layerdata.push(input.readInt32());
				}
				else{
					var splitdata = data.split(",");
					for( i in 0...splitdata.length){
						layerdata.push(Std.parseInt(splitdata[i]) );
					}
				}
				layers.push( {
					name : l.att.name,
					opacity : l.has.opacity ? Std.parseFloat(l.att.opacity) : 1.,
					objects : [],
					data : layerdata,
					chunks : null
				});
			}

			layerdata = []; //reset the layerdata since its been already pushed for that layer
		}
		//=-OBJECT PARSING-=\\ =-BUGGED-=
		//this for some reason pushes objectdata as a layer despite it not being a layer, perhaps it changed at some point?
		for( l in x.nodes.objectgroup ) {
			var objs = [];
			for( o in l.nodes.object ) // this doesn't push a typedef, but just object list, doesn't support templates either 
				if( o.has.name )
					objs.push( { name : o.att.name, type : o.has.type ? o.att.type : null, x : Std.parseInt(o.att.x), y : Std.parseInt(o.att.y) } );
			layers.push( {
				name : l.att.name,
				opacity : 1., //value is static?
				objects : objs,
				data : null, //intended since it doesn't add data
				chunks : null
			});
		}
		//=-TILESET PARSING-=\\
		for (t in x.nodes.tileset){
			var tileTypes = [];
			var fullpath = (entry.directory + "/" + t.att.source);
			var setdata = hxd.Res.load(fullpath).entry.getText();
			var tsx = new Access(Xml.parse(setdata).firstElement()); //vscode complains about "local variable setdata used without being initialized", despite it being initialized, vshaxe for some reason starts shitting itself on this repo, and i have no idea why
			if (tsx.hasNode.tile){
				for(t in 0...tsx.nodes.tile.length){
					tileTypes.push({ id: Std.parseInt(tsx.nodes.tile[t].att.id), type: tsx.nodes.tile[t].att.type});
				}
			}
			//in theory, nobody should ever have a filename start or end with ../, it could conflict if a file just so happend to be called ../something.png, but like if you can name a file that way, you should probably seek help
			//hxd.res.load can't find the path if it starts in the same folder and or uses ../, so the following is a semi functional workaround
			var trimmedsource = if (StringTools.startsWith(tsx.node.image.att.source, "../")) tsx.node.image.att.source.substring(3) else entry.directory + "/" + tsx.node.image.att.source;
			while (StringTools.startsWith(trimmedsource, "../" ) ) //this is probably stupid, but it needs to be done
				trimmedsource = tsx.node.image.att.source.substring(3);

			tilesets.push({
					tileWidth: Std.parseInt(tsx.att.tilewidth),
					tileHeight: Std.parseInt(tsx.att.tileheight), 
					tileCount: Std.parseInt(tsx.att.tilecount),
					columns: Std.parseInt(tsx.att.columns),
					name: tsx.att.name,
					source: trimmedsource,
					firstgid: Std.parseInt(t.att.firstgid),
					margin: tsx.has.margin ? Std.parseInt(tsx.att.margin) : 0,
					spacing: tsx.has.spacing ? Std.parseInt(tsx.att.spacing) : 0,
					offsetX: tsx.hasNode.tileoffset ? Std.parseInt(tsx.node.tileoffset.att.x) : 0,
					offsetY: tsx.hasNode.tileoffset ? Std.parseInt(tsx.node.tileoffset.att.y) : 0,
					tileClasses: tsx.hasNode.tile ? tileTypes : null
					} );
		}
		//=-PRE FINISH TRACE PILE-=\\
		//trace(Std.parseInt(x.att.width));


		return {
			width : Std.parseInt(x.att.width),
			height : Std.parseInt(x.att.height),
			layers : layers,
			tilesets: tilesets,
			tileWidth: Std.parseInt(x.att.tilewidth),
			tileHeight: Std.parseInt(x.att.tileheight),
			infinite: Std.parseInt(x.att.infinite) != 0
		};
	}

	/**
	 * decompresses based on the compression used
	 */
	function Decode(data:String, encoding:String, compression:String){
		//a lot of the methods here are nearly identical,
		//it could probably be simplifyed to just one part instead of splitting it into multiple shites
		var base = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")); //base64 zlib
		var bytes:haxe.io.Bytes = null; //in theory this has no reason to happen

		if (encoding == "base64" && compression == "zlib"){
			while( data.charCodeAt(data.length-1) == "=".code ) //this is designed to trim off the "=" or "==" at the end of most base64 code as it is just padding
				data = data.substr(0, data.length - 1);
			bytes = haxe.io.Bytes.ofString(data);
			bytes = base.decodeBytes(bytes); //intended for decoding zlib compressed base64, should become an option instead of mendatory thing, though it is faster
			bytes = format.tools.Inflate.run(bytes);
		}
		else if (encoding == "base64" && compression == "gzip"){
			while( data.charCodeAt(data.length-1) == "=".code )
				data = data.substr(0, data.length - 1);
			bytes = haxe.io.Bytes.ofString(data);
			bytes = base.decodeBytes(bytes);
			bytes = new format.gz.Reader(new haxe.io.BytesInput(bytes)).read().data;
		}
		else if(encoding == "base64" && compression == "zstd"){
			throw "zstd is not supported by format, and or any haxe library for that matter, please use zlib or gzip instead in the meantime :)";
		}
		else if(encoding == "base64" && compression == null){
			bytes = haxe.io.Bytes.ofString(data);
			bytes = base.decodeBytes(bytes);
		}
		else{//unknown format catching
			throw "that's not a compression format, ensure the data is not corrupted, and no XML is not Supported, its deprecated for a reason.";
		}

		return bytes;
		
	}

	function render(){

	}

	/**
	 * the following function allows you to load a tmx file as a full scene, with all objects in place
	 * 
	 * TODO: add world support, i.e tiled worlds 
	 */
	// function toScene():h2d.Scene{

	// }

}