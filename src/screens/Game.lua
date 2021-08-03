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
  local Bullet = require("src.entities.bullet")

  -- CAMERA
  local camera = Camera(RES_X / 2, RES_Y / 2, RES_X, RES_Y)
  camera:setFollowStyle("PLATFORMER")

  -- VARS
  local player = {}
  local world = {}
  local map = {}
  local paused = true
  local started = false
  local music = {}
  local entities = { bullets = {}, crawlers = {} }

  local function add_crawlers()
    local grid_size = map.active.Entities.grid_size
    for _, c in ipairs(map.active.Entities.Crawler or {}) do
      local crawler = Crawler(c, grid_size, "crawlers")
      entities.crawlers[#entities.crawlers + 1] = crawler
      world:add(crawler, crawler.x, crawler.y, crawler.w, crawler.h)
    end
  end

  local function add_player()
    player = Player(
                 map.active.Entities.Player[1], map.active.width,
                 map.active.height)
    world:add(player, player.x, player.y, player.w, player.h)
  end

  local function init_entities()
    add_player()
    add_crawlers()
  end

  local function remove_crawlers()
    for _, crawler in ipairs(entities.crawlers) do
      world:remove(crawler)
    end
    entities.crawlers = {}
  end

  local function remove_bullets()
    for _, bullet in ipairs(entities.bullets) do
      world:remove(bullet)
    end
    entities.bullets = {}
  end

  local function on_level_loading_entities()
    remove_bullets()
    remove_crawlers()
  end

  local function on_level_loaded_entities()
    player:onLevelLoaded()
    add_crawlers()
  end

  local function update_entities(dt)
    for _, crawler in ipairs(entities.crawlers) do
      crawler:update(dt, world)
    end
    for _, bullet in ipairs(entities.bullets) do
      bullet:update(dt, world)
    end
    player:update(dt, world)
  end

  local function draw_entities()
    for _, crawler in ipairs(entities.crawlers) do
      crawler:draw()
    end
    for _, bullet in ipairs(entities.bullets) do
      bullet:draw()
    end
    player:draw()
  end

  -- GAME
  function self:init()
    player = {}
    world = {}
    map = {}
    paused = true
    started = false
    -- music = love.audio.play("assets/music.ogg", "static", true)

    -- MAP
    map = Tilemapper(
              "assets/minitroid.ldtk",
              { aseprite = true, collisions = { [1] = true } })
    world = bump.newWorld()
    map:loadLevel("Level_0", world)
    camera:setBounds(0, 0, map.active.width, map.active.height)
    init_entities()

    -- SIGNALS
    Signal.register(
        SIGNALS.NEXT_LEVEL, function(params)
          paused = true
          on_level_loading_entities()
          love.audio.play("assets/door.ogg", "static", nil, 0.7)
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
    Signal.register(
        SIGNALS.SHOOT, function(x, y, dx, dy)
          entities.bullets[#entities.bullets + 1] = Bullet(
                                                        x, y, dx, dy, world,
                                                        map.active.width,
                                                        map.active.height,
                                                        "bullets")
        end)
    Signal.register(
        SIGNALS.DESTROY_ITEM, function(item, item_table_name)
          world:remove(item)
          local item_table = entities[item_table_name]
          local found = nil
          for i, el in ipairs(item_table) do
            if el == item then
              found = i
              break
            end
          end
          if found then
            table.remove(item_table, found)
          end
        end)
  end

  function self:update(dt)
    Input:update()
    if not started and Input:pressed("jump") then
      paused = false
      started = true
    end
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

    love.graphics.clear(24 / 255, 20 / 255, 37 / 255, 255 / 255)
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
