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
    y = self.north + self.h / 3
    self.jumping = false
    self.rolling = false
  elseif self.y < self.north - self.h / 3 then
    dir = "n"
    y = self.south - self.h - self.h / 3
    self.jumping = false
    self.rolling = false
  end
  if dir then
    self:stop_rolling()
    Signal.emit(SIGNALS.NEXT_LEVEL, dir)
    self.world:remove(self)
    self.x = x
    self.y = y
  end
end

function Player:start_rolling()
  self.rolling = true
  self.x = self.x - self.rolling_x
  self.world:update(
      self, self.x + self.rolling_x, self.y + self.rolling_y, self.rolling_w,
      self.rolling_h)
  self.sprite:setTag("ball")
end

function Player:stop_rolling()
  self.rolling = false
  self.x = self.x + self.rolling_x
  self.world:update(self, self.x, self.y, self.w, self.h)
  self.sprite:setTag("idle")
end

function Player:update(dt, world)
  self.sprite:update(dt)

  if not self.world and world then
    self.world = world
  end

  local x, y = self.x, self.y
  local x_axis = Input:get("move")

  local still_shooting = self.shooting and
                             (love.timer.getTime() - self.shooting < 0.2)
  if not still_shooting and self.shooting then
    self.shooting = false
  end

  if math.abs(self.x_velocity) > 10 then
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

  if self.ground then
    if Input:pressed("down") and self.roll then
      self:start_rolling()
    end
  end
  if Input:pressed("up") and self.rolling and not self.ceiling then
    self:stop_rolling()
  end

  if not self.bouncing then
    if x_axis > 0 then
      self.x_velocity = self.speed
      if self.ground then
        if self.rolling then
          self.sprite:setTag("rolling")
        else
          self.sprite:setTag("run")
        end
      end
      self.last_dir = 1
    elseif x_axis < 0 then
      self.x_velocity = -self.speed
      if self.ground then
        if self.rolling then
          self.sprite:setTag("rolling")
        else
          self.sprite:setTag("run")
        end
      end
      self.last_dir = -1
    else
      if self.ground then
        if self.rolling then
          self.sprite:setTag("ball")
        else
          self.sprite:setTag("idle")
        end
      end
    end

    if Input:down("jump") and not self.rolling then
      if self.ground and not self.jumping then
        love.audio.play("assets/jump.ogg", "static", nil, 0.7)
        self.jumping = true
        self.y_velocity = self.jump_height
      end
    end

    if Input:released("jump") then
      self.jumping = false
    end

    if Input:down("shoot") and not self.rolling then
      if not self.shooting then
        love.audio.play("assets/shoot.ogg", "static", nil, 0.3)
        self.sprite:setTag("shoot")
        self.shooting = love.timer.getTime()
        Signal.emit(
            SIGNALS.SHOOT, self.x + (self.last_dir > 0 and self.w or 0),
            self.y + self.gun_height, self.last_dir, 0)
      end
    end
  end

  x = self.x + self.x_velocity * dt + 0.000001
  y = self.y + self.y_velocity * dt + 0.000001
  self.y_velocity = self.y_velocity + self.gravity * dt

  local cols
  if self.rolling then
    local newX, newY = 0, 0
    newX, newY, cols = self.world:move(
                           self, x + self.rolling_x, y + self.rolling_y,
                           self.filter)
    self.x, self.y = newX - self.rolling_x, newY - self.rolling_y
  else
    self.x, self.y, cols = self.world:move(self, x, y, self.filter)
  end

  local ground = false
  for _, col in pairs(cols) do
    if col.type == "cross" then
      self:cross(col.other)
    elseif col.type == "bounce" then
      self:bounce(col.other)
    elseif col.normal.y == 1 then
      self.y_velocity = 0
    elseif col.normal.y == -1 then
      ground = true
      self.y_velocity = 0
    end
  end

  self.ground = ground

  if not self.ground and not self.rolling then
    self.sprite:setTag("jump")
  end

  if still_shooting then
    self.sprite:setTag("shoot")
  end

  local _, _, cols = world:check(self, self.x, self.y - self.rolling_y)
  self.ceiling = false
  for _, col in pairs(cols) do
    if col.normal.y == 1 then
      self.ceiling = true
    end
  end

  self:moveOutOfBounds()
end

function Player:bounce(other)
  if self.bouncing then
    return
  end
  if other.type == "crawler" then
    self:hit(1)
  end
  self.bouncing = true
  local diff = (self.x + self.w / 2) - (other.x + other.w / 2)
  local dir = diff / math.abs(diff)
  self.x_velocity = self.bounciness * dir
end

function Player:cross(other)
  if other.type == "item" then
    love.audio.play("assets/pickup.ogg", "static", nil, 0.7)
    if other.item == "ball" then
      other:destroy()
      self.roll = true
    end
  end
end

function Player:hit(hit)
  love.audio.play("assets/hurt.ogg", "static", nil, 0.7)
  self.hp = self.hp - hit
  Signal.emit(SIGNALS.HIT)
  if self.hp < 0 then
    print("dead")
  end
end

function Player:filter(other)
  if other.type then
    if other.type == "crawler" then
      if not self.bouncing then
        return "bounce"
      else
        return nil
      end
    elseif other.type == "bullet" then
      return nil
    elseif other.type == "item" then
      return "cross"
    end
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
  self.rolling_h = p.rolling_h
  self.rolling_w = p.rolling_w
  self.rolling_x = p.rolling_x
  self.rolling_y = p.rolling_y

  -- SHOOTING
  self.shooting = false
  self.gun_height = self.h - 5

  -- PHYSICS
  self.speed = 50
  self.friction = 5
  self.ground = false
  self.ceiling = false
  self.jump_height = -95
  self.gravity = 150
  self.jumping = false
  self.y_velocity = 0
  self.x_velocity = 0
  self.bounciness = 600
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

