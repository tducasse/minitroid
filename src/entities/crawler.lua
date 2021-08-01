local peachy = require("lib.peachy")
local Crawler = Class:extend()

function Crawler:draw()
  local left = self.left or 0
  local top = self.top or 0
  local x = self.x - left
  local y = self.y - top
  if self.last_dir == -1 then
    x = x + self.w + left * 2
  end
  self.sprite:draw(x, y, 0, self.last_dir)
end

function Crawler:update_target()
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

function Crawler:distance_to(target)
  if not target then
    return 1
  end
  return math.sqrt(
             math.pow(self.x - target.x, 2) + math.pow(self.y - target.y, 2))
end

function Crawler:update(dt, world)
  if not self.world and world then
    self.world = world
  end
  self.sprite:update(dt)
  self:update_target()
  local x =
      self.x + ((self.target.x - self.x) / self:distance_to(self.target)) * dt *
          self.speed
  local y =
      self.y + ((self.target.y - self.y) / self:distance_to(self.target)) * dt *
          self.speed

  self.x, self.y = self.world:move(self, x, y)
end

function Crawler:new(c, grid_size, world)
  self.type = "crawler"

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

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/crawler.json",
                    love.graphics.newImage("assets/crawler.png"), "walk")
  self.sprite:play()
end

return Crawler
