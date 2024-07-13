package states;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxBasic;

typedef PreviousMid = {
	x:Float,
	y:Float
}

class MidTemplate extends MusicBeatState
{
	var coolBG:FlxBackdrop;

	var corner1:FlxSprite;
	var corner2:FlxSprite;
	var midLogo:FlxSprite;

	function createBG(x:Float = 0, y:Float = 0)
	{
		coolBG = new FlxBackdrop(Paths.image("mainmenu/mid"), XY, 12, 12);
		coolBG.setPosition(x, y);
		coolBG.alpha = 0.25;
		coolBG.velocity.set(-100, -100);
	}

	public function new(bg:PreviousMid = null)
	{
		if (bg != null)
			createBG(bg.x, bg.y);

		super();
	}

	override function create()
	{
		bgColor = 0xFFB789E6;

		if (coolBG == null)
			createBG();

		var corner1:FlxSprite = new FlxSprite().loadGraphic(Paths.image("mainmenu/corner1"));

		var corner2:FlxSprite = new FlxSprite(FlxG.width, FlxG.height).loadGraphic(Paths.image("mainmenu/corner2"));
		corner2.x -= corner2.width;
		corner2.y -= corner2.height;

		midLogo = new FlxSprite(75, 10).loadGraphic(Paths.image("mainmenu/vsmid"));

		add(coolBG);
		add(corner1);
		add(corner2);
		add(midLogo);

		super.create();
	}

	function addNearBG(basic:FlxBasic):FlxBasic
	{
		return insert(members.indexOf(coolBG) + 1, basic);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		var scale:Float = FlxMath.lerp(1, midLogo.scale.x, 0.95);
		midLogo.scale.set(scale, scale);

		midLogo.angle = FlxMath.fastCos(curDecBeat) * 10;
	}

	override function beatHit()
	{
		super.beatHit();
		midLogo.scale.set(1.27, 1.27);
	}

	override function destroy():Void
	{
		bgColor = 0xFF000000;
		super.destroy();
	}
}