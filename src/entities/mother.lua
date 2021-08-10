local peachy = require("lib.peachy")
local Mother = Class:extend()

function Mother:draw()
  self.sprite:draw(self.x, self.y)
end

function Mother:update(dt)
  self.sprite:update(dt)
end

function Mother:hit()
  self.hp = self.hp - 1
  if self.hp == 6 then
    self.sprite:setTag("Broken")
  elseif self.hp > 0 then
    self.sprite:setTag("Hurt")
  else
    self:destroy()
  end
end

function Mother:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function Mother:onLoop()
  if self.sprite.tagName == "Hurt" then
    self.sprite:setTag("Broken")
  end
end

function Mother:new(m, collection)
  self.type = "mother"
  self.collection = collection

  -- POSITION
  self.x = m.x
  self.y = m.y
  self.w = m.w
  self.h = m.h

  self.hp = 7

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/mother-brain.json",
                    love.graphics.newImage("assets/mother-brain.png"), "Alive")
  self.sprite:play()
  self.sprite:onLoop(self.onLoop, self)
end

return Mother
