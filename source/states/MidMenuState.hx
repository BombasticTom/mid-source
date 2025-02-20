package states;

import flixel.FlxState;
import states.MidTemplate.PreviousMid;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.math.FlxAngle;

import options.OptionsState;

typedef MidCharacter = {
	var name:String;
	var chance:Float;
	var yOffset:Float;
}

class MidMenuState extends MidTemplate
{
	public static var midVersion:String = '2.0'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var maxAllowed:Bool = false;

	static function newChar(name:String, chance:Float = 1, yOffset:Float = 0.2):MidCharacter
	{
		return {name: name, chance: chance, yOffset: yOffset};
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

	static var characterData:MidCharacter;

	final characterList:Array<MidCharacter> = // Avoid using Dynamic as much as possible!!
	[
		newChar("BOY"),
		newChar("GirlFriend"),
		newChar("Mid"),
		newChar("MYSTI"),
		newChar("HYCMenu", 1, 0),
		newChar("Locas", 1, 0),
		newChar("yaoi", .0025),
		newChar("Mysti_Evil", .005),
		newChar("MDP", .01),
		newChar("GYATFRIEND", .05)
	]; 

	var stunned:Bool = false;

	var credits:FlxSprite;

	var options:Array<FlxSprite> = [];
	var optionsGroup:FlxTypedGroup<FlxSprite>;

	var frisbee:FlxSprite;
	var character:FlxSprite;

	final spriteAngle:Float = 45;
	final xOffset:Float = 41;
	final charX:Float = 920;

	function recalculatePosition(?lockIn:Bool = false) // lock the FLIP in 😹
	{
		var rad:Float = FlxAngle.asRadians(spriteAngle);
		
		var midPoint:FlxPoint = frisbee.getGraphicMidpoint();
		var lerpVal:Float = lockIn ? 0 : Math.exp(-FlxG.elapsed * 9.6);

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

	function selectSequence(selected:FlxSprite, choice:Int = -1)
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		if (choice < 0)
			choice = curSelected;

		FlxFlicker.flicker(selected, 1.0, 0.06, false, false, (flick:FlxFlicker) -> {
			switch(choice)
			{
				case 0:
					MusicBeatState.switchState(new StoryMenuState());
				case 1:
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					coolTween(false,
						(_) -> MusicBeatState.switchState(new MidFreeplay({x: coolBG.x, y: coolBG.y, scale: midLogo.scale.x}))
					);
				case 2:
					MusicBeatState.switchState(new OptionsState());
					OptionsState.onPlayState = false;

					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
				case 3:
					MusicBeatState.switchState(new CreditsState());
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

	override function coolTween(reversed = false, ?complete:TweenCallback)
	{
		var tweenType:FlxTweenType = reversed ? BACKWARD : PERSIST;

		var prevX:Float = frisbee.x;

		if (reversed)
			frisbee.x -= 800;
		else
			prevX -= 500;

		recalculatePosition(true);

		FlxTween.tween(frisbee, {x: prevX}, 1, {
			ease: FlxEase.backInOut,
			onComplete: complete
		});

		FlxTween.tween(character, {y: character.y + 650}, 1, {
			ease: reversed ? FlxEase.sineOut : FlxEase.sineIn,
			type: tweenType
		});
	}

	public function new(bg:PreviousMid = null, refresh = false)
	{
		if (characterData == null || refresh)
			characterData = chooseRandomCharacter();

		super(bg, refresh);
	}

	var sprLooped:Bool = false;

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

		credits = new FlxSprite(0, 0, Paths.image("mainmenu/credits"));
		credits.x = FlxG.width - credits.width * 1.2;
		credits.y = FlxG.height - credits.height * 1.2;

		character = new FlxSprite(FlxG.width * .75, FlxG.height);
		character.frames = Paths.getSparrowAtlas('mainmenu/characters/${characterData.name}');
		character.animation.addByPrefix("idle", "bop", 24, false);

		if (!character.animation.exists("idle"))
		{
			sprLooped = true;
			character.animation.addByPrefix("idle", "idle", 24, true);
			character.animation.play("idle", true);
		}

		character.x -= character.width * .5;
		character.y -= character.height * (1 - characterData.yOffset);

		trace('Current character: ${characterData.name}');

		credits.antialiasing = ClientPrefs.data.antialiasing;
		character.antialiasing = ClientPrefs.data.antialiasing;
		
		addOption("Story Mode", 120);
		addOption("Freeplay", 48);
		addOption("Options", 48);

		changeSelection();

		addNearBG(frisbee);
		addNearBG(optionsGroup);
		addNearBG(character);
		
		add(credits);

		FlxG.mouse.visible = true;

		if (canCoolTween)
			coolTween(true);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var creditsScale:Float = 1;
		var creditsY:Float = 0;

		// KBM CONTROLS

		if (!stunned)
		{
			// KEYBOARD

			if (controls.UI_UP_P)
				changeSelection(-1);

			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.ACCEPT)
			{
				selectSequence(options[curSelected]);
				stunned = true;
			}

			if (controls.BACK)
			{
				stunned = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTransitionableState.skipNextTransIn = true;
				FlxG.camera.fade(FlxColor.BLACK, .5, false, () -> LoadingState.loadAndSwitchState(new TitleState()));
			}

			// MOUSE

			if (FlxG.mouse.overlaps(credits))
			{
				credits.alpha = 1;
				creditsScale = 1.2;

				if (FlxG.mouse.justPressed)
				{
					selectSequence(credits, 3);
					stunned = true;
				}
			}
			else
			{
				credits.alpha = 0.5;
				creditsY = FlxMath.fastSin(curDecBeat) * 10;
			}
		}

		// cool credits effect

		var lerpVal:Float = Math.exp(-elapsed * 9);
		var creditsLerpScale:Float = FlxMath.lerp(creditsScale, credits.scale.x, lerpVal);

		credits.scale.set(creditsLerpScale, creditsLerpScale);
		credits.offset.y = FlxMath.lerp(creditsY, credits.offset.y, lerpVal);

		recalculatePosition();
	}

	override function beatHit():Void
	{
		super.beatHit();

		if (!sprLooped)
			character.animation.play("idle", true);
	}

	override function destroy()
	{
		FlxG.mouse.visible = false;
		super.destroy();
	}
}
