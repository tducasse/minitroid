local Win = Class:extend()

function Win:new(a, collection)
  self.type = "win"
  self.collection = collection

  -- POSITION
  self.x = a.x
  self.y = a.y
  self.w = a.w
  self.h = a.h

end

return Win
