local peachy = require("lib.peachy")
local AcidPole = Class:extend()

function AcidPole:draw()
  self.sprite:draw(self.x, self.y)
end

function AcidPole:update(dt)
  self.sprite:update(dt)
end

function AcidPole:new(a, collection)
  self.type = "acid_pole"
  self.collection = collection

  -- POSITION
  self.x = a.x
  self.y = a.y
  self.w = a.w
  self.h = a.h

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/acid-pole.json",
                    love.graphics.newImage("assets/acid-pole.png"), "default")
  self.sprite:play()
end

return AcidPole
