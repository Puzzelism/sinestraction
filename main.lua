-- code by puzzelism 2022

function love.load()
    -- important variables
    SPLIT_FACTOR = 50;
    SIN_SCALE = 20;
    MOVE_FACTOR = -1;
    VERSION = '0.0.1';
    
    -- point arrays
    points = {};
    points2 = {};

    idk = 0.1;
end

-- base config
shadow = true;
wireframe = false;
cosine = false;
menu = true;
move = 1;

-- colors
sinColor = {1, 1, 1}
cosColor = {1, 0.5, 0.5}

function love.update(dt)
    if(love.keyboard.isDown("w"))then
        SPLIT_FACTOR = SPLIT_FACTOR + 10
    elseif(love.keyboard.isDown("s"))then
        SPLIT_FACTOR = SPLIT_FACTOR - 10
    end

    w = love.graphics.getWidth();
    h = love.graphics.getHeight();
    sliceW = w / SPLIT_FACTOR;
    move = move + (MOVE_FACTOR * dt);

    for x = 0,SPLIT_FACTOR do
        sined = 20+(math.sin(x*idk+move)*SIN_SCALE)
        cosined = 20+(math.cos(x*idk-move)*SIN_SCALE)
        points[x] = (love.graphics.getHeight()/4)-20 + sined;
        points2[x] = (love.graphics.getHeight()/4)-20 + cosined;
    end

    if(love.keyboard.isDown("up"))then
        SIN_SCALE = SIN_SCALE + 5;
    elseif(love.keyboard.isDown("down"))then
        SIN_SCALE = SIN_SCALE - 5;
    end
    if(love.keyboard.isDown("right"))then
        idk = idk +(0.05 * dt);
    elseif(love.keyboard.isDown("left"))then
        idk = idk - (0.05 * dt);
    end
end

function love.keypressed(key)
    if(key == "escape")then
        love.event.quit()
    elseif(key == "space")then
        shadow = not shadow
    elseif(key == "=")then 
        MOVE_FACTOR = MOVE_FACTOR + 1;
    elseif(key == "-")then
        MOVE_FACTOR = MOVE_FACTOR - 1;
    elseif(key == "lshift")then
        wireframe = not wireframe
    elseif(key == "tab")then
        cosine = not cosine
    elseif(key == "lalt")then
        menu = not menu
    end
end

function love.draw()
    love.graphics.scale(2, 2);
    love.graphics.setBackgroundColor(0.05, 0.05, 0.05);

    if(menu)then
        love.graphics.setColor(1, 1, 1);
        love.graphics.print("[UP/DOWN] SCALE: "..SIN_SCALE,0,0);
        love.graphics.print("[+/-] MOVE: "..MOVE_FACTOR,0,16)
        love.graphics.print("[<-/->] FREQ: "..idk,0,32);
        love.graphics.print("[SPACE] SHADOW: "..(shadow and 'HI' or 'LO'),0,48);
        love.graphics.print("[LSHIFT] WIRE: "..(wireframe and ('['..(cosine and SPLIT_FACTOR*2 or SPLIT_FACTOR)..' NODES]') or 'LO'), 0, 64)
        love.graphics.print("[TAB] VIEW_COS: "..(cosine and 'HI' or 'LO'), 0, 80)
        love.graphics.print(love.timer.getFPS().."fps", w/2-40, 16)
        love.graphics.setColor(1,1,0);
        love.graphics.print("v"..VERSION, w/4-20, h/2-40)
        love.graphics.setColor(0.5,0.5,0.5);
        love.graphics.print("made by STANG 2022", w/4-64, h/2-16)
    end

    love.graphics.print("MENU [ALT]", w/2-74, 0)
    
    -- RENDER
    for i = 0,SPLIT_FACTOR do
        if(cosine)then
            love.graphics.setColor(cosColor)
            love.graphics.rectangle((wireframe and 'line' or 'fill'), i*sliceW, points2[i], sliceW, 40);
        end
        if(shadow)then
            love.graphics.setColor(0.5, 0.5, 0.5);
            love.graphics.rectangle("fill", i*sliceW+4, points[i]+4, sliceW, 40);
        end
        love.graphics.setColor(sinColor);
        love.graphics.rectangle((wireframe and 'line' or 'fill'), i*sliceW, points[i], sliceW, 40);
    end
end