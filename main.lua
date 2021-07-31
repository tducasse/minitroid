local ScreenManager = require("lib.screen_manager")
local baton = require("lib.baton")
local push = require("lib.push")
require("src.globals")
require("lib.audio")

local inspect = require("lib.inspect")
Inspect = function(a)
  print(inspect(a))
end
Class = require("lib.classic")
Signal = require("lib.signal")

function love.load()
  -- INPUT
  Input = baton.new {
    controls = {
      left = { "key:left", "key:a" },
      right = { "key:right", "key:d" },
      up = { "key:up", "key:w" },
      down = { "key:down", "key:s" },
      jump = { "key:space", "key:x" },
      cancel = { "key:escape" },
    },
    pairs = { move = { "left", "right", "up", "down" } },
  }

  -- WINDOW
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough")
  push:setupScreen(
      RES_X, RES_Y, WIN_X, WIN_Y, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        pixelperfect = true,
      })

  -- SCREENS
  local screens = {
    game = require("src.screens.Game"),
    splash = require("src.screens.SplashScreen"),
    intro = require("src.screens.Intro"),
  }
  ScreenManager.init(screens, "splash")
  ScreenManager.registerCallbacks()
end

function love.resize(w, h)
  return push:resize(w, h)
end
