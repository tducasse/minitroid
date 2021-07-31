local Screen = require("lib.screen")
local ScreenManager = require("lib.screen_manager")
local push = require("lib.push")

local SplashScreen = {}

function SplashScreen.new()
  local self = Screen.new()

  function self:update()
    Input:update()
    if Input:pressed("jump") then
      ScreenManager.switch("intro")
    end
    if Input:pressed("cancel") then
      love.event.quit()
    end
  end

  function self:draw()
    push:start()
    love.graphics.printf(
        "press space to start the game", 0, RES_Y / 2, RES_X, "center")
    push:finish()
  end

  return self
end

return SplashScreen
