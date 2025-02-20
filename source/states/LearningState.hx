package states;

import flixel.input.gamepad.FlxGamepad;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

class LearningState extends MusicBeatState
{
	var skyLeft:FlxSprite;
	var skyRight:FlxSprite;
	var logo:FlxSprite;
	var characters:FlxSprite;
	var mall:FlxSprite;
	var start:FlxSprite;
	var copyright:FlxSprite;

	inline function quickImage(path:String)
		return Paths.image('coolertitlestate/$path');

	override function create()
	{
		// bgColor = 0xFF7E9DAA;

		Conductor.bpm = 174;
		FlxG.sound.playMusic(Paths.music("liveandlearn"), 1, false);

		var sky:FlxSprite = new FlxSprite().loadGraphic(quickImage("sky"));

		skyLeft = new FlxSprite(-FlxG.width).loadGraphic(quickImage("skybad"));
		skyRight = new FlxSprite(FlxG.width).loadGraphic(quickImage("skygood"));
		characters = new FlxSprite().loadGraphic(quickImage("characters"));

		mall = new FlxSprite(0, FlxG.height).loadGraphic(quickImage("mall"));
		mall.screenCenter(X);

		logo = new FlxSprite(0, FlxG.height * .4).loadGraphic(quickImage("logo-large"));
		logo.y -= logo.height * .5;
		logo.screenCenter(X);

		start = new FlxSprite(0, FlxG.height * .75).loadGraphic(quickImage("start-alt"));
		start.y -= start.height * .5;
		start.screenCenter(X);

		copyright = new FlxSprite(FlxG.width * 0.075, FlxG.height * 0.85).loadGraphic(quickImage("copyright"));

		add(sky);
		add(skyLeft);
		add(skyRight);
		add(mall);

		FlxTransitionableState.skipNextTransOut = true;

		super.create();

		FlxG.camera.fade(FlxColor.BLACK, 2, true);
	}

	var stunned:Bool = false;

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

				FlxFlicker.flicker(start, 0, 1, false);
		}
	}

	override function destroy()
	{
		bgColor = FlxColor.BLACK;
		super.destroy();
	}
}