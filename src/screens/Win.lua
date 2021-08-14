local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local WinScreen = {}

function WinScreen.new()
  local self = Screen.new()

  local push = require("lib.push")

  local music = {}
  local image = {}

  function self:init()
    image = love.graphics.newImage("assets/win.png")
    love.audio.stop(Music)
    Music = love.audio.play(MUSIC.WIN, "static", true)
  end

  function self:update()
    Input:update()
    if Input:pressed("jump") then
      love.audio.stop(music)
      ScreenManager.switch("splash")
    end
  end

  function self:draw()
    push:start()
    love.graphics.draw(image)
    push:finish()
  end

  return self
end
return WinScreen

