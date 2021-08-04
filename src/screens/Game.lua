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
  local Item = require("src.entities.item")

  -- CAMERA
  local camera = Camera(RES_X / 2, RES_Y / 2, RES_X, RES_Y)
  camera:setFollowStyle("PLATFORMER")

  -- VARS
  local player = {}
  local world = {}
  local map = {}
  local paused = false
  local music = {}
  local entities = { bullets = {}, crawlers = {}, items = {} }

  local function add_crawlers()
    local grid_size = map.active.Entities.grid_size
    for _, c in ipairs(map.active.Entities.Crawlers or {}) do
      local crawler = Crawler(c, grid_size, "crawlers")
      entities.crawlers[#entities.crawlers + 1] = crawler
      world:add(crawler, crawler.x, crawler.y, crawler.w, crawler.h)
    end
  end

  local function add_items()
    for _, i in ipairs(map.active.Entities.Items or {}) do
      local item = Item(i, "items")
      entities.items[#entities.items + 1] = item
      world:add(item, item.x, item.y, item.w, item.h)
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
    add_items()
  end

  local function remove_collection(collection)
    for _, el in ipairs(entities[collection]) do
      world:remove(el)
    end
    entities[collection] = {}
  end

  local function remove_entities()
    for collection in pairs(entities) do
      remove_collection(collection)
    end
  end

  local function on_level_loading_entities()
    remove_entities()
  end

  local function on_level_loaded_entities()
    player:onLevelLoaded()
    add_crawlers()
    add_items()
  end

  local function update_collection(collection, dt)
    for _, el in ipairs(entities[collection]) do
      if el.update then
        el:update(dt, world)
      end
    end
  end

  local function update_entities(dt)
    for collection in pairs(entities) do
      update_collection(collection, dt)
    end
    player:update(dt, world)
  end

  local function draw_collection(collection)
    for _, el in ipairs(entities[collection]) do
      if el.draw then
        el:draw()
      end
    end
  end

  local function draw_entities()
    for collection in pairs(entities) do
      draw_collection(collection)
    end
    player:draw()
  end

  -- GAME
  function self:init()
    player = {}
    world = {}
    map = {}
    paused = false
    music = love.audio.play("assets/music.ogg", "static", true)

    -- MAP
    map = Tilemapper(
              "assets/minitroid.ldtk",
              { aseprite = true, collisions = { [1] = true, [3] = true } })
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

    Signal.register(
        SIGNALS.HIT, function()
          camera:flash(0.05, { 24 / 255, 20 / 255, 37 / 255, 255 / 255, 1 })
          camera:shake(1, 0.1, 60)
        end)
  end

  function self:update(dt)
    Input:update()
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
