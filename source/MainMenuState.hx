package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var quadrado:FlxBackdrop;

	var board:FlxSprite;
	var white:BGSprite;
	var kinemaster:BGSprite;

	var funnyKey:Array<FlxKey> = [FlxKey.SIX, FlxKey.NINE];
	var lastKeysPressed:Array<FlxKey> = [];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'credits'
	];

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;
		
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/background'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		quadrado = new FlxBackdrop(Paths.image('menu/quadrados'), 0, 0, true, false);
		quadrado.y -= 80;
		add(quadrado);
		
		quadrado.offset.x -= 0;
		quadrado.offset.y += 0;
		quadrado.velocity.x = 20;

		board = new FlxSprite(-80).loadGraphic(Paths.image('menu/board'));
		board.setGraphicSize(Std.int(board.width * 1.190));
		board.updateHitbox();
		board.screenCenter();
		board.antialiasing = ClientPrefs.globalAntialiasing;
		add(board);

		white = new BGSprite('menu/kinemaster_white', 0, 25, 0.3, 0.3, ['idle'], true);
		white.setGraphicSize(Std.int(white.width * 0.9));
		white.scrollFactor.set();
		white.updateHitbox();
		add(white);

	    kinemaster = new BGSprite('menu/kinemaster_menu', 10, 20, 0.3, 0.3, ['idle'], true);
		kinemaster.setGraphicSize(Std.int(kinemaster.width * 0.9));
		kinemaster.scrollFactor.set();
		kinemaster.updateHitbox();
		add(kinemaster);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin: Made With Kinemaster (DEMO)", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if android
		addVirtualPad(UP_DOWN, A_B); // no editors since idk what will happen honestly
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var finalKey:FlxKey = FlxG.keys.firstJustPressed();
		if(finalKey != FlxKey.NONE) {
			lastKeysPressed.push(finalKey);
			if(lastKeysPressed.length > funnyKey.length)
			{
				lastKeysPressed.shift();
			}
				
			if(lastKeysPressed.length == funnyKey.length)
			{
				var isDifferent:Bool = false;
				for (i in 0...lastKeysPressed.length) {
					if(lastKeysPressed[i] != funnyKey[i]) {
						isDifferent = true;
						break;
					}
				}

				if(!isDifferent) {
					FlxTween.tween(FlxG.camera, {zoom: 2.0}, 0.7, {ease: FlxEase.expoIn});
					FlxG.sound.play(Paths.sound('confirmMenu'));
					PlayState.storyPlaylist = ['funny'];
					PlayState.isStoryMode = false;
				
					var diffic = "";
					
					PlayState.SONG = Song.loadFromJson('funny-hard' , 'funny');
					PlayState.storyWeek = 0;
					PlayState.campaignScore = 0;
		
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.fadeOut();

				}
			}
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxTween.tween(white, {y: 750}, 2.7, {ease: FlxEase.expoInOut});
					FlxTween.tween(kinemaster, {y: 750}, 2.7, {ease: FlxEase.expoInOut});
					FlxTween.tween(board, {x: 700}, 2.7, {ease: FlxEase.expoInOut});

					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1.5, {ease: FlxEase.expoIn});

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.anyJustPressed(debugKeys) #if android || _virtualpad.buttonE.justPressed #end)
			{
				//selectedSomethin = true;
				//MusicBeatState.switchState(new MasterEditorMenu());
				//put
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x += 270;
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
			}
		});
	}
}
