local peachy = require("lib.peachy")
local Player = Class:extend()

function Player:draw()
  local left = self.left or 0
  local top = self.top or 0
  local x = self.x - left
  local y = self.y - top
  if self.last_dir == -1 then
    x = x + self.w + left * 2
  end
  self.sprite:draw(x, y, 0, self.last_dir)
end

function Player:moveOutOfBounds()
  local dir = nil
  local x, y = self.x, self.y
  if self.x > self.east - self.w / 3 then
    dir = "e"
    x = self.west + self.w / 3
  elseif self.x < self.west - self.w / 3 then
    dir = "w"
    x = self.east - self.w - self.w / 3
  elseif self.y > self.south - self.h / 3 then
    dir = "s"
    y = self.north + self.h + self.h / 3
  elseif self.y < self.north - self.h / 3 then
    dir = "n"
    y = self.south - self.h - self.h / 3
  end
  if dir then
    Signal.emit(SIGNALS.NEXT_LEVEL, dir)
    self.world:remove(self)
    self.x = x
    self.y = y
  end
end

function Player:update(dt, world)
  self.sprite:update(dt)

  if not self.world and world then
    self.world = world
  end

  local x, y = self.x, self.y
  local x_axis = Input:get("move")

  if math.abs(self.x_velocity) > 0.1 then
    if not self.bouncing then
      self.x_velocity = self.x_velocity - self.last_dir * self.friction
    else
      self.x_velocity = self.x_velocity / 2
    end
  else
    if self.bouncing then
      self.bouncing = false
      self.jumping = false
    end
    self.x_velocity = 0
  end

  if not self.bouncing then
    if x_axis > 0 then
      self.x_velocity = self.speed
      if self.ground then
        self.sprite:setTag("run")
      end
      self.last_dir = 1
    elseif x_axis < 0 then
      self.x_velocity = -self.speed
      if self.ground then
        self.sprite:setTag("run")
      end
      self.last_dir = -1
    else
      if self.ground then
        self.sprite:setTag("idle")
      end
    end

    if Input:down("jump") then
      if self.ground and not self.jumping then
        love.audio.play("assets/jump.ogg", "static")
        self.jumping = true
        self.y_velocity = self.jump_height
      end
    end

    if Input:released("jump") then
      self.jumping = false
    end
  end

  x = self.x + self.x_velocity * dt + 0.000001
  y = self.y + self.y_velocity * dt + 0.000001
  self.y_velocity = self.y_velocity + self.gravity * dt

  local cols
  self.x, self.y, cols = self.world:move(self, x, y, self.filter)

  local ground = false
  for _, col in pairs(cols) do
    if col.bounce then
      self:bounce(col.other.type)
    elseif col.normal.y == 1 then
      self.y_velocity = 0
    elseif col.normal.y == -1 then
      ground = true
      self.y_velocity = 0
    end
  end

  self.ground = ground

  if not self.ground then
    self.sprite:setTag("jump")
  end

  self:moveOutOfBounds()
end

function Player:bounce(other)
  if self.bouncing then
    return
  end
  if other == "crawler" then
    self:hit(1)
  end
  self.bouncing = true
  self.x_velocity = self.bounciness * -self.last_dir
end

function Player:hit(hit)
  self.hp = self.hp - hit
  if self.hp < 0 then
    print("dead")
  end
end

function Player:filter(other)
  if other.type and other.type == "crawler" then
    return "bounce"
  else
    return "slide"
  end
end

function Player:onLevelLoaded()
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:display_hp()
  for i = 1, self.hp do
    love.graphics.draw(self.heart, (i - 1) * self.heart:getWidth() + i, 59)
  end
end

function Player:new(p, map_width, map_height)
  self.type = "player"
  self.hp = 5
  self.heart = love.graphics.newImage("assets/heart.png")

  -- POSITION
  self.x = p.x
  self.y = p.y
  self.top = p.top
  self.left = p.left
  self.w = p.w
  self.h = p.h

  -- PHYSICS
  self.speed = 50
  self.friction = 5
  self.ground = false
  self.jump_height = -95
  self.gravity = 150
  self.jumping = false
  self.y_velocity = 0
  self.x_velocity = 0
  self.bounciness = 500
  self.bouncing = false

  -- LEVEL BOUNDARIES
  self.east = map_width
  self.south = map_height
  self.north = 0
  self.west = 0

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/player.json",
                    love.graphics.newImage("assets/player.png"), "idle")
  self.last_dir = 1
  self.sprite:play()
end

return Player

