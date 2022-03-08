--[[ 
    CODE BY PUZZELISM
    2022
]]--

-- shortcut ops
lg = love.graphics;
lk = love.keyboard;
lm = love.math;
ls = love.sound;
la = love.audio;

-- version
VERSION = "0.1.1";

--colors
function resetColors() -- ID
    bgColor = {0.05, 0.05, 0.05} -- 1
    sinColor = {1, 1, 1} -- 2
    shadowColor = {0.5, 0.5, 0.5} -- 3
    fontColor = {1, 1, 1} -- 4
    versionColor = {1, 1, 0} -- 5
    highlightColor = {0.5, 0.5, 1} -- 6
    cosColor = {1, 0.5, 0.5} -- 7
end

function randomizeColors(colorID)
    random = {lm.random(), lm.random(), lm.random()}
    if(colorID)then
        if(colorID == 1)then bgColor=random
        elseif(colorID == 2)then 
            sinColor=random
            shadowColor={sinColor[1]-0.3,sinColor[2]-0.3,sinColor[3]-0.3}
        elseif(colorID == 3)then shadowColor=random
        elseif(colorID == 4)then fontColor=random
        elseif(colorID == 5)then versionColor=random
        elseif(colorID == 6)then highlightColor=random
        elseif(colorID == 7)then cosColor=random
        end
    end
end

function reload()
    resetColors()
    -- important variables
    SHADOW = true;
    WIREFRAME = false;
    COSINE = false;
    MENU = true;
    SPLIT_FACTOR = 50;
    SIN_SCALE = 30;
    MOVE_FACTOR = 2;
    FREQ = 0.25;
    HEIGHT = 40;
    AUDIO_TIMER_MAX = 25;
    OFFSET = 20;
    TITLE = true;
    AUDIO_TIMER = AUDIO_TIMER_MAX;
    VOL = 0.05;
    move = MOVE_FACTOR;

    --audio
    la.setVolume(VOL);
    select1 = ls.newSoundData("res/select1.wav")
    select2 = ls.newSoundData("res/select2.wav")
    select3 = ls.newSoundData("res/select3.wav")
    synth1 = ls.newSoundData("res/laser1.wav")
    synth2 = ls.newSoundData("res/laser2.wav")
    synth3 = ls.newSoundData("res/laser3.wav")

    synthSnd = {
        la.newSource(synth1, stream), 
        la.newSource(synth2, stream),
        la.newSource(synth3, stream),
    }
    selectSnd = {
        la.newSource(select1, static),
        la.newSource(select2, static),
        la.newSource(select3, static),
    }

    -- graphics
    titleScreen = lg.newImage("res/title.png")
    titleSplash = lg.newImage("res/splash.png")

    -- init arrays
    points = {};
    points2 = {};
end

function playSelect(sound)
    soundTick = lm.random()
    if(AUDIO_TIMER < 0)then
        if(soundTick < 0.3) then sound[1]:play()
        elseif(soundTick > 0.3 and soundTick < 0.7)then sound[2]:play()
        elseif(soundTick > 0.7)then sound[3]:play()
        end
        AUDIO_TIMER = AUDIO_TIMER_MAX
    end
end

function love.load()
    love.window.setMode(800, 640, {resizable = true, minwidth=600, minheight=600});
    reload();
end

function love.update(dt)
    -- scaling
    if(not TITLE)then
        if(lk.isDown("up"))then
            SIN_SCALE = SIN_SCALE + 5;
            playSelect(synthSnd)
        elseif(lk.isDown("down"))then
            SIN_SCALE = SIN_SCALE - 5;
            playSelect(synthSnd)
        end
        -- frequency
        if(lk.isDown("right"))then
            FREQ = FREQ +(0.005);
            playSelect(synthSnd)
        elseif(lk.isDown("left"))then
            FREQ = FREQ - (0.005);
            playSelect(synthSnd)
        end
    end

    -- get env variables
    w = lg.getWidth();
    h = lg.getHeight();
    sliceW = w / SPLIT_FACTOR;
    move = move + (MOVE_FACTOR * dt);
    AUDIO_TIMER = AUDIO_TIMER-1

    -- update waves
    for x = 0,SPLIT_FACTOR do
        sined = OFFSET+(math.sin(x*FREQ+move)*SIN_SCALE)
        cosined = 10+(-OFFSET)+(math.cos(x*FREQ-move)*SIN_SCALE)
        points[x] = (lg.getHeight()/4)-20 + sined;
        points2[x] = (lg.getHeight()/4)-20 + cosined;
    end
end

function love.draw()
    lg.setColor(fontColor)
    lg.scale(2, 2);
    lg.setBackgroundColor(bgColor);

    drawWaves()
    
    if(not TITLE)then  
        if(MENU)then drawMenu() end
    else drawTitle() end
