local peachy = require("lib.peachy")
local Skree = Class:extend()

function Skree:draw()
  self.sprite:draw(self.x, self.y)
end

function Skree:update(dt, world, player)
  if not self.world and world then
    self.world = world
  end
  self.sprite:update(dt)
  if math.abs(player.x - self.x) < 10 then
    self.sprite:setTag("default")
    if self.y_velocity == 0 then
      self.y_velocity = dt * self.speed
    end
  end
  local y = self.y + self.y_velocity

  self.x, self.y = self.world:move(self, self.x, y, self.filter)

end

function Skree:filter(other)
  if other.type then
    if other.type == "player" or other.type == "bullet" then
      return "cross"
    else
      return "slide"
    end
  else
    return "slide"
  end
end

function Skree:new(c, collection)
  self.type = "skree"
  self.collection = collection

  -- POSITION
  self.x = c.x
  self.y = c.y
  self.w = c.w
  self.h = c.h

  -- MOVEMENT
  self.speed = 100
  self.y_velocity = 0

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/skree.json",
                    love.graphics.newImage("assets/skree.png"), "default")
  self.sprite:play()
end

function Skree:hit()
  love.audio.play("assets/destroy.ogg", "static", false, "0.7")
  self:destroy()
end

function Skree:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

return Skree
