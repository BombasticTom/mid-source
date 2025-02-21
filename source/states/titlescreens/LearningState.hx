package states.titlescreens;

import flixel.input.gamepad.FlxGamepad;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

class LearningState extends TitleBaseplate
{
	var skyLeft:FlxSprite;
	var skyRight:FlxSprite;
	var logo:FlxSprite;
	var characters:FlxSprite;
	var mall:FlxSprite;
	var start:FlxSprite;
	var copyright:FlxSprite;

	public function new(?TransIn, ?TransOut)
	{
		super("Adventure", TransIn, TransOut);
	}

	override function create()
	{
		var liveandlearn = Paths.music("liveandlearn");

		var sky = quickSprite("sky");

		skyLeft = quickSprite("skybad", -FlxG.width);
		skyRight = quickSprite("skygood", FlxG.width);
		characters = quickSprite("characters");

		mall = quickSprite("mall", 0, FlxG.height);
		mall.screenCenter(X);

		logo = quickSprite("logo-large", 0, FlxG.height * .4);
		logo.y -= logo.height * .5;
		logo.screenCenter(X);

		start = quickSprite("start-alt", 0, FlxG.height * .75);
		start.y -= start.height * .5;
		start.screenCenter(X);

		copyright = quickSprite("copyright", FlxG.width * 0.075, FlxG.height * 0.85);

		add(sky);
		add(skyLeft);
		add(skyRight);
		add(mall);

		FlxTransitionableState.skipNextTransOut = true;

		super.create();

		Conductor.bpm = 174;
		FlxG.sound.playMusic(liveandlearn, 1, false);
		FlxG.camera.fade(FlxColor.BLACK, 2, true);
	}

	var stunned:Bool = true;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!stunned && pressedEnter)
		{
			stunned = true;

			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(start, 1.0, 0.06);

			FlxG.camera.fade(FlxColor.BLACK, 1.5, () -> {
				FlxTransitionableState.skipNextTransIn = true;
				MusicBeatState.switchState(new MidMenuState());
			});
		}
	}

	var beatCounter:Int = 0;

	override function beatHit()
	{
		super.beatHit();
		
		beatCounter++;

		switch (beatCounter)
		{
			case 1:
				FlxTween.tween(skyRight, {x: 676}, Conductor.crochet * 5 / 1000, {ease: FlxEase.sineOut});
				FlxTween.tween(skyLeft, {x: 0}, Conductor.crochet * 5 / 1000, {ease: FlxEase.sineOut});
				FlxTween.tween(mall, {y: FlxG.height - mall.height}, Conductor.crochet * 5 / 1000, {ease: FlxEase.sineInOut});
			case 6:
				logo.alpha = 0;
				logo.scale.set(2, 2);
				add(logo);
				FlxTween.tween(logo, {alpha: 1, "scale.x": 1, "scale.y": 1}, Conductor.crochet * 2 / 1000, {ease: FlxEase.quintIn});
			case 8:
				FlxG.camera.flash();
				remove(mall);
				add(characters);
				add(copyright);
				add(start);

				stunned = false;
				FlxFlicker.flicker(start, 0, 1, false);
		}
	}
}