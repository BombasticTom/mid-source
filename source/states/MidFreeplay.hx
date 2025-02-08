package states;

import objects.AttachedSprite;
import objects.FreeplaySelection;
import haxe.Exception;
import backend.Song;
import backend.Highscore;
import objects.HealthIcon;
import flixel.group.FlxGroup;
import states.FreeplayState.SongMetadata;
import backend.WeekData;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;

class MidFreeplay extends MidTemplate
{
	var stunned:Bool = false;

	var score:Int = 0;
	var rating:Float = 0.0;

	var curSelected:Int = 0;
	var curDifficulty:Int = -1;

	var lerpScore:Float = 0.0;
	var lerpRating:Float = 0.0;
	var lerpSelected:Float = 0.0;

	var songList:Array<SongMetadata> = [];

	// Code for da highscore

	var highscoreGroup:FlxSpriteGroup;

	var highscoreBox:FlxSprite;
	var highscoreTxt:FlxText;

	// Code for them freaking difficulties!!

	var difficultyGroup:FlxSpriteGroup;

	var difficultyBox:FlxSprite;
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	// This shows up when no shit found 😹😹

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	// Song select shenanigans

	var songGroup:FlxTypedGroup<FreeplaySelection>;
	var stupidChudIcon:AttachedSprite;
	final chudOrigin:Float = -125;

	static var lastDifficultyName:String = Difficulty.getDefault();

	public static var vocals:FlxSound = null;

	final songCoords:FlxPoint = new FlxPoint(FlxG.width - 70, 500);
	final songOffsets:FlxPoint = new FlxPoint(-100, 156);

	var difficultyTween:FlxTween;

	var scrollMenu:FlxSound;

