local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local GameScreen = {}

function GameScreen.new()
  local self = Screen.new()

  local Tilemapper = require("lib.tilemapper")
  local Camera = require("lib.camera")
  local bump = require("lib.bump")
  local push = require("lib.push")

  local Player = require("src.entities.player")

  -- CAMERA
  local camera = Camera(RES_X / 2, RES_Y / 2, RES_X, RES_Y)
  camera:setFollowStyle("PLATFORMER")

  -- VARS
  local player = {}
  local world = {}
  local map = {}
  local paused = false
  local music = {}

  -- GAME
  function self:init()
    player = {}
    world = {}
    map = {}
    paused = false
    music = love.audio.play("assets/music.ogg", "stream", true)

    -- MAP
    map = Tilemapper("assets/boilerplate.ldtk", { aseprite = true })
    world = bump.newWorld()
    map:loadLevel("Level_0", world)
    camera:setBounds(0, 0, map.active.width, map.active.height)

    -- PLAYER
    player = Player(
                 map.active.Entities.Player, map.active.width, map.active.height)
    world:add(player, player.x, player.y, player.w, player.h)

    -- SIGNALS
    Signal.register(
        SIGNALS.NEXT_LEVEL, function(params)
          paused = true
          camera:fade(
              0.1, { 0, 0, 0, 1 }, function()
                map:nextLevel(
                    params, function()
                    end)
                Signal.emit(SIGNALS.LEVEL_LOADED)
              end)
        end)
    Signal.register(
        SIGNALS.LEVEL_LOADED, function()
          camera:fade(
              0.1, { 0, 0, 0, 0 }, function()
                paused = false
                player:onLevelLoaded()
              end)
        end)
  end

  function self:update(dt)
    Input:update()
    if Input:pressed("cancel") then
      love.audio.stop(music)
      ScreenManager.switch("splash")
    end
    love.audio.update()
    if not paused then
      player:update(dt, world)
    end
    camera:follow(player.x, player.y)
    camera:update(dt)
  end

  function self:draw()
    push:start()
    camera:attach()

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    map:draw()
    if not paused then
      player:draw()
    end

    -- local items = world:getItems()
    -- for i = 1, #items do
    --   local item = items[i]
    --   love.graphics.rectangle("line", item.x, item.y, item.w, item.h)
    -- end

    camera:detach()
    camera:draw()
    push:finish()
  end

  return self

end
return GameScreen
