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
lms = love.mouse;

-- version
VERSION = "1.0.0";

--colors
function resetColors()
    bgColor = {0.05, 0.05, 0.05}
    fontColor = {1, 1, 1}
    versionColor = {1, 1, 0}
    highlightColor = {0.5, 0.5, 1}
end

function randColor(offset)
    if(offset == nil) then
        offset = 0;
    end
    random = {lm.random()+offset, lm.random()+offset, lm.random()+offset}
    return random
end

-- return the shadow of a given color
function getShadow(color)
    return {color[1]-0.3, color[2]-0.3, color[3]-0.3}
end

function addWave()
    temp = randColor();
    WAVES[NUM_WAVES+1] = {
        SHADOW = true,
        WIREFRAME = false,
        SPLIT_FACTOR = 50,
        SIN_SCALE = 30,
        MOVE_FACTOR = 2,
        FREQ = 0.25,
        HEIGHT = 20,
        OFFSET = 20,
        HOVER = false,
        sliceW = 0,
        move = 0,
        color = temp,
        shadowColor = getShadow(temp),
        points = {}
    }

    NUM_WAVES = NUM_WAVES + 1;
    SEL = NUM_WAVES
end

function reload()
    resetColors()
    -- important variables
    NUM_WAVES = 1;
    SEL = 1;
    WAVES = {
        {
            SHADOW = true,
            WIREFRAME = false,
            SPLIT_FACTOR = 50,
            SIN_SCALE = 30,
            MOVE_FACTOR = 2,
            FREQ = 0.25,
            HEIGHT = 20,
            OFFSET = 20,
            HOVER = false,
            sliceW = 0,
            move = 0,
            color = {1,1,1},
            shadowColor = {0.5,0.5,0.5},
            points = {}
        },
    }

    AUDIO_TIMER_MAX = 25;
    TITLE = true;
    AUDIO_TIMER = AUDIO_TIMER_MAX;
    VOL = 0.05;

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
    titleSplash = lg.newImage("res/splash.png")
    font = lg.setNewFont("res/Pixellari.ttf", 16)
    font:setFilter("linear", "nearest")
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
    love.window.setMode(600, 600, {resizable = true, minwidth=600, minheight=600});
    reload(); -- configure variables
end

function love.update(dt)
    -- mouse controls
    mouseX = lms.getX()/2;
    mouseY = lms.getY()/2;

    -- scaling
    if(not TITLE)then
        if(lk.isDown("up"))then
            WAVES[SEL].SIN_SCALE = WAVES[SEL].SIN_SCALE + 2;
            playSelect(synthSnd)
        elseif(lk.isDown("down"))then
            WAVES[SEL].SIN_SCALE = WAVES[SEL].SIN_SCALE - 2;
            playSelect(synthSnd)
        end
        -- frequency
        if(lk.isDown("right"))then
            WAVES[SEL].FREQ = WAVES[SEL].FREQ +(0.005);
            playSelect(synthSnd)
        elseif(lk.isDown("left"))then
            WAVES[SEL].FREQ = WAVES[SEL].FREQ - (0.005);
            playSelect(synthSnd)
        end
    end

    -- get env variables
    w = lg.getWidth();
    h = lg.getHeight();
    

    AUDIO_TIMER = AUDIO_TIMER-1

    -- update waves
    for i = 1,NUM_WAVES do
        WAVES[i].sliceW = w / WAVES[i].SPLIT_FACTOR;
        WAVES[i].move = WAVES[i].move + (WAVES[i].MOVE_FACTOR * dt);
        for x = 0,WAVES[i].SPLIT_FACTOR do
            sined = WAVES[i].OFFSET+(math.sin(x*WAVES[i].FREQ+WAVES[i].move)*WAVES[i].SIN_SCALE)
            WAVES[i].points[x] = (lg.getHeight()/4)-20 + sined;
        end
    end

    -- collision detection for waves (seperate for layering)
    locked = false;
    for i=NUM_WAVES,1,-1 do
        for x=0,WAVES[i].SPLIT_FACTOR do
            if(locked == false)then
            if(mouseX > x*WAVES[i].sliceW and mouseX < x*WAVES[i].sliceW+WAVES[i].sliceW)then
                if(mouseY > WAVES[i].points[x] and mouseY < WAVES[i].points[x]+WAVES[i].HEIGHT)then
                    WAVES[i].HOVER = true;
                    locked = true;
                    if(lms.isDown(1))then SEL = i end
                else
                    WAVES[i].HOVER = false;
                end
            end
            end
        end
    end
end

function love.draw()
    lg.setColor(fontColor)
    lg.scale(2, 2);
    lg.setBackgroundColor(bgColor);

    drawWaves()
    
    if(not TITLE)then  
        if(MENU)then drawMenu() end
        lg.setColor(MENU and fontColor or {0.5,0.5,0.5})
        lg.print("MENU [ALT]", w/2-90, 0)
        lg.setColor(fontColor);
        lg.printf({versionColor, (love.timer.getFPS().."fps")}, w/2-42, (MENU and h/2-16 or 16), 200)
    else drawTitle() end
end

function love.keypressed(key)
    if(TITLE)then
        if(key == "escape")then love.event.quit()
        elseif(key == "space")then TITLE = not TITLE
            MENU = false;
        end
    elseif(not TITLE)then
        playSelect(selectSnd)
        if(key == "escape")then TITLE = not TITLE
        elseif(key == "space")then WAVES[SEL].SHADOW = not WAVES[SEL].SHADOW
        elseif(key == "=")then WAVES[SEL].MOVE_FACTOR = WAVES[SEL].MOVE_FACTOR + 1;
        elseif(key == "-")then WAVES[SEL].MOVE_FACTOR = WAVES[SEL].MOVE_FACTOR - 1;
        elseif(key == "lctrl")then WAVES[SEL].WIREFRAME = not WAVES[SEL].WIREFRAME
        elseif(key == "lalt")then MENU = not MENU
        elseif(key == "w")then WAVES[SEL].SPLIT_FACTOR = WAVES[SEL].SPLIT_FACTOR + 10;
        elseif(key == "s")then WAVES[SEL].SPLIT_FACTOR = WAVES[SEL].SPLIT_FACTOR - 10;
	    elseif(key == "d")then WAVES[SEL].HEIGHT = WAVES[SEL].HEIGHT + 10;
        elseif(key == "a")then WAVES[SEL].HEIGHT = WAVES[SEL].HEIGHT - 10;
        elseif(key == "tab")then addWave();
        -- COLORS
        elseif(key == "1")then bgColor=randColor();
        elseif(key == "2")then 
            WAVES[SEL].color = randColor();
            WAVES[SEL].shadowColor = {WAVES[SEL].color[1]-0.3,WAVES[SEL].color[2]-0.3,WAVES[SEL].color[2]-0.3}
        elseif(key == "3")then WAVES[SEL].shadowColor=randColor();
        elseif(key == "4")then versionColor=randColor(0.2);
        elseif(key == "5")then highlightColor=randColor();
        elseif(key == "r")then reload();
        end
    end
    
    -- fullscreen
    if(key == "return" or key == "f11")then fullscreen = not fullscreen love.window.setFullscreen(fullscreen, fstype) end
end

function love.wheelmoved(x, y)
    if(y > 0)then WAVES[SEL].OFFSET = WAVES[SEL].OFFSET - 5
    elseif(y < 0) then WAVES[SEL].OFFSET = WAVES[SEL].OFFSET + 5
    end
end

function drawMenu()
    lg.setColor(fontColor);
    lg.print("[UP/DOWN] SCALE: "..WAVES[SEL].SIN_SCALE,1,0)
    lg.print("[+/-] MOVE: "..WAVES[SEL].MOVE_FACTOR,1,16)
    lg.print("[</>] FREQ: "..WAVES[SEL].FREQ,1,32)
    lg.print("[A/D] HEIGHT: "..WAVES[SEL].HEIGHT,1,48)
    lg.print("[LCTRL] WIRE: "..(WAVES[SEL].WIREFRAME and ('['..WAVES[SEL].SPLIT_FACTOR..' NODES, W/S to mod]') or 'LO'), 1, 64)
    lg.print("[TAB] NEW WAVE: "..NUM_WAVES, 1, 80)
    lg.print("FULLSCRN [ENTER]", w/2, 16)
    lg.print((WAVES[SEL].SHADOW and 'HI' or 'LO').." SHADOWS [SPACE]", w/2-162, 16)
    lg.print("__COLORS__", w/2-97, 32)
    lg.printf({{bgColor[1]+0.2, bgColor[2]+0.2, bgColor[3]+0.2}, "[1]", WAVES[SEL].color, "[2]", WAVES[SEL].shadowColor, "[3]", versionColor, "[4]", highlightColor, "[5]"}, w/2-98, 48, 200)

    lg.printf({WAVES[SEL].color, "y = ", highlightColor, WAVES[SEL].OFFSET-20, WAVES[SEL].color, " + SIN(x * ", highlightColor, WAVES[SEL].FREQ, WAVES[SEL].color, " + ", highlightColor, WAVES[SEL].MOVE_FACTOR, WAVES[SEL].color, ") * ", highlightColor, WAVES[SEL].SIN_SCALE}, w/4-94, h/2-32, w, center)

    lg.setColor(0.5,0.5,0.5);
    lg.print("made by puzzel 2022", w/4-64, h/2-16)
end

function drawTitle()
    lg.setBackgroundColor(bgColor);
    titleSplash:setFilter("linear", "nearest");
    lg.setColor(WAVES[SEL].color);
    lg.draw(titleSplash, (w/2-titleSplash:getPixelWidth())/2-40, h/15, 0, 1.5, 1.5) --1.5
    lg.print("[SPACE]", w/4-28, h/2-50)
    
    lg.setColor(versionColor);
    lg.print("v"..VERSION, w/4-25, h/15+35);
end

function drawWaves()
    for i=1,NUM_WAVES do
        for x = 0,WAVES[i].SPLIT_FACTOR do
            if(WAVES[i].SHADOW)then
                lg.setColor(WAVES[i].shadowColor);
                lg.rectangle("fill", x*WAVES[i].sliceW+6, WAVES[i].points[x]+2, WAVES[i].sliceW, WAVES[i].HEIGHT);
            end
            lg.setColor(WAVES[i].HOVER and WAVES[i].shadowColor or WAVES[i].color); 
            lg.rectangle((WAVES[i].WIREFRAME and 'line' or 'fill'), x*WAVES[i].sliceW, WAVES[i].points[x], WAVES[i].sliceW, WAVES[i].HEIGHT);
        end
    end
end