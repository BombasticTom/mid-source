package states;

import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;

class TitleBaseplate extends MusicBeatState
{
	var initialized(get, set):Bool;
	var closedState(get, set):Bool;
	var shouldUpdate(get, never):Bool;

	function get_initialized():Bool
	{
		return TitleState.initialized;
	}
	function set_initialized(val:Bool)
	{
		TitleState.initialized = val;
		return val;
	}

	function get_closedState():Bool
	{
		return TitleState.closedState;
	}
	function set_closedState(val:Bool)
	{
		TitleState.closedState = val;
		return val;
	}

	function get_shouldUpdate():Bool
	{
		return TitleState.shouldUpdate;
	}

	var themeName:String = "";

	function quickImage(name:String):FlxGraphic
		return Paths.image('$themeName$name');

	function quickSprite(name:String = "NOPHOTODUMBASS", X:Float = 0, Y:Float = 0):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(X, Y);
		spr.loadGraphic(quickImage(name));
		spr.antialiasing = ClientPrefs.data.antialiasing;
		return spr;
	}

	public function new(?name:String, ?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		super(TransIn, TransOut);
		
		if (name != null)
			themeName = 'TitleScreens/$name/';
	}
}