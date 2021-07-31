local Ero = require("lib.erogodic")
local script

---@diagnostic disable: undefined-global
script = Ero(
             function()
      name "Someone"
      msg "Hello, the game is going to start. But first choose an item"
      local item1 = option "Item 1"
      local item2 = option "Item 2"
      menu "Select your item"
      if selection(item1) then
        giveItem("Item 1")
      elseif selection(item2) then
        giveItem("Item 2")
      end
      msg "Let's go!"
    end)

script:defineAttributes({ "name" })

script:addMacro(
    "giveItem", function(item)
      local lastName = get("name")
      name ""
      msg("You chose " .. item .. "!")
      name(lastName)
    end)

---@diagnostic enable: undefined-global

return script