	override function create()
	{
		// Assets preloading code
		WeekData.reloadWeekFiles(false);

		scrollMenu = FlxG.sound.load(Paths.sound('scrollMenu'), 0.4);

		for (i => weekName in WeekData.weeksList) {
			var week:WeekData = WeekData.weeksLoaded.get(weekName);

			if(weekIsLocked(week))
				continue;

			WeekData.setDirectoryFromWeek(week);

			for (song in week.songs)
				addSong(song[0], i, song[1], -7179779);
		}

		// Prevents crashing if no song was found
		if (songList.length < 1)
			addSong("test", 0, "bf", -7179779);

		Mods.loadTopMod();

		var arrow:FlxGraphic = Paths.image("freeplay/arrow");

		super.create();

		PlayState.isStoryMode = false;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		songGroup = new FlxTypedGroup<FreeplaySelection>();

		for (i => song in songList)
		{
			var songText:FreeplaySelection = new FreeplaySelection(300, 300, song);
			songText.target = i;

			songText.kill();
			songGroup.add(songText);

			Mods.currentModDirectory = song.folder;
		}

		WeekData.setDirectoryFromWeek();

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		// Flipping highscore code!

		highscoreBox = new FlxSprite(0, 0, Paths.image("freeplay/highscorebox"));

		highscoreTxt = new FlxText(0, 0, highscoreBox.width);
		highscoreTxt.setFormat(Paths.font("Comic Sans MS.ttf"), 32, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		highscoreTxt.text = "wowie zowie";
		highscoreTxt.x = highscoreBox.width * 0.5 - highscoreTxt.width * 0.5;
		highscoreTxt.y = highscoreBox.height * 0.75 - highscoreTxt.frameHeight * 0.5;
		highscoreTxt.borderSize = 2.5;
		highscoreTxt.alignment = CENTER;

		highscoreGroup = new FlxSpriteGroup(FlxG.width - (highscoreBox.width + 40));
		highscoreGroup.add(highscoreBox);
		highscoreGroup.add(highscoreTxt);

		// Freaking difficulty code!

		difficultyBox = new FlxSprite(0, 0, Paths.image("freeplay/difficultybox"));

		difficulty = new FlxSprite(0, difficultyBox.height * 0.7);

		leftArrow = new FlxSprite(0, difficulty.y).loadGraphic(arrow);
		leftArrow.angle = -15;
		leftArrow.updateHitbox();
		leftArrow.offset.set(leftArrow.width, leftArrow.height * 0.5);
		leftArrow.flipX = true;

		rightArrow = new FlxSprite(0, difficulty.y).loadGraphic(arrow);
		rightArrow.angle = 15;
		rightArrow.offset.y = rightArrow.height * 0.5;

		difficultyGroup = new FlxSpriteGroup(highscoreBox.x - (difficultyBox.width + 70));
		difficultyGroup.add(difficultyBox);
		difficultyGroup.add(difficulty);
		difficultyGroup.add(leftArrow);
		difficultyGroup.add(rightArrow);

		var stupidChudGraphic = Paths.image("icons/icon-bf");
		stupidChudIcon = new AttachedSprite();
		stupidChudIcon.loadGraphic(stupidChudGraphic, true, Std.int(stupidChudGraphic.width / 2));
		stupidChudIcon.xAdd = chudOrigin;

		// Missingno!

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("Comic Sans MS.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;

		songCoords.x -= songGroup.members[0].width;

		add(songGroup);

		add(difficultyGroup);
		add(highscoreGroup);
		add(stupidChudIcon);

		add(missingTextBG);
		add(missingText);

		changeSelection(0, true);
		playDifficultyTween(lastDifficultyName);

		if (canCoolTween)
			coolTween(true);

		persistentUpdate = true;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songList.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(week:WeekData):Bool
	{
		return (!week.startUnlocked && week.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(week.weekBefore) || !StoryMenuState.weekCompleted.get(week.weekBefore)));
	}

	inline private function _updateSongLastDifficulty()
	{
		songList[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	function changeSelection(by:Int = 0, muteSound:Bool = false)
	{
		var curSong:SongMetadata = songList[curSelected];
		var lastList:Array<String> = Difficulty.list;

		curSong.lastDifficulty = Difficulty.getString(curDifficulty);

		curSelected += by;
		dirtyRender = (curSelected < 0 || curSelected >= songList.length);
		curSelected = (curSelected + songList.length) % songList.length;

		curSong = songList[curSelected];
		var curSprite:FreeplaySelection = songGroup.members[curSelected];

		stupidChudIcon.sprTracker = curSprite;

		if (!muteSound)
			scrollMenu.play(true);

		Mods.currentModDirectory = curSong.folder;
		PlayState.storyWeek = curSong.week;
		Difficulty.loadFromWeek();

		var savedDiff:String = curSong.lastDifficulty;
		final defaultDiff:String = Difficulty.getDefault();

		var savedIDX:Int = Difficulty.list.indexOf(savedDiff);
		var lastIDX:Int = Difficulty.list.indexOf(lastDifficultyName);
		var defaultIDX:Int = Difficulty.list.indexOf(defaultDiff);

		if(savedIDX > -1 && !lastList.contains(savedDiff))
			curDifficulty = savedIDX;
		else if (lastIDX > -1)
			curDifficulty = lastIDX;
		else if (defaultIDX > - 1)
			curDifficulty = defaultIDX;
		else
			curDifficulty = 0;

		changeDiff(0, true);
		renderSongs();
	}

	function playDifficultyTween(name:String)
	{
		difficulty.loadGraphic(Paths.image('freeplay/difficulties/${name.toLowerCase()}'));

		difficulty.x = difficultyBox.getGraphicMidpoint().x - difficulty.width * 0.5;
		difficulty.offset.y = difficulty.height * 0.5 + 15;
		difficulty.alpha = 0;

		leftArrow.x = difficulty.x - 15;
		rightArrow.x = difficulty.x + difficulty.width + 15;
		
		if (difficultyTween != null)
			difficultyTween.cancel();

		difficultyTween = FlxTween.tween(difficulty, {"offset.y": difficulty.offset.y - 15, alpha: 1}, 0.07);
	}

	function changeDiff(change:Int = 0, muteSound:Bool = false)
	{
		curDifficulty = (curDifficulty + change + Difficulty.list.length) % Difficulty.list.length;

		if (!muteSound && Difficulty.list.length > 1)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		#if !switch
		var songName:String = songList[curSelected].songName;
		score = Highscore.getScore(songName, curDifficulty);
		rating = Highscore.getRating(songName, curDifficulty);
		#end

		var newDifficulty:String = Difficulty.getString(curDifficulty);

		if (newDifficulty != lastDifficultyName)
			playDifficultyTween(newDifficulty);

		lastDifficultyName = newDifficulty;

		var isVisible:Bool = (Difficulty.list.length > 1);

		leftArrow.visible = isVisible;
		rightArrow.visible = isVisible;

		missingText.visible = false;
		missingTextBG.visible = false;

		_updateSongLastDifficulty();
	}

	var _leftDrawDistance:Int = 4;
	var _rightDrawDistance:Int = 2;

	function renderSongs(?selection:Int)
	{
		selection = selection ?? curSelected;

		var min:Int = Math.round(FlxMath.bound(selection - _leftDrawDistance, 0, songList.length));
		var max:Int = Math.round(FlxMath.bound(selection + _rightDrawDistance, 0, songList.length));

		for (song in songGroup.members)
		{
			var idx:Int = songGroup.members.indexOf(song);
			if (idx >= min && idx <= max)
				song.revive();
			else
				song.kill();
		}
	}

	/**
		Activates when all sprites are needed at once
	**/
	var dirtyRender:Bool = false;

	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));

		if (dirtyRender)
		{
			var roundLerp:Int = Math.round(lerpSelected);

			renderSongs(roundLerp);

			if (roundLerp == curSelected)
				dirtyRender = false;
		}

		songGroup.forEachAlive((song:FreeplaySelection) -> {
			var yPos:Float = (song.target - lerpSelected);
			song.x = songCoords.x + yPos * songOffsets.x;
			song.y = songCoords.y + yPos * songOffsets.y;
		});
	}

	public static function destroyFreeplayVocals() {
		if (vocals != null) {
			vocals.stop();
			vocals.destroy();
			vocals = null;
		}
	}

	override function update(elapsed:Float):Void
	{
		lerpScore = Math.floor(FlxMath.lerp(score, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(rating, lerpRating, Math.exp(-elapsed * 12));

		stupidChudIcon.xAdd = chudOrigin + FlxMath.fastCos(curDecBeat) * 20;

		if (Math.abs(lerpScore - score) <= 10)
			lerpScore = score;

		if (Math.abs(lerpRating - rating) <= 0.01)
			lerpRating = rating;

		if (!stunned)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);

			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.UI_LEFT_P)
				changeDiff(-1);

			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (controls.ACCEPT)
			{
				persistentUpdate = false;

				var songPath:String = Paths.formatToSongPath(songList[curSelected].songName);
				var songFile:String = Highscore.formatSong(songPath, curDifficulty);
				trace(songFile);

				try
				{
					PlayState.SONG = Song.loadFromJson(songFile, songPath);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;

					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				}
				catch(e:Exception)
				{
					trace('ERROR! $e');

					var errorStr:String = e.toString();

					if(errorStr.startsWith('[file_contents,assets/data/'))
						errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); // Missing chart

					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);

					missingText.visible = true;
					missingTextBG.visible = true;

					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);

					return;
				}

				FlxG.sound.music.volume = 0;

				LoadingState.loadAndSwitchState(new PlayState());

				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			}

			if (controls.BACK)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.play(Paths.sound('cancelMenu'));
				coolTween(false, (_) -> FlxG.switchState(new MidMenuState({x: coolBG.x, y: coolBG.y, scale: midLogo.scale.x})));
			}
		}

		highscoreTxt.text = '$lerpScore (${Math.round(lerpRating * 100)}%)';

		updateTexts(elapsed);
		super.update(elapsed);
	}

	override function coolTween(reversed = false, ?complete:TweenCallback)
	{
		var tweenType:FlxTweenType = reversed ? BACKWARD : PERSIST;

		FlxTween.tween(difficultyGroup, {y: difficultyGroup.y - difficultyBox.height - 20}, 0.5, {
			ease: FlxEase.backInOut,
			type: tweenType
		});

		FlxTween.tween(highscoreGroup, {y: highscoreGroup.y - highscoreBox.height - 20}, 0.7, {
			ease: FlxEase.backInOut,
			type: tweenType
		});

		FlxTween.tween(songCoords, {x: songCoords.x + 500}, 0.7, {
			ease: FlxEase.backInOut,
			type: tweenType,
			onComplete: complete
		});
	}

	override function destroy()
	{
		super.destroy();

		destroyFreeplayVocals();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
}