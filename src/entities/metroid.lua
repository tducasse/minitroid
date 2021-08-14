local peachy = require("lib.peachy")
local Metroid = Class:extend()

function Metroid:draw()
  self.sprite:draw(self.x, self.y)
end

function Metroid:update_target()
  if self:distance_to(self.target) <= 0.1 then
    local next_path_index = self.path_index + 1 * self.last_dir
    if next_path_index > #self.path or next_path_index < 1 then
      next_path_index = self.path_index - 1 * self.last_dir
      self.last_dir = -self.last_dir
    end
    self.path_index = next_path_index
    self.target = self.path[self.path_index]
  end
end

function Metroid:distance_to(target)
  if not target then
    return 1
  end
  return math.sqrt(
             math.pow(self.x - target.x, 2) + math.pow(self.y - target.y, 2))
end

function Metroid:update(dt, world)
  if not self.world and world then
    self.world = world
  end
  self.sprite:update(dt)
  self:update_target()
  self.x_velocity = ((self.target.x - self.x) / self:distance_to(self.target)) *
                        dt * self.speed
  self.y_velocity = ((self.target.y - self.y) / self:distance_to(self.target)) *
                        dt * self.speed
  local x = self.x + self.x_velocity
  local y = self.y + self.y_velocity

  self.x, self.y = self.world:move(self, x, y, self.filter)
end

function Metroid:filter()
  return "cross"
end

function Metroid:new(c, grid_size, collection)
  self.type = "metroid"
  self.collection = collection

  -- POSITION
  self.x = c.x
  self.y = c.y
  self.top = c.top
  self.left = c.left
  self.w = c.w
  self.h = c.h

  -- MOVEMENT
  self.path = {}
  for _, v in ipairs(c.path) do
    self.path[#self.path + 1] = { x = v.cx * grid_size, y = v.cy * grid_size }
  end
  self.target = self.path[1]
  self.path_index = 1
  self.last_dir = 1
  self.speed = 10
  self.x_velocity = 0
  self.y_velocity = 0

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/metroid.json",
                    love.graphics.newImage("assets/metroid.png"), "default")
  self.sprite:play()
end

function Metroid:hit()
  love.audio.play("assets/destroy.ogg", "static", false, "0.7")
  self:destroy()
end

function Metroid:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

return Metroid
