package objects;

import states.FreeplayState.SongMetadata;

class FreeplaySelection extends FlxSpriteGroup
{
	var box:FlxSprite;
	var name:FlxText;

	var song:SongMetadata;

	public var target:Int = 0;

	// var icon:HealthIcon;

	public function new(x:Float, y:Float, data:SongMetadata)
	{
		song = data;

		super(x, y, 3);

		box = new FlxSprite().loadGraphic(Paths.image("freeplay/songbox"));
		name = new FlxText(0, 0, 0, song.songName, 32);
		name.color = FlxColor.BLACK;
		name.systemFont = Paths.font("Comic Sans MS.ttf");

		name.scale.x = Math.min(1, (box.width - 15) / name.fieldWidth);
		name.draw();

		var midpoint:FlxPoint = box.getGraphicMidpoint();
		name.x = midpoint.x - name.fieldWidth * 0.5;
		name.y = midpoint.y - name.fieldHeight * 0.5;

		add(box);
		add(name);
	}
}