local peachy = require("lib.peachy")
local Fluid = Class:extend()

function Fluid:draw()
  self.sprite:draw(self.x, self.y)
end

function Fluid:update(dt)
  self.sprite:update(dt)
end

function Fluid:new(m, collection)
  self.type = "fluid"
  self.collection = collection

  -- POSITION
  self.x = m.x
  self.y = m.y
  self.w = m.w
  self.h = m.h

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/red-fluid.json",
                    love.graphics.newImage("assets/red-fluid.png"), "Full")
  self.sprite:play()
end

return Fluid
