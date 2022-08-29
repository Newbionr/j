function onCreate()
	dodged = false;
    candodge = false;
    time = 0;
	
    precacheImage('error');
	precacheSound('mouse-effect');
end

function onEvent(name, value1, value2)
    if name == "errorEvent" then
    time = (value1);

	makeAnimatedLuaSprite('error', 'error', math.random(1000), math.random(650));
    luaSpriteAddAnimationByPrefix('error', 'error', 'error', 24, true);
	luaSpritePlayAnimation('error', 'error');
	setObjectCamera('error', 'other');
	scaleLuaSprite('error', 0.80, 0.80); 
    addLuaSprite('error', true); 

	candodge = true;
	runTimer('Died', time);
	
	end
end

function onUpdate()
   if candodge == true and keyJustPressed('space') then
   
   dodged = true;
   playSound('mouse-effect', 0.7);
   triggerEvent('Add Camera Zoom','0.020');
   triggerEvent('Play Animation','dodge','1');
   removeLuaSprite('error');
   candodge = false
   
   end
end

function onTimerCompleted(tag, loops, loopsLeft)
   if tag == 'Died' and dodged == false then
   setProperty('health', 0);
   
   elseif tag == 'Died' and dodged == true then
   dodged = false
   
   end
end