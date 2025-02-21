package states.titlescreens;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;

class SpookyState extends TitleBaseplate
{
	// Borrowed from FunkinCrew/Funkin
	// https://github.com/FunkinCrew/Funkin/blob/main/source/funkin/util/EaseUtil.hx

	public static inline function stepped(steps:Int, ?ease:Float->Float):Float->Float
	{
		return function(t:Float):Float {
		return Math.floor(ease(t) * steps) / steps;
		}
	}
	
	public function new(?TransIn, ?TransOut)
	{
		super("Spooky", TransIn, TransOut);
	}

	final breatheRadius:Float = 10;
	final distance:Float = 20;

	var bf:FlxSprite;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);

		bgColor = 0xFFFF0006;
		super.create();

		var logo = quickSprite("Logo", 0, FlxG.height * 0.4);
		logo.offset.y = logo.height * 0.5;
		logo.screenCenter(X);
		add(logo);

		logo.y -= 20;
		FlxTween.tween(logo, {y: logo.y + 20}, 3, {ease: stepped(16, FlxEase.sineInOut), type: PINGPONG});

		var mid = quickSprite("Mid", FlxG.width * (distance / 100), FlxG.height);
		mid.offset.set(mid.width * 0.5, mid.height * .82);
		add(mid);

		bf = quickSprite("BF", FlxG.width * (1 - distance / 100), FlxG.height);
		bf.x -= bf.width * 0.5;
		bf.y -= bf.height * .8;
		add(bf);

		var begin = quickSprite("Begin", 0, FlxG.height * 0.9);
		begin.y -= begin.height * .5;
		begin.screenCenter(X);
		add(begin);

		mid.y += breatheRadius;
		FlxTween.tween(mid, {y: mid.y - breatheRadius * 2}, 2, {ease: stepped(8, FlxEase.elasticInOut), type: PINGPONG});

		if (!initialized)
			FlxG.camera.fade(0xFFFF0006, 5, true, () -> initialized = true);
	}

	final bfPussyShakeIntensity:Float = .005;
	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var shakeX:Float = FlxG.random.float(-1, 1) * bfPussyShakeIntensity * bf.width;
		var shakeY:Float = FlxG.random.float(-1, 1) * bfPussyShakeIntensity * bf.height;

		bf.offset.x = shakeX * FlxG.scaleMode.scale.x;
		bf.offset.y = shakeY * FlxG.scaleMode.scale.y;

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

		// EASTER EGG

		if (initialized && !transitioning)
		{
			if(pressedEnter)
			{
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.music.fadeOut(1, 0, (_) -> FlxG.sound.music.stop());
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					var nextState:FlxState = (!closedState && shouldUpdate) ? new OutdatedState() : new MidMenuState();
					FlxTransitionableState.skipNextTransIn = true;
					FlxG.camera.fade(FlxColor.BLACK, 1, false, () -> MusicBeatState.switchState(nextState));
					closedState = true;
				});
			}
		}
	}
}