WIDTH = 600;
HEIGHT = 600;

function love.conf(t)
    t.version = "11.4"

    t.window.title = "SINESTRACTION"

    t.window.width = WIDTH
    t.window.height = HEIGHT
    t.window.minwidth = WIDTH
    t.window.minheight = HEIGHT

    t.window.resizable = true
    t.window.fullscreen = false

    t.window.fullscreentype = "exclusive"
end