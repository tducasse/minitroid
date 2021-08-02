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
  local Crawler = require("src.entities.crawler")

  -- CAMERA
  local camera = Camera(RES_X / 2, RES_Y / 2, RES_X, RES_Y)
  camera:setFollowStyle("PLATFORMER")

  -- VARS
  local player = {}
  local crawlers = {}
  local world = {}
  local map = {}
  local paused = false
  local music = {}

  local function init_entities()
    -- PLAYER
    player = Player(
                 map.active.Entities.Player[1], map.active.width,
                 map.active.height)
    world:add(player, player.x, player.y, player.w, player.h)

    local grid_size = map.active.Entities.grid_size
    -- CRAWLERS
    for _, c in ipairs(map.active.Entities.Crawler or {}) do
      local crawler = Crawler(c, grid_size)
      crawlers[#crawlers + 1] = crawler
      world:add(crawler, crawler.x, crawler.y, crawler.w, crawler.h)
    end
  end

  local function on_level_loaded_entities()
    player:onLevelLoaded()
    local grid_size = map.active.Entities.grid_size
    -- CRAWLERS
    for _, c in ipairs(map.active.Entities.Crawler or {}) do
      local crawler = Crawler(c, grid_size)
      crawlers[#crawlers + 1] = crawler
      world:add(crawler, crawler.x, crawler.y, crawler.w, crawler.h)
    end
  end

  local function on_level_loading_entities()
    for _, crawler in ipairs(crawlers) do
      world:remove(crawler)
    end
    crawlers = {}
  end

  local function update_entities(dt)
    for _, crawler in ipairs(crawlers) do
      crawler:update(dt, world)
    end
    player:update(dt, world)
  end

  local function draw_entities()
    for _, crawler in ipairs(crawlers) do
      crawler:draw()
    end
    player:draw()
  end

  -- GAME
  function self:init()
    player = {}
    crawlers = {}
    world = {}
    map = {}
    paused = false
    -- music = love.audio.play("assets/music.ogg", "static", true)

    -- MAP
    map = Tilemapper("assets/minitroid.ldtk", { aseprite = true })
    world = bump.newWorld()
    map:loadLevel("Level_0", world)
    camera:setBounds(0, 0, map.active.width, map.active.height)
    init_entities()

    -- SIGNALS
    Signal.register(
        SIGNALS.NEXT_LEVEL, function(params)
          paused = true
          on_level_loading_entities()
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
                on_level_loaded_entities()
              end)
        end)
  end

  function self:update(dt)
    Input:update()
    -- if Input:pressed("cancel") then
    -- love.audio.stop(music)
    -- ScreenManager.switch("splash")
    -- love.event.quit()
    -- end
    love.audio.update()
    if not paused then
      update_entities(dt)
    end
    camera:follow(player.x, player.y)
    camera:update(dt)
  end

  function self:draw()
    push:start()
    camera:attach()

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    if not paused then
      draw_entities()
      map:draw()
    end

    -- local items = world:getItems()
    -- for i = 1, #items do
    --   local item = items[i]
    --   love.graphics.rectangle("line", item.x, item.y, item.w, item.h)
    -- end
    camera:detach()
    camera:draw()
    if not paused then
      player:display_hp()
    end
    push:finish()
  end

  return self

end
return GameScreen
