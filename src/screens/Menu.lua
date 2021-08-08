local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local MenuScreen = {}

function MenuScreen.new()
  local self = Screen.new()

  local push = require("lib.push")

  local music = {}
  local menu = {}

  function self:init()
    menu = love.graphics.newImage("assets/menu.png")
    music = love.audio.play("assets/menu.ogg", "static", true)
  end

  function self:update()
    Input:update()
    if Input:pressed("jump") then
      love.audio.stop(music)
      ScreenManager.switch("game")
    end
  end

  function self:draw()
    push:start()
    love.graphics.draw(menu)
    push:finish()
  end

  return self
end
return MenuScreen
