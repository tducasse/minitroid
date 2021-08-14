local peachy = require("lib.peachy")
local Turret = Class:extend()

function Turret:draw()
  local x = self.x - self.left
  local y = self.y - self.top
  self.sprite:draw(x, y)
end

function Turret:update(dt)
  self.sprite:update(dt)
end

function Turret:onLoop()
  local current = self.sprite.tagName
  local options = {}
  if current == "LBL" then
    options = { "BLB", "BLL" }
  elseif current == "BLB" then
    options = { "BBL" }
  elseif current == "BLL" then
    options = { "LBL" }
  elseif current == "BBL" then
    options = { "BLB", "BLL" }
  elseif current == "RBR" then
    options = { "BRB", "BRR" }
  elseif current == "BRB" then
    options = { "BBR" }
  elseif current == "BRR" then
    options = { "RBR" }
  elseif current == "BBR" then
    options = { "BRB", "BRR" }
  end

  local random = math.random()
  if random < 0.33 then
    self:shoot()
  end

  if #options == 1 then
    self.sprite:setTag(options[1])
  else
    if random < 0.4 then
      self.sprite:setTag(options[2])
    else
      self.sprite:setTag(options[1])
    end
  end
end

function Turret:shoot()
  if not Cinema then
    Signal.emit(SIGNALS.TURRET_SHOOT, self)
  end
end

function Turret:new(a, collection)
  self.type = "turret"
  self.collection = collection

  -- POSITION
  self.x = a.x
  self.y = a.y
  self.w = a.w
  self.h = a.h
  self.left = a.left
  self.top = a.top
  self.is_left = a.is_left

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/turret.json",
                    love.graphics.newImage("assets/turret.png"),
                    self.is_left and "LBL" or "RBR")
  self.sprite:play()
  self.sprite:onLoop(self.onLoop, self)
end

return Turret
