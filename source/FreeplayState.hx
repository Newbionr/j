package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	// THANK YOU SO MUCH MARIO MADNESS SOURCE CODE 
	// i literally passed 1 week to finish this alone, with a lot of bugs and crashes
	// so, thank you so much for helping me
	
	var tween:FlxTween;
	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	public static var quadrado:FlxBackdrop;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private static var musicas:Array<Dynamic> = [];

	var iconesGrp:FlxTypedSpriteGroup<FlxSprite>;

	var nada:Int = 1;
	var nada2:Bool = false;

	var bg:FlxSprite;
	var desc:FlxText;
    var borda:FlxSprite;

	var box:AttachedSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	public static var vocals:FlxSound = null;

	override function create()
	{
		Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		quadrado = new FlxBackdrop(Paths.image('menu/quadrados'), 0, 0, true, false);
		quadrado.alpha = 0.8;
		quadrado.y -= 80;
		add(quadrado);
		
		quadrado.offset.x -= 0;
		quadrado.offset.y += 0;
		quadrado.velocity.x = 20;

		borda = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/background_freeplay'));
		borda.antialiasing = ClientPrefs.globalAntialiasing;
		borda.setGraphicSize(Std.int(borda.width * 0.8));
		add(borda);
		borda.screenCenter();

		var musicas0:Array<Dynamic> = [
		    ['Kinemaster',	'Kinemaster',  '0',   'FD5B5B'],
		    ['Edition',		'Edition',     '1',   'FD5B5B'],
		    ['Effect',		'Effect',      '2',   'FD5B5B']
	    ];
 
	    var musicas1:Array<Dynamic> = [
		    ['Kinemaster',	'Kinemaster',  '0',   'FD5B5B'],
		    ['Edition',		'Edition',     '1',   'FD5B5B'],
		    ['Effect',		'Effect',      '2',   'FD5B5B'],
		    ['Funny',		'Funny',       '3',   'FFFFFF']
	    ];

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		if (ClientPrefs.funnyPass)
			{
				musicas = musicas1;
			}
        else
			{
				musicas = musicas0;
			}

		iconesGrp = new FlxTypedSpriteGroup<FlxSprite>();
				for (i in 0...musicas.length)
				{
	
					var char:FlxSprite = new FlxSprite(1200 * nada , -210).loadGraphic(Paths.image('menu/freeplay/characters/Char' + musicas[i][2]));
					char.setGraphicSize(Std.int(char.width * 0.6));
					iconesGrp.add(char);

					nada += 1;
					
				}
		add(iconesGrp);

		for (i in 0...musicas.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, musicas[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(musicas[i].songName + ' new scale: ' + textScale);
			}

			Paths.currentModDirectory = musicas[i].folder;
			var icon:HealthIcon = new HealthIcon(musicas[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		box = new AttachedSprite();
		box.makeGraphic(1, 1, FlxColor.BLACK);
		box.xAdd = -10;
		box.yAdd = -10;
		box.alphaMult = 0.6;
		box.alpha = 0.6;
		add(box);
		
		desc = new FlxText(50, 620, 1180, "", 32);
		desc.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.scrollFactor.set();
		desc.updateHitbox();
		desc.screenCenter(X);
		box.sprTracker = desc;
		add(desc);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		#if PRELOAD_ALL
		#if android
		var leText:String = "Press X to listen to the Song / Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#end
		#else
		var leText:String = "Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end

		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		#if android
		addVirtualPad(FULL, A_B_C_X_Y_Z);
		#end

		diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 64);
		diffText.font = scoreText.font;
		add(diffText);

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var travar:Bool = false;

	var instPlaying:Int = -1;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if(!nada2)
			{
				passar();
				nada2 = true;
			}
		
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonX.justPressed #end;
		var ctrl = FlxG.keys.justPressed.CONTROL #if android || _virtualpad.buttonC.justPressed #end;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT #if android || _virtualpad.buttonZ.pressed #end) shiftMult = 3;

		if(musicas.length > 1)
		{
			if (leftP)
			{
				changeSelection(-shiftMult);
				passar();
				holdTime = 0;
				travar = true;
			}
			if (rightP)
			{
				changeSelection(shiftMult);
				passar();
				holdTime = 0;
				travar = true;
			}
			if(controls.ACCEPT) {
			    travar = true;
				FlxTween.tween(FlxG.camera, {zoom: 3.8}, 1, {ease: FlxEase.expoIn});
				FlxG.sound.music.volume = 0;
			    PlayState.SONG = Song.loadFromJson(musicas[curSelected][1], musicas[curSelected][1]);
			    PlayState.campaignScore = 0;
			    PlayState.campaignMisses = 0;
			    LoadingState.loadAndSwitchState(new PlayState());
			    FreeplayState.destroyFreeplayVocals();
	        }
		}

		if (controls.UI_DOWN_P)
		{
		    FlxG.sound.play(Paths.sound('scrollMenu'));
			changeDiff(-1);
		}
		else if (controls.UI_UP_P)
		{
		    FlxG.sound.play(Paths.sound('scrollMenu'));
			changeDiff(1);
		}
		else if (leftP || rightP) changeDiff();

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			#if android
			removeVirtualPad();
			#end
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = musicas[curSelected].folder;
				var poop:String = Highscore.formatSong(musicas[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, musicas[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(musicas[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(musicas[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = musicas.length - 1;
		if (curSelected >= musicas.length)
			curSelected = 0;

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		#if !switch
		intendedScore = Highscore.getScore(musicas[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(musicas[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.4;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		desc.text = musicas[curSelected][0];
		if(moveTween != null) moveTween.cancel();
		box.setGraphicSize(Std.int(desc.width + 20), Std.int(desc.height + 25));
		box.updateHitbox();
		
		Paths.currentModDirectory = musicas[curSelected].folder;
		PlayState.storyWeek = musicas[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	function getCurrentBGColor() {
		var bgColor:String = musicas[curSelected][3];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return musicas[num].length <= 0;
	}

	private function passar()
	{
		switch(curSelected){
			case 0:
				tween = FlxTween.tween(iconesGrp, {x: -1500}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
					{
						travar = false;
					}});
			case 1:
				tween = FlxTween.tween(iconesGrp, {x: -2700}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
					{
						travar = false;
					}});
			case 2:
				tween = FlxTween.tween(iconesGrp, {x: -3900}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
					{
						travar = false;
					}});
			case 3:
				tween = FlxTween.tween(iconesGrp, {x: -5100}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
					{
						travar = false;
					}});
		}
		do {

		} while(unselectableCheck(curSelected));
	}

	
	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
}