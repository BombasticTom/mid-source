package states;

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
	private var activeWindows:Array<CharacterWindowSprite>;
	private var mainWindow:Window;

	public function new()
	{
		super();

		trace("initializing");

		mainWindow = Lib.current.stage.window;
		activeWindows = [];

		mainWindow.onClose.add(clearWindows);

		FlxG.state.add(this);
	}

	private function clearWindows()
	{
		trace("Closing all windows..");

		for (theWindow in activeWindows)
			theWindow.destroy();

		activeWindows = [];
	}

	override function destroy()
	{
		if (mainWindow.onClose.has(clearWindows))
			mainWindow.onClose.remove(clearWindows);

		clearWindows();

		super.destroy();
	}

	public function create(?character:Character):CharacterWindowSprite
	{
		var spr:CharacterWindowSprite = new CharacterWindowSprite(character);
		activeWindows.push(spr);

		return spr;
	}
}

class CharacterWindowSprite extends FlxBasic
{
	public var window:Window;

	private var windowSprite:Sprite;
	private var character:Character;

	public function new(?character:Character)
	{
		super();

		if (character != null)
			setup(character);
	}

	override function destroy()
	{
		window.close();

		window = null;
		windowSprite = null;

		super.destroy();
	}

	public function setup(character:Character, x:Int = -10, width:Int = 500, height:Int = 500):CharacterWindowSprite {
		var y:Int = Std.int(Application.current.window.display.currentMode.height / 2);

		this.character = character;

		window = Lib.application.createWindow({
			title: character.curCharacter,
			x: x,
			y: y,
			width: width,
			height: height,
			borderless: false
		});

		windowSprite = new Sprite();

		windowSprite.graphics.beginBitmapFill(character.pixels, new Matrix(), false, true);
		windowSprite.graphics.drawRect(0, 0, character.pixels.width, character.pixels.height);
		windowSprite.graphics.endFill();
		windowSprite.scrollRect = new Rectangle();

		window.stage.addChild(windowSprite);
		window.stage.addEventListener(Event.EXIT_FRAME, updateSprite);

		Application.current.window.focus();
		FlxG.autoPause = false;

		if (character != null)
			character.visible = false;

		return this;
	}

	private function updateSprite(event:Event)
	{
		var characterFrame:FlxRect = character.frame.frame;
		
		if (characterFrame != null)
			windowSprite.scrollRect = characterFrame.copyToFlash(windowSprite.scrollRect);
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

		if (controls.BACK)
			MusicBeatState.switchState(new StoryMenuState());
	}
} 