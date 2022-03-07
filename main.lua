--[[ 
    CODE BY PUZZELISM
    2022
]]--

-- shortcut ops
lg = love.graphics;
lk = love.keyboard;
lm = love.math;

-- version
VERSION = '0.0.2';

-- base config
SHADOW = true;
WIREFRAME = false;
COSINE = false;
MENU = true;

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
        elseif(colorID == 2)then sinColor=random
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
    SPLIT_FACTOR = 50;
    SIN_SCALE = 30;
    MOVE_FACTOR = 1;
    FREQ = 0.25;
    HEIGHT = 40;
    move = MOVE_FACTOR;
        
    -- init arrays
    points = {};
    points2 = {};
end

function love.load()
    love.window.setMode(800, 640, {resizable = true, minwidth=600, minheight=600});
    reload();
end

function love.update(dt)
    -- scaling
    if(lk.isDown("up"))then
        SIN_SCALE = SIN_SCALE + 5;
    elseif(lk.isDown("down"))then
        SIN_SCALE = SIN_SCALE - 5;
    end
    -- frequency
    if(lk.isDown("right"))then
        FREQ = FREQ +(0.005);
    elseif(lk.isDown("left"))then
        FREQ = FREQ - (0.005);
    end

    -- get env variables
    w = lg.getWidth();
    h = lg.getHeight();
    sliceW = w / SPLIT_FACTOR;
    move = move + (MOVE_FACTOR * dt);

    -- update waves
    for x = 0,SPLIT_FACTOR do
        sined = 20+(math.sin(x*FREQ+move)*SIN_SCALE)
        cosined = 20+(math.cos(x*FREQ-move)*SIN_SCALE)
        points[x] = (lg.getHeight()/4)-20 + sined;
        points2[x] = (lg.getHeight()/4)-20 + cosined;
    end
end

function love.keypressed(key)
    if(key == "escape")then love.event.quit()
    elseif(key == "space")then SHADOW = not SHADOW
    elseif(key == "=")then  MOVE_FACTOR = MOVE_FACTOR + 1;
    elseif(key == "-")then MOVE_FACTOR = MOVE_FACTOR - 1;
    elseif(key == "lshift")then WIREFRAME = not WIREFRAME
    elseif(key == "tab")then COSINE = not COSINE
    elseif(key == "lalt")then MENU = not MENU
    elseif(key == "w")then SPLIT_FACTOR = SPLIT_FACTOR + 10;
    elseif(key == "s")then SPLIT_FACTOR = SPLIT_FACTOR - 10;
    elseif(key == "return")then fullscreen = not fullscreen love.window.setFullscreen(fullscreen, fstype)
	elseif(key == "d")then HEIGHT = HEIGHT + 10;
    elseif(key == "a")then HEIGHT = HEIGHT - 10;
    elseif(key == "1")then randomizeColors(1);
    elseif(key == "2")then randomizeColors(2);
    elseif(key == "3")then randomizeColors(3);
    elseif(key == "4")then randomizeColors(4);
    elseif(key == "5")then randomizeColors(5);
    elseif(key == "6")then randomizeColors(6);
    elseif(key == "7")then randomizeColors(7);
    elseif(key == "r")then reload();
    end
end

function love.draw()
    -- graphcis step
    lg.scale(2, 2);
    lg.setBackgroundColor(bgColor);

    -- menu render
    if(MENU)then
        lg.setColor(fontColor);
        lg.print("[UP/DOWN] SCALE: "..SIN_SCALE,0,0);
        lg.print("[+/-] MOVE: "..MOVE_FACTOR,0,16)
        lg.print("[<-/->] FREQ: "..FREQ,0,32);
        lg.print("[A/D] HEIGHT: "..HEIGHT,0,48)
        lg.print("[LSHIFT] WIRE: "..(WIREFRAME and ('['..(cosine and SPLIT_FACTOR*2 or SPLIT_FACTOR)..' NODES, W/S to mod]') or 'LO'), 0, 64)
        lg.print("[TAB] VIEW_COS: "..(COSINE and 'HI' or 'LO'), 0, 80)
        lg.print("FULLSCRN [ENTER]", w/2-120, 16)
        lg.print((SHADOW and 'HI' or 'LO').." SHADOWS [SPACE]", w/2-138, 32)
        lg.print("COLORIZE [1-7][R RESET]", w/2-158, 48)
        
        lg.setColor(versionColor);
        lg.print("v"..VERSION, w/4-20, h/2-50)

        lg.setColor(fontColor)
        lg.printf({shadowColor, "y = SIN(x * ", highlightColor, FREQ, shadowColor, " + ", highlightColor, MOVE_FACTOR, shadowColor, ") * ", highlightColor, SIN_SCALE}, w/4-80, h/2-32, w, center)

        lg.setColor(shadowColor);
        lg.print("made by puzzel 2022", w/4-64, h/2-16)
    end
    lg.setColor(MENU and fontColor or shadowColor)
    lg.print("MENU [ALT]", w/2-74, 0)
    lg.print(love.timer.getFPS().."fps", w/2-40, (MENU and 64 or 16))
    
    -- wave render
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