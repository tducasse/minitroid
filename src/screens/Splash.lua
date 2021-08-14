local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local SplashScreen = {}

function SplashScreen.new()
  local self = Screen.new()

  local push = require("lib.push")

  local image = {}

  function self:init()
    image = love.graphics.newImage("assets/splash.png")
    if not (Music.isPlaying and Music:isPlaying()) then
      Music = love.audio.play(MUSIC.MENU, "static", true)
    end
  end

  function self:update()
    Input:update()
    if Input:pressed("jump") then
      ScreenManager.switch("menu")
    end
  end

  function self:draw()
    push:start()
    love.graphics.draw(image)
    push:finish()
  end

  return self
end
return SplashScreen