end

function love.keypressed(key)
    if(TITLE)then
        if(key == "escape")then love.event.quit()
        elseif(key == "space")then TITLE = not TITLE
        end
    elseif(not TITLE)then
        playSelect(selectSnd)
        if(key == "escape")then TITLE = not TITLE
        elseif(key == "space")then SHADOW = not SHADOW
        elseif(key == "=")then MOVE_FACTOR = MOVE_FACTOR + 1;
        elseif(key == "-")then MOVE_FACTOR = MOVE_FACTOR - 1;
        elseif(key == "lshift")then WIREFRAME = not WIREFRAME
        elseif(key == "tab")then COSINE = not COSINE
        elseif(key == "lalt")then MENU = not MENU
        elseif(key == "w")then SPLIT_FACTOR = SPLIT_FACTOR + 10;
        elseif(key == "s")then SPLIT_FACTOR = SPLIT_FACTOR - 10;
	    elseif(key == "d")then HEIGHT = HEIGHT + 10;
        elseif(key == "a")then HEIGHT = HEIGHT - 10;
        -- COLORS
        elseif(key == "1")then randomizeColors(1);
        elseif(key == "2")then randomizeColors(2);
        elseif(key == "3")then randomizeColors(7);
        elseif(key == "4")then randomizeColors(3);
        elseif(key == "5")then randomizeColors(5);
        elseif(key == "6")then randomizeColors(6);
        elseif(key == "r")then reload();
        end
    end
    
    -- fullscreen
    if(key == "return")then fullscreen = not fullscreen love.window.setFullscreen(fullscreen, fstype) end
end

function love.wheelmoved(x, y)
    if(y > 0)then OFFSET = OFFSET - 5
    elseif(y < 0) then OFFSET = OFFSET + 5
    end
end

function drawMenu()
    lg.setColor(fontColor);
    lg.print("[UP/DOWN] SCALE: "..SIN_SCALE,0,0)
    lg.print("[+/-] MOVE: "..MOVE_FACTOR,0,16)
    lg.print("[<-/->] FREQ: "..FREQ,0,32)
    lg.print("[A/D] HEIGHT: "..HEIGHT,0,48)
    lg.print("[LSHIFT] WIRE: "..(WIREFRAME and ('['..(COSINE and SPLIT_FACTOR*2 or SPLIT_FACTOR)..' NODES, W/S to mod]') or 'LO'), 0, 64)
    lg.print("[TAB] VIEW_COS: "..(COSINE and 'HI' or 'LO'), 0, 80)
    lg.print("FULLSCRN [ENTER]", w/2-120, 16)
    lg.print((SHADOW and 'HI' or 'LO').." SHADOWS [SPACE]", w/2-138, 32)
    lg.print("COLORIZE [1-6][R RESET]", w/2-158, 48)
    
    lg.setColor(versionColor);
    lg.print("v"..VERSION, w/4-20, h/2-50)

    lg.setColor(1,1,1,1)
    lg.printf({shadowColor, "y = ", highlightColor, OFFSET-20, shadowColor, " + SIN(x * ", highlightColor, FREQ, shadowColor, " + ", highlightColor, MOVE_FACTOR, shadowColor, ") * ", highlightColor, SIN_SCALE}, w/4-95, h/2-32, w, center)

    lg.setColor(0.5,0.5,0.5);
    lg.print("made by puzzel 2022", w/4-64, h/2-16)

    lg.setColor(MENU and fontColor or shadowColor)
    lg.print("MENU [ALT]", w/2-74, 0)
    lg.print(love.timer.getFPS().."fps", w/2-40, (MENU and 64 or 16))
end

function drawTitle()
    lg.setBackgroundColor(bgColor);
    titleSplash:setFilter("linear", "nearest");
    lg.setColor(sinColor);
    lg.draw(titleSplash, (w/2-titleSplash:getPixelWidth())/2-40, h/15, 0, 1.5, 1.5) --1.5
end

function drawWaves()
    for i = 0,SPLIT_FACTOR do
        if(COSINE)then
            lg.setColor(cosColor)
            lg.rectangle((WIREFRAME and 'line' or 'fill'), i*sliceW, points2[i], sliceW, HEIGHT-5);
        end
        if(SHADOW)then
            lg.setColor(shadowColor);
            lg.rectangle("fill", i*sliceW+6, points[i]+2, sliceW, HEIGHT);
        end
        lg.setColor(sinColor); 
        lg.rectangle((WIREFRAME and 'line' or 'fill'), i*sliceW, points[i], sliceW, HEIGHT);
    end
end