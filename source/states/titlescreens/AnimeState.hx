package states.titlescreens;

import openfl.filters.ShaderFilter;
import shaders.Glitch;
import states.TitleState.TitleData;

import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import flixel.addons.effects.FlxTrail;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.Assets;
import shaders.ColorSwap;

import states.OutdatedState;

class AnimeState extends TitleBaseplate
{
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var logoBl:FlxSprite;
	var mid:FlxSprite;
	var midtrail:FlxTrail;

	var curWacky:Array<String> = [];

	var titleJSON:TitleData;

	public function new(?TransIn, ?TransOut)
	{
		super("Anime", TransIn, TransOut);
	}

	override public function create():Void
	{
		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		// IGNORE THIS!!!
		titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if (!initialized) {
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (initialized)
			startIntro();
		else
			new FlxTimer().start(1, (_) -> startIntro());
	}

	var titleText:FlxSprite;
	
	var swagShader:Glitch;
	var shaderFilter:ShaderFilter;

	function startIntro()
	{
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		if(ClientPrefs.data.shaders)
		{
			swagShader = new Glitch();
			shaderFilter = new ShaderFilter(swagShader.shader);
		}

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = quickSprite("newgrounds_logo", 0, FlxG.height * 0.52);
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		ngSpr.visible = false;
		add(ngSpr);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

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

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (!closedState && shouldUpdate)
						MusicBeatState.switchState(new OutdatedState());
					else
						MusicBeatState.switchState(new MidMenuState());

					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			swagShader.iTime = Conductor.songPosition / 1500;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen

	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					#if PSYCH_WATERMARKS
					createCoolText(['Vs Mid by'], 40);
					#else
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					#end
				case 4:
					#if PSYCH_WATERMARKS
					addMoreText('Mid', 40);
					addMoreText('and a lot of cool people', 40);
					#else
					addMoreText('Awe Yeah');
					#end
				case 5:
					deleteCoolText();
				case 6:
					#if PSYCH_WATERMARKS
					createCoolText(['Not associated', 'with'], -40);
					#else
					createCoolText(['In association', 'with'], -40);
					#end
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('VS');
				case 15:
					addMoreText('MID');
				case 16:
					addMoreText('V2'); // credTextShit.text += '\nFunkin';

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			var tTween:Float = 1;

			var bg = quickSprite("titlebg");
			bg.scale.set(4, 4);
	
			var mid:FlxSprite = quickSprite("mid", -150);
			mid.scale.set(4, 4);
			
			var logoBl:FlxSprite = quickSprite("logoBumpin", -800);
			logoBl.updateHitbox();
			
			midtrail = new FlxTrail(mid, null, 12, 5, .5);

			remove(ngSpr);
			remove(credGroup);

			add(bg);
			add(mid);
			add(midtrail);
			add(logoBl);

			FlxG.camera.filters = [shaderFilter];

			FlxTween.tween(bg, {"scale.x": 1, "scale.y": 1}, tTween, {ease: FlxEase.cubeOut});
			FlxTween.tween(logoBl, {x: -150}, tTween, {ease: FlxEase.cubeOut, startDelay: tTween});
			FlxTween.tween(mid, {x: 500}, tTween, {ease: FlxEase.cubeOut});
			FlxTween.tween(mid, {"scale.x": 1, "scale.y": 1}, tTween, {ease: FlxEase.quintOut});
			FlxG.camera.flash(FlxColor.WHITE, .5);

			skippedIntro = true;
		}
	}

	override function destroy()
	{
		swagShader.destroy();
		swagShader = null;
		shaderFilter = null;
		super.destroy();
	}
}
