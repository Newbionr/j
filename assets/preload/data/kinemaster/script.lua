function onCreate()
    makeLuaSprite('credit', 'menu/credits/kinemaster', 30, 600);
    scaleLuaSprite('credit', 0.60, 0.60);
    addLuaSprite('credit');
    setObjectCamera('credit', 'hud');
end

function onStepHit() 
    if curStep == 1 then
        doTweenY('creditTween1', 'credit', 0, 0.4, 'quartInOut');
    end
    if curStep == 20 then
        doTweenY('creditTween2', 'credit', 700, 1, 'quartInOut');
    end
    if curStep == 30 then
        removeLuaSprite('credit');
    end
end