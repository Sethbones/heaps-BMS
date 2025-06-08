package h2d.shader;

//shader code by: TylerGlaiel
//https://www.shadertoy.com/view/csX3RH
//port to hxsl by BoneManSeth
/**
 * in technical terms: what this shader does is the following
 * 
 * when nearest neighbor rendering is done and when scaled, some lines on the screen will get stretched to fit the resolution of the screen,
 * that point is when the shader starts to kick in, the parts that would be stretched are instead filtered, resulting in a sharp image with no visible artifacts
 * 
 * because of this, you can also shrink and rotate stuff without causing the screen to look like a pixely mess
 * 
 * note: this requires the scene to have defaultsmooth enabled, otherwise it does nothing or causes graphical issues
 */
 class PixelArtAA extends hxsl.Shader{
    static var SRC = {
        @:import h3d.shader.Base2d;

        @borrow(h3d.shader.Base2d) var texture: Sampler2D;

        function texture2DAA(uv:Vec2):Vec2 {
            var texsize:Vec2 = texture.size();
            var uv_texspace:Vec2 = uv*texsize;
            var seam:Vec2 = floor(uv_texspace+.5);
            uv_texspace = (uv_texspace-seam)/fwidth(uv_texspace)+seam;
            uv_texspace = clamp(uv_texspace, seam-.5, seam+.5);
            return uv_texspace/texsize;
        }

        function __init__fragment(){
            calculatedUV = texture2DAA(calculatedUV);

        }
    }
}