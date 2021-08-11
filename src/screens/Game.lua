local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local GameScreen = {}

function GameScreen.new()
  local self = Screen.new()

  local Tilemapper = require("lib.tilemapper")
  local Camera = require("lib.camera")
  local bump = require("lib.bump")
  local push = require("lib.push")
  local tween = require("lib.tween")

  local Player = require("src.entities.player")
  local Crawler = require("src.entities.crawler")
  local Bullet = require("src.entities.bullet")
  local Item = require("src.entities.item")
  local Acid = require("src.entities.acid")
  local AcidPole = require("src.entities.acid-pole")
  local Mother = require("src.entities.mother")
  local RedFluid = require("src.entities.red-fluid")
  local Turret = require("src.entities.turret")
  local Win = require("src.entities.win")

  -- CAMERA
  local camera = Camera(RES_X / 2, RES_Y / 2, RES_X, RES_Y)
  camera:setFollowStyle("PLATFORMER")

  -- VARS
  local player = {}
  local world = {}
  local map = {}
  local paused = false
  local current_music = nil
  local entities = {
    bullets = {},
    crawlers = {},
    items = {},
    acid = {},
    acid_pole = {},
    mother = {},
    fluids = {},
    turrets = {},
    win = {},
  }

  local entity_order = {
    "acid",
    "acid_pole",
    "mother",
    "fluids",
    "turrets",
    "crawlers",
    "items",
    "bullets",
    "win",
  }

  local cameraTween = {}
  local cameraTweenPos = {}

  local function remove(item)
    if world:hasItem(item) then
      world:remove(item)
    end
  end

  local function add_crawlers()
    local grid_size = map.active.Entities.grid_size
    for _, c in ipairs(map.active.Entities.Crawlers or {}) do
      local crawler = Crawler(c, grid_size, "crawlers")
      entities.crawlers[#entities.crawlers + 1] = crawler
      world:add(crawler, crawler.x, crawler.y, crawler.w, crawler.h)
    end
  end

  local function add_acid()
    for _, a in ipairs(map.active.Entities.Acid or {}) do
      local acid = Acid(a, "acid")
      entities.acid[#entities.acid + 1] = acid
      world:add(acid, acid.x, acid.y, acid.w, acid.h)
    end
  end

  local function add_turrets()
    for _, t in ipairs(map.active.Entities.Turret or {}) do
      local turret = Turret(t, "turrets")
      entities.turrets[#entities.turrets + 1] = turret
      world:add(turret, turret.x, turret.y, turret.w, turret.h)
    end
  end

  local function add_red_fluid()
    for _, f in ipairs(map.active.Entities.RedFluid or {}) do
      local fluid = RedFluid(f, "fluids")
      entities.fluids[#entities.fluids + 1] = fluid
      world:add(fluid, fluid.x, fluid.y, fluid.w, fluid.h)
    end
  end

  local function add_acid_pole()
    for _, a in ipairs(map.active.Entities.AcidPole or {}) do
      local acid_pole = AcidPole(a, "acid_pole")
      entities.acid_pole[#entities.acid_pole + 1] = acid_pole
      world:add(acid_pole, acid_pole.x, acid_pole.y, acid_pole.w, acid_pole.h)
    end
  end

  local function add_mother()
    for _, m in ipairs(map.active.Entities.Mother or {}) do
      local mother = Mother(m, "mother")
      entities.mother[#entities.mother + 1] = mother
      world:add(mother, mother.x, mother.y, mother.w, mother.h)
    end
  end

  local function add_items(player)
    for _, i in ipairs(map.active.Entities.Items or {}) do
      if player then
        local item_type = string.lower(i.type)
        if item_type == "missile_item" and player.missile then
          return
        end
        if item_type == "ball" and player.ball then
          return
        end
      end
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

  local function add_win()
    for _, i in ipairs(map.active.Entities.Win or {}) do
      local item = Win(i, "win")
      entities.win[#entities.win + 1] = item
      world:add(item, item.x, item.y, item.w, item.h)
    end
  end

  local function play_level_music()
    local song = MUSIC.DEFAULT
    if map.active.secret then
      song = MUSIC.SECRET
    elseif map.active.boss then
      song = nil
    end
    if current_music ~= song then
      love.audio.stop(Music)
      if song then
        Music = love.audio.play(song, "static", true)
        current_music = song
      end
    end
  end

  local function init_level()
    Signal.clearPattern(".*")
    add_player()
    add_crawlers()
    add_red_fluid()
    add_acid()
    add_turrets()
    add_acid_pole()
    add_mother()
    add_items()
    add_win()
    play_level_music()
  end

  local function remove_collection(collection)
    for _, el in ipairs(entities[collection]) do
      remove(el)
    end
    entities[collection] = {}
  end

  local function remove_entities()
    for collection in pairs(entities) do
      remove_collection(collection)
    end
  end

  local function on_level_loading()
    remove_entities()
  end

  local function on_level_loaded()
    player:onLevelLoaded()
    add_crawlers()
    add_acid()
    add_red_fluid()
    add_turrets()
    add_acid_pole()
    add_mother()
    add_items(player)
    add_win()
    play_level_music()
    if map.active.boss then
      local mother = entities.mother[1]
      local motherPos = { x = mother.x + mother.w / 2, y = player.y }
      local playerPos = { x = player.x, y = player.y }
      cameraTweenPos = playerPos
      cameraTween = tween.new(6, cameraTweenPos, motherPos, "linear")
    else
      cameraTween = {}
      cameraTweenPos = {}
    end
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
    if not cameraTween.update then
      player:update(dt, world)
    end
  end

  local function draw_collection(collection)
    for _, el in ipairs(entities[collection]) do
      if el.draw then
        el:draw()
      end
    end
  end

  local function draw_entities()
    for _, collection in ipairs(entity_order) do
      draw_collection(collection)
    end
    if not cameraTween.update then
      player:draw()
    end
  end

  -- GAME
  function self:init()
    player = {}
    world = {}
    map = {}
    paused = false

    -- MAP
    map = Tilemapper(
              "assets/minitroid.ldtk", {
          aseprite = true,
          collisions = { [1] = true, [3] = true, [4] = true, [5] = true },
        })
    world = bump.newWorld()
    map:loadLevel("Level_0", world)
    camera:setBounds(0, 0, map.active.width, map.active.height)
    init_level()

    -- SIGNALS
    Signal.register(
        SIGNALS.NEXT_LEVEL, function(params)
          paused = true
          on_level_loading()
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
          camera:setBounds(
              0, 0, map.active.width,
              map.active.max_height and map.active.max_height > 0 and
                  map.active.max_height or map.active.height)
          camera:fade(
              0.1, { 0, 0, 0, 0 }, function()
                paused = false
                on_level_loaded()
              end)
        end)
    Signal.register(
        SIGNALS.SHOOT, function(x, y, dx, dy, missile)
          entities.bullets[#entities.bullets + 1] = Bullet(
                                                        x, y, dx, dy, world,
                                                        map.active.width,
                                                        map.active.height,
                                                        missile, "bullets")
        end)
    Signal.register(
        SIGNALS.DESTROY_ITEM, function(item, item_table_name)
          remove(item)
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
          camera:flash(0.1, { 1, 1, 1, 1 })
          camera:shake(2, 0.2, 60)
        end)

    Signal.register(
        SIGNALS.LOSE, function()
          camera:fade(
              1.4, { 0, 0, 0, 1 }, function()
                love.audio.stop(Music)
                ScreenManager.switch("splash")
              end)
        end)
    Signal.register(
        SIGNALS.MOTHER_DEATH, function()
          camera:shake(4, 1, 60)
        end)
    Signal.register(
        SIGNALS.WIN, function()
          ScreenManager.switch("win")
        end)
  end

  function self:update(dt)
    Input:update()
    love.audio.update()
    if not paused then
      update_entities(dt)
    end

    if map.active.boss and cameraTween.update then
      local complete = cameraTween:update(dt)
      if not complete then
        if cameraTweenPos.x then
          camera:follow(cameraTweenPos.x, cameraTweenPos.y)
        end
      else
        if not (cameraTweenPos.x == player.x and cameraTweenPos.y == player.y) then
          Music = love.audio.play(MUSIC.BOSS, "static", true)
          current_music = MUSIC.BOSS
          local playerPos = { x = player.x, y = player.y }
          cameraTween = tween.new(5, cameraTweenPos, playerPos, "inQuint")
        else
          cameraTween = {}
          cameraTweenPos = {}
        end
      end
    else
      camera:follow(player.x, player.y)
    end

    camera:update(dt)
  end

  function self:draw()
    push:start()
    camera:attach()

    love.graphics.clear()
    if not paused then
      map:draw()
      draw_entities()
    end

    -- local items = world:getItems()
    -- for i = 1, #items do
    --   local item = items[i]
    --   if item.x and item.y and item.w and item.h then
    --     love.graphics.rectangle("line", item.x, item.y, item.w, item.h)
    --   end
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
