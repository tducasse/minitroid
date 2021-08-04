local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local MenuScreen = {}

function MenuScreen.new()
  local self = Screen.new()

  local push = require("lib.push")

  local big = love.graphics.newFont("assets/visitor1.ttf", 14, "mono")
  local medium = love.graphics.newFont("assets/visitor1.ttf", 8, "mono")

  local music = {}

  function self:init()
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
    love.graphics.clear(24 / 255, 20 / 255, 37 / 255, 255 / 255)
    love.graphics.setFont(big)
    love.graphics.printf(
        { { 0, 0, 1, 0.9 }, "minitroid" }, 0, RES_Y / 5, RES_X, "center")
    love.graphics.setFont(medium)
    love.graphics.printf(
        { { 1, 0, 0 }, "press space" }, 0, RES_Y / 2, RES_X, "center")
    love.graphics.printf(
        { { 1, 0, 0 }, "to start" }, 0, RES_Y / 2 + 6, RES_X, "center")
    push:finish()
  end

  return self
end
return MenuScreen
