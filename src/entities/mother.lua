local peachy = require("lib.peachy")
local Mother = Class:extend()

function Mother:draw()
  self.sprite:draw(self.x, self.y)
end

function Mother:update(dt)
  self.sprite:update(dt)
end

function Mother:new(m, collection)
  self.type = "mother"
  self.collection = collection

  -- POSITION
  self.x = m.x
  self.y = m.y
  self.w = m.w
  self.h = m.h

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/mother-brain.json",
                    love.graphics.newImage("assets/mother-brain.png"), "Alive")
  self.sprite:play()
end

return Mother
