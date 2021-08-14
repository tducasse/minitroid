local peachy = require("lib.peachy")
local Explosion = Class:extend()

function Explosion:draw()
  self.sprite:draw(self.x, self.y)
end

function Explosion:update(dt)
  self.sprite:update(dt)
end

function Explosion:onLoop()
  self:destroy()
end

function Explosion:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function Explosion:new(x, y, collection)
  self.type = "explosion"
  self.collection = collection

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/explosion.json",
                    love.graphics.newImage("assets/explosion.png"), "default")
  self.sprite:play()
  self.sprite:onLoop(self.onLoop, self)

  -- POSITION
  self.w = self.sprite:getWidth()
  self.h = self.sprite:getHeight()
  self.x = x - self.w / 2
  self.y = y - self.h / 2

  love.audio.play("assets/explosion.ogg", "static", false, 0.7)

end

return Explosion
