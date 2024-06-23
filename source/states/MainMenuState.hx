package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.math.FlxAngle;
import flixel.addons.display.FlxBackdrop;

import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var stunned:Bool = false;

	var options:Array<FlxSprite> = [];
	var optionsGroup:FlxTypedGroup<FlxSprite>;

	var midLogo:FlxSprite;
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
					MusicBeatState.switchState(new FreeplayState());
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

		bgColor = 0xFFB789E6;

		optionsGroup = new FlxTypedGroup<FlxSprite>();

		var coolBG:FlxBackdrop = new FlxBackdrop(Paths.image("mainmenu/mid"), XY, 12, 12);
		coolBG.alpha = 0.25;
		coolBG.velocity.set(-100, -100);
		
		frisbee = new FlxSprite().loadGraphic(Paths.image("mainmenu/disc"));
		frisbee.setPosition(-frisbee.width / 1.5, FlxG.height - frisbee.height * 0.9);
		frisbee.angularVelocity = 1000;

		var corner1:FlxSprite = new FlxSprite().loadGraphic(Paths.image("mainmenu/corner1"));

		var corner2:FlxSprite = new FlxSprite(FlxG.width, FlxG.height).loadGraphic(Paths.image("mainmenu/corner2"));
		corner2.x -= corner2.width;
		corner2.y -= corner2.height;

		midLogo = new FlxSprite(75, 10).loadGraphic(Paths.image("mainmenu/vsmid"));

		character = new FlxSprite();
		character.frames = Paths.getSparrowAtlas("mainmenu/characters/HYCMenu");
		character.animation.addByPrefix("idle", "bop", 24, false);

		addOption("Story Mode", 120);
		addOption("Freeplay", 48);
		addOption("Options", 48);

		changeSelection();

		add(coolBG);
		add(character);
		add(optionsGroup);
		add(frisbee);
		add(corner1);
		add(corner2);
		add(midLogo);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

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

		var scale:Float = FlxMath.lerp(1, midLogo.scale.x, 0.95);
		midLogo.scale.set(scale, scale);

		midLogo.angle = FlxMath.fastCos(curDecBeat) * 10;
	}

	override function beatHit():Void
	{
		super.beatHit();
		character.animation.play("idle", true);
		midLogo.scale.set(1.27, 1.27);
	}

	override function destroy():Void
	{
		bgColor = 0xFF000000;
		super.destroy();
	}
}
