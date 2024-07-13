package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.math.FlxAngle;

import options.OptionsState;

typedef MidCharacter = {
	var name:String;
	var chance:Float;
	var x:Float;
	var y:Float;
}

class MidMenuState extends MidTemplate
{
	public static var midVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var maxAllowed:Bool = false;

	static function newChar(name:String, chance:Float = 1, x:Float = 0, y:Float = 0):MidCharacter
	{
		return {name: name, chance: chance, x: x, y: y};
	}

	function chooseRandomCharacter():MidCharacter
	{
		var exclude:Array<Int> = [];

		for (i => char in characterList)
		{
			if (char.chance == 1)
				continue;

			if (FlxG.random.bool(char.chance * 100))
				return char;

			exclude.push(i);
		}

		return characterList[FlxG.random.int(0, characterList.length - 1, exclude)];
	}

	var characterList:Array<MidCharacter> = // Avoid using Dynamic as much as possible!!
	[
		newChar("HYCMenu"),
		newChar("Locas", 1, 600, 100),
		newChar("Maxwell", 0.05)
	]; 

	var stunned:Bool = false;

	var options:Array<FlxSprite> = [];
	var optionsGroup:FlxTypedGroup<FlxSprite>;

	var frisbee:FlxSprite;
	var character:FlxSprite;	

	final spriteAngle:Float = 45;
	final xOffset:Float = 41;

	function recalculatePosition()
	{
		var rad:Float = FlxAngle.asRadians(spriteAngle);
		
		var midPoint:FlxPoint = frisbee.getGraphicMidpoint();
		var lerpVal:Float = Math.exp(-FlxG.elapsed * 9.6);

		for (i => spr in options)
		{
			var j:Int = i - curSelected;
			// CODE FOR CHANGING SPRITE ANGLE: spr.angle = FlxMath.lerp(spriteAngle*j, spr.angle, lerpVal);
			
			var toX:Float = midPoint.x + FlxMath.fastCos(j * rad) * frisbee.width - spr.width * 0.5;
			var toY:Float = midPoint.y + FlxMath.fastSin(j * rad) * frisbee.height * 0.5 - spr.height * 0.5;

			spr.x = FlxMath.lerp(toX, spr.x, lerpVal);
			spr.y = FlxMath.lerp(toY, spr.y, lerpVal);
		}
	}

	function addOption(name:String, ?xOffset:Float = 0)
	{
		if (optionsGroup == null)
			return;

		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/${name.toLowerCase().replace(" ", "")}'));
		spr.alpha = 0.5;
		spr.offset.x = -xOffset;

		options.push(spr);
		optionsGroup.add(spr);
	}

	function changeSelection(?by:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		// Reconfigure alpha of the previous option
		options[curSelected].alpha = 0.5;

		// Update counter to the new selected option
		curSelected = (curSelected + by + options.length) % options.length;

		var selectedSprite:FlxSprite = options[curSelected];
		selectedSprite.alpha = 1;

		// Fix layering issues
		optionsGroup.clear();
		var isAbove:Bool = curSelected > options.length / 2;

		for (spr in options)
		{
			// Skip if the option we're looking at is the selected one
			if (spr == selectedSprite)
				continue;

			if (isAbove)
				optionsGroup.add(spr);
			else
				optionsGroup.insert(0, spr);
		}

		// Put the current option in front of every other one
		optionsGroup.add(selectedSprite);
	}

	function selectSequence(selected:FlxSprite)
	{
		FlxFlicker.flicker(selected, 1.0, 0.06, false, false, (flick:FlxFlicker) -> {
			switch(curSelected)
			{
				case 0:
					MusicBeatState.switchState(new StoryMenuState());
				case 1:
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					MusicBeatState.switchState(new MidFreeplay({x: coolBG.x, y: coolBG.y}));
				case 2:
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;

					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
			}
		});

		for (spr in options)
		{
			if (spr == selected)
				continue;

			FlxTween.tween(spr, {alpha: 0}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: (_) -> spr.kill()
			});
		}
	}

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = true;
		persistentDraw = true;

		super.create();

		optionsGroup = new FlxTypedGroup<FlxSprite>();

		frisbee = new FlxSprite().loadGraphic(Paths.image("mainmenu/disc"));
		frisbee.setPosition(-frisbee.width / 1.5, FlxG.height - frisbee.height * 0.9);
		frisbee.angularVelocity = 1000;

		var characterData:MidCharacter = chooseRandomCharacter();
		character = new FlxSprite(characterData.x, characterData.y);
		character.frames = Paths.getSparrowAtlas('mainmenu/characters/${characterData.name}');
		character.animation.addByPrefix("idle", "bop", 24, false);

		trace('Current character: ${characterData.name}');

		midLogo = new FlxSprite(75, 10).loadGraphic(Paths.image("mainmenu/vsmid"));

		addOption("Story Mode", 120);
		addOption("Freeplay", 48);
		addOption("Options", 48);

		changeSelection();

		addNearBG(frisbee);
		addNearBG(optionsGroup);
		addNearBG(character);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!stunned)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);

			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectSequence(options[curSelected]);
				stunned = true;
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new TitleState());
			}
		}

		recalculatePosition();
	}

	override function beatHit():Void
	{
		super.beatHit();
		character.animation.play("idle", true);
	}
}
