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
                    love.graphics.newImage("assets/turret.png"), "default")
  self.sprite:play()
end

return Turret
