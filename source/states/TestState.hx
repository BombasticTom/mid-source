package states;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import openfl.Assets;
import flixel.FlxBasic;
import flixel.math.FlxRect;
import openfl.events.Event;
import openfl.Lib;
import objects.Character;
import lime.app.Application;
import lime.ui.Window;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

class CharacterWindowUtil extends FlxBasic
{
	public var activeWindows:Array<CharacterWindowSprite> = [];
	final mainWindow:Window = Lib.application.window;

	public function new()
	{
		super();

		kill();

		trace("initializing");
		FlxG.autoPause = false;

		mainWindow.onClose.add(clearWindows);
		FlxG.state.add(this);
	}

	private function clearWindows()
	{
		trace("Closing all windows..");

		for (theWindow in activeWindows)
		{
			theWindow.window.close();
		}

		activeWindows = [];

		trace("All windows terminated.");

		Paths.clearUnusedMemory();
	}

	override function destroy()
	{
		trace("buhbyeee");

		if (mainWindow.onClose.has(clearWindows))
			mainWindow.onClose.remove(clearWindows);

		clearWindows();

		super.destroy();
	}

	public function create(?character:Character):CharacterWindowSprite
	{
		var spr = new CharacterWindowSprite(character);
		activeWindows.push(spr);

		return spr;
	}
}

class CharacterWindowSprite
{
	public var window:Window;

	private var character:Character;
	private var windowSprite:Sprite = new Sprite();
	private var container:Sprite = new Sprite();

	public function new(?character:Character)
	{
		if (character != null)
			setup(character);
	}

	public function setup(character:Character, x:Int = -10, width:Int = 500, height:Int = 500):CharacterWindowSprite {
		var y:Int = Std.int(Application.current.window.display.currentMode.height / 2);

		window = Lib.application.createWindow({
			title: character.curCharacter,
			x: x,
			y: y,
			width: width,
			height: height,
			borderless: false
		});

		if (character != null)
			character.visible = false;

		this.character = character;

		// windowSprite.graphics.clear();
		// windowSprite.graphics.beginBitmapFill(character.pixels, new Matrix());
		// windowSprite.graphics.drawRect(0, 0, character.pixels.width, character.pixels.height);
		// windowSprite.graphics.endFill();

		container.addChild(windowSprite);
		window.stage.addChild(container);

		Application.current.window.focus();

		return this;
	}

	@:noCompletion
	var REMOVE_LISTENER:Bool = false;

	private function updateSprite(event:Event)
	{

	}
}

class TestState extends MusicBeatState
{
	var dad:Character;
	var bf:Character;

	var windowManager:CharacterWindowUtil;

	var windowDad:CharacterWindowSprite;
	var windowBF:CharacterWindowSprite;

	override function create()
	{
		dad = new Character(0, 0, "dad");
		dad.screenCenter();

		bf = new Character(0, 0);
		bf.screenCenter();

		windowManager = new CharacterWindowUtil();

		super.create();

		add(dad);
		add(bf);

		new FlxTimer().start(1, (_:FlxTimer) -> {
			windowBF = windowManager.create(bf);
			windowDad = windowManager.create(dad);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			FlxG.resetState();
		}
		if (controls.BACK)
			MusicBeatState.switchState(new MidMenuState());
	}
} 