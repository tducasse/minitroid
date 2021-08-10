local peachy = require("lib.peachy")
local Fluid = Class:extend()

function Fluid:draw()
  self.sprite:draw(self.x, self.y)
end

function Fluid:update(dt)
  self.sprite:update(dt)
end

function Fluid:hit()
  self.hp = self.hp - 1
  if self.hp > 0 then
    local index = math.ceil(self.hp / 2)
    local anim = self.anims[index]
    self.sprite:setTag(anim)
  else
    self:destroy()
  end
end

function Fluid:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function Fluid:new(m, collection)
  self.type = "fluid"
  self.collection = collection

  -- POSITION
  self.x = m.x
  self.y = m.y
  self.w = m.w
  self.h = m.h

  self.hp = 6
  self.anims = { "Third", "Two thirds", "Full" }

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/red-fluid.json",
                    love.graphics.newImage("assets/red-fluid.png"), "Full")
  self.sprite:play()
end

return Fluid
