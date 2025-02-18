package states;

import flixel.addons.transition.FlxTransitionableState;

class LearningState extends MusicBeatState
{
	var skyLeft:FlxSprite;
	var skyRight:FlxSprite;
	var logo:FlxSprite;
	var characters:FlxSprite;
	var mall:FlxSprite;
	var start:FlxSprite;

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

		logo = new FlxSprite(0, FlxG.height * .4).loadGraphic(quickImage("logo"));
		logo.y -= logo.height * .5;
		logo.screenCenter(X);

		add(sky);
		add(skyLeft);
		add(skyRight);
		add(mall);
		// add(characters);
		// add(logo);

		FlxTransitionableState.skipNextTransOut = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	var beatCounter:Int = 0;

	override function beatHit()
	{
		super.beatHit();
		
		beatCounter++;

		switch (beatCounter)
		{
			case 1:
				FlxTween.tween(skyRight, {x: 676}, Conductor.crochet * 4 / 1000, {ease: FlxEase.sineOut});
				FlxTween.tween(skyLeft, {x: 0}, Conductor.crochet * 4 / 1000, {ease: FlxEase.sineOut});
				FlxTween.tween(mall, {y: FlxG.height - mall.height}, Conductor.crochet * 4 / 1000, {ease: FlxEase.sineInOut});
			case 8:
				FlxG.camera.flash();
				remove(mall);
				add(characters);
				add(logo);
		}
	}

	override function destroy()
	{
		bgColor = FlxColor.BLACK;
		super.destroy();
	}
}