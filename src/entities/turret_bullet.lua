local peachy = require("lib.peachy")
local TurretBullet = Class:extend()

function TurretBullet:draw()
  self.sprite:draw(self.x, self.y)
end

function TurretBullet:update(dt, world)
  self.sprite:update(dt)
  if not self.world and world then
    self.world = world
  end

  local x, y = 0, 0
  x = self.dx and (self.x + self.dx * self.speed * dt + 0.00001) or self.x
  y = self.dy and (self.y + self.dy * self.speed * dt + 0.00001) or self.y

  local cols = {}
  self.x, self.y, cols = self.world:move(self, x, y, self.filter)

  for _, col in pairs(cols) do
    if col.type == "touch" then
      self:destroy()
      if col.other.hit then
        col.other:hit()
      end
    elseif col.type == "slide" then
      self:destroy()
    end
  end

  if self.x < 0 or self.x > self.map_width or self.y < 0 or self.y >
      self.map_height then
    self:destroy()
  end

end

function TurretBullet:hit()
  self:destroy()
end

function TurretBullet:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function TurretBullet:filter(other)
  if other.type then
    if other.type == "player" then
      return "touch"
    else
      return "slide"
    end
  else
    return "slide"
  end
end

function TurretBullet:new(turret, world, map_width, map_height, collection)
  self.type = "turret_bullet"
  self.collection = collection

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/turret_bullet.json",
                    love.graphics.newImage("assets/turret_bullet.png"),
                    "default")
  self.sprite:play()

  self.w = self.sprite:getWidth()
  self.h = self.sprite:getHeight()

  -- POSITION
  local current = turret.sprite.tagName
  if current == "LBL" then
    self.x = turret.x - 1 - self.w
    self.y = turret.y + turret.h - self.h / 2
    self.dx = -1
    self.dy = 1
  elseif current == "BLB" then
    self.x = turret.x + turret.w / 2 - self.w / 2
    self.y = turret.y + turret.h + 1
    self.dx = 0
    self.dy = 1
  elseif current == "BLL" then
    self.x = turret.x - 1 - self.w
    self.y = turret.y + turret.h / 2 - self.h / 2
    self.dx = -1
    self.dy = 0
  elseif current == "BBL" then
    self.x = turret.x - 1 - self.w
    self.y = turret.y + turret.h - self.h / 2
    self.dx = -1
    self.dy = 1
  elseif current == "RBR" then
    self.x = turret.x + turret.w + 1
    self.y = turret.y + turret.h - self.h / 2
    self.dx = 1
    self.dy = 1
  elseif current == "BRB" then
    self.x = turret.x + turret.w / 2 - self.w / 2
    self.y = turret.y + turret.h + 1
    self.dx = 0
    self.dy = 1
  elseif current == "BRR" then
    self.x = turret.x + turret.w + 1
    self.y = turret.y + turret.h / 2 - self.h / 2
    self.dx = 1
    self.dy = 0
  elseif current == "BBR" then
    self.x = turret.x + turret.w + 1
    self.y = turret.y + turret.h - self.h / 2
    self.dx = 1
    self.dy = 1
  end

  self.speed = 25

  -- BOUNDARIES
  self.map_width = map_width
  self.map_height = map_height

  -- COLLISION
  world:add(
      self, self.x, self.y, self.sprite:getWidth(), self.sprite:getHeight())

end

return TurretBullet
