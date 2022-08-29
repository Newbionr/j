local defaultNotePos = {}
local spin = 1
 
function onSongStart()
    for i = 0, 7 do
        defaultNotePos[i] = {
            getPropertyFromGroup('strumLineNotes', i, 'x'),
            getPropertyFromGroup('strumLineNotes', i, 'y')
        }
    end
end

function onCreate()
    makeLuaSprite('credit', 'menu/credits/edition', 30, 600);
    scaleLuaSprite('credit', 0.60, 0.60);
    addLuaSprite('credit');
    setObjectCamera('credit', 'hud');
end

function onUpdate(elapsed)
    local songPos = getPropertyFromClass('Conductor', 'songPosition') / 50
    
    if curStep >= 1792 and curStep < 2048 then
        setProperty("camHUD.angle", spin * math.sin(songPos))
    end
    
    if curStep == 2048 then
        setProperty("camHUD.angle", 0)
    end
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