-- Manage a small spruce forest, to produce wood, to be used as charcoal and other things.

gTrashSlot = 15
require "libs.inventorymanager2"
require "libs.displaymanager"

--sapplingInventory  = Inventory.new({1,1}, true, "Sappling")
--print(textutils.serialize(turtle.getItemDetail(1.5)))

-- minecraft:spruce_sapling


-- fuel
local fuelItems = {"minecraft:coal_block", "minecraft:coal", "minecraft:charcoal", "immersiveengineering:coal_coke", "immersiveengineering:coke" }

-- trash items
-- minecraft::cobblestone
-- minecraft:granite
-- minecraft:diorite
-- minecraft:andesite
-- minecraft:dirt
-- minecraft:coarse_dirt
-- minecraft:podzol
-- minecraft:sand
-- minecraft:red_sand
-- minecraft:gravel
-- minecraft:sandstone
-- minecraft:chiseled_sandstone
-- minecraft:cut_sandstone

-- Plant all the sapplings.
--function plantSapplings()
  
--end

-- Method used to wait for tree to grow.
function waitForTree()
  
end


function main()
  --term.clear()
  --term.setCursorPos(1, 1)
  --term.setCursorBlink(false)
  displaymanager:clear()
  --displaymanager:splash()
  
  displaymanager:clear()
  print("---------------------------------------")
  print("- Forestry Manager                    -")
  print("---------------------------------------")
  
  --sleep(3)

  
  inventorymanager:allocateSlots({1,2,3,4}, {"minecraft:spruce_sapling"})
  inventorymanager:allocateSlots({16}, fuelItems)
  displaymanager:setTitle("Forestry Manager v1.0")
  displaymanager:printHud()
  --for i=1,40 do
--    displaymanager:print("Test fsd af" .. i .. " aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
--    displaymanager:error("Test fsd af" .. i .. " aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
--    displaymanager:printHud()
--    sleep(1)
--  end
  --inventorymanager:cleanInventory() -- For when resuming from unloading, and might have inventory.
  
  --print(inventorymanager:selectSlotWithItem({"minecraft:spruce_sapling"}))
  
  --print(inventorymanager:selectSlotWithItem(fuelItems))
  --print("Sappling: " .. inventorymanager:availableItemCount({"minecraft:spruce_sapling"}))
  --print("Fuel: " .. inventorymanager:availableItemCount(fuelItems))
  
  --print("Sappling: " .. inventorymanager:totalItemCount({"minecraft:spruce_sapling"}))
  --print("Fuel: " .. inventorymanager:totalItemCount(fuelItems))

  --print(inventorymanager:hasSpaceLeft())
end


main()
