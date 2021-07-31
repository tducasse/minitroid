local ScreenManager = require("lib.screen_manager")
local Talkies = require("lib.talkies")
local Screen = require("lib.screen")
local push = require("lib.push")
local script = require("src.scripts.intro")

Talkies.backgroundColor = { 1, 1, 1, 0.2 }
Talkies.titleColor = { 1, 0, 0, 1 }
Talkies.textSpeed = "fast"
Talkies.font = love.graphics.newFont(24)

local Intro = {}

function Intro.new()
  local self = Screen.new()

  function self:init()
    local displayMessageNode

    local function nextMessage()
      local node = script:next()
      displayMessageNode(node)
    end

    local function selectOption(selection)
      local node = script:select(selection)
      displayMessageNode(node)
    end

    displayMessageNode = function(node)
      if node == nil then
        return
      end

      local config = {}
      if node.options then
        config.options = {}
        for i, opt in ipairs(node.options) do
          local onSelect = function()
            selectOption(opt)
          end
          config.options[i] = { opt, onSelect }
        end
      else
        config.oncomplete = nextMessage
      end
      Talkies.say(node.name, node.msg, config)
    end
    nextMessage()
  end

  function self:update(dt)
    Talkies.update(dt)
    Input:update()
    if Input:pressed("jump") then
      Talkies.onAction()
    elseif Input:pressed("up") then
      Talkies.prevOption()
    elseif Input:pressed("down") then
      Talkies.prevOption()
    elseif Input:pressed("cancel") then
      ScreenManager.switch("splash")
    end
  end

  function self:draw()
    push:start()
    Talkies.draw()
    if Talkies.isOpen() == false then
      ScreenManager.switch("game")
    end
    push:finish()
  end

  return self
end

return Intro
