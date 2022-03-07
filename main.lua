-- code by puzzelism 2022

-- shortcut ops
lg = love.graphics;
lk = love.keyboard;

VERSION = '0.0.1';

-- base config
SHADOW = true;
WIREFRAME = false;
COSINE = false;
MENU = true;

-- colors
bgColor = {0.05, 0.05, 0.05}
sinColor = {1, 1, 1}
cosColor = {1, 0.5, 0.5}

function love.load()
    -- important variables
    SPLIT_FACTOR = 50;
    SIN_SCALE = 30;
    MOVE_FACTOR = 1;
    FREQ = 0.25;
    move = MOVE_FACTOR;
    
    -- init arrays
    points = {};
    points2 = {};
end

function love.update(dt)
    if(lk.isDown("up"))then
        SIN_SCALE = SIN_SCALE + 5;
    elseif(lk.isDown("down"))then
        SIN_SCALE = SIN_SCALE - 5;
    end
    if(lk.isDown("right"))then
        FREQ = FREQ +(0.05 * dt);
    elseif(lk.isDown("left"))then
        FREQ = FREQ - (0.05 * dt);
    end

    w = lg.getWidth();
    h = lg.getHeight();
    sliceW = w / SPLIT_FACTOR;
    move = move + (MOVE_FACTOR * dt);

    for x = 0,SPLIT_FACTOR do
        sined = 20+(math.sin(x*FREQ+move)*SIN_SCALE)
        cosined = 20+(math.cos(x*FREQ-move)*SIN_SCALE)
        points[x] = (lg.getHeight()/4)-20 + sined;
        points2[x] = (lg.getHeight()/4)-20 + cosined;
    end
end

function love.keypressed(key)
    if(key == "escape")then
        love.event.quit()
    elseif(key == "space")then
        SHADOW = not SHADOW
    elseif(key == "=")then 
        MOVE_FACTOR = MOVE_FACTOR + 1;
    elseif(key == "-")then
        MOVE_FACTOR = MOVE_FACTOR - 1;
    elseif(key == "lshift")then
        WIREFRAME = not WIREFRAME
    elseif(key == "tab")then
        COSINE = not COSINE
    elseif(key == "lalt")then
        MENU = not MENU
    elseif(key == "w")then
        SPLIT_FACTOR = SPLIT_FACTOR + 10;
    elseif(KEY == "S")then
        SPLIT_FACTOR = SPLIT_FACTOR - 10;
    end
end

function love.draw()
    -- graphcis step
    lg.scale(2, 2);
    lg.setBackgroundColor(bgColor);

    -- menu render
    if(MENU)then
        lg.setColor(1, 1, 1);
        lg.print("[UP/DOWN] SCALE: "..SIN_SCALE,0,0);
        lg.print("[+/-] MOVE: "..MOVE_FACTOR,0,16)
        lg.print("[<-/->] FREQ: "..FREQ,0,32);
        lg.print("[SPACE] SHADOW: "..(SHADOW and 'HI' or 'LO'),0,48);
        lg.print("[LSHIFT] WIRE: "..(WIREFRAME and ('['..(cosine and SPLIT_FACTOR*2 or SPLIT_FACTOR)..' NODES]') or 'LO'), 0, 64)
        lg.print("[TAB] VIEW_COS: "..(COSINE and 'HI' or 'LO'), 0, 80)
        lg.print(love.timer.getFPS().."fps", w/2-40, 16)
        lg.setColor(1,1,0);
        lg.print("v"..VERSION, w/4-20, h/2-40)
        lg.setColor(0.5,0.5,0.5);
        lg.print("made by puzzel 2022", w/4-64, h/2-16)
    end
    lg.print("MENU [ALT]", w/2-74, 0)
    
    -- wave render
    for i = 0,SPLIT_FACTOR do
        if(COSINE)then
            lg.setColor(cosColor)
            lg.rectangle((WIREFRAME and 'line' or 'fill'), i*sliceW, points2[i], sliceW, 40);
        end
        if(SHADOW)then
            lg.setColor(0.5, 0.5, 0.5);
            lg.rectangle("fill", i*sliceW+4, points[i]+4, sliceW, 40);
        end
        lg.setColor(sinColor);
        lg.rectangle((WIREFRAME and 'line' or 'fill'), i*sliceW, points[i], sliceW, 40);
    end
end