-- Manage a small spruce forest, to produce wood, to be used as charcoal and other things.

if not os.computerLabel() then
  error("Put a label on your computer")
end

gTrashSlot = 15
require "libs.inventorymanager2"
require "libs.displaymanager"
require "libs.digFunctions"

-- Sapling
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

gTotalLogsCut = 0 -- How many logs where harvested, total.
gMinimumFuelLevel = 200 -- How much fuel to have for each "run". Should be adjusted to at least be enough for one "job".


-- Do one "leg" of sucking. Turtle will look opposite direction when it comes back, manage that outside.
-- Does more turns than necessary, but looks better.
-- TODO : Add asserts to bail out if movement doesn't work.
function moveTwoForwardsSuckAroundGoBack()
  tryForward() turtle.suck() sleep(0.25)
  tryForward()
  displaymanager:printHud() -- Spam these a couple of place.
  turtle.turnRight() turtle.suck() sleep(0.25)
  turtle.turnLeft() turtle.suck() sleep(0.25)
  turtle.turnLeft() turtle.suck() sleep(0.25)
  turtle.turnLeft() turtle.suck() sleep(0.25)
  tryForward()
  tryForward()
  displaymanager:printHud() -- Spam these a couple of place.
  -- Add back these if the turtle should reset to face the same direction.
  --turtle.turnRight() sleep(0.25)
  --turtle.turnRight() sleep(0.25)
end


-- Do the sucking around the tree base. This should reasonably get "enough" sappling.
function pickUpSaplingsAroundTreeBase()
  displaymanager:print("Trying to suck up sapling around the tree")
  -- Suck on the left of initial position.
  turtle.turnLeft() sleep(0.25)
  moveTwoForwardsSuckAroundGoBack()
  displaymanager:printHud() sleep(1)
  
  -- Suck in front of initial position
  turtle.turnLeft() sleep(0.25)
  moveTwoForwardsSuckAroundGoBack()
  displaymanager:printHud() sleep(1)

  -- Suck on the right of initial position.
  turtle.turnLeft() sleep(0.25)
  moveTwoForwardsSuckAroundGoBack()
  displaymanager:printHud() sleep(1)
  
  turtle.turnLeft() turtle.suck() sleep(0.25)
  
  --Finish facing the same way.
  turtle.turnLeft() turtle.turnLeft() sleep(0.25)
  displaymanager:print("Done sucking")
end


-- Place a sapling. If can't find any, wait for some to be added to inventory.
function placeSapling()
  displaymanager:print("Trying to place a sapling")
  while not inventorymanager:selectSlotWithItem({"minecraft:spruce_sapling"}) do
    displaymanager:error("No spruce sapling. Add spruce sapling.")
    os.pullEvent("turtle_inventory") -- Wait for an inventory event.
    inventorymanager:cleanInventory()
    sleep(0.25) -- In case inventory gets spammed with something like mousewheelie.
  end
  displaymanager:clearError()
  -- Remove possible crap in the sapling spot.
  tryDig()
  assert(turtle.place(), "Major error, couldn't place sapling, aborting")
  displaymanager:print("Placed a sapling")
end


-- Wait for a tree to grow. Just check for when a block "shows up".
-- Could also use 'local has_block, data = turtle.inspect()' to detect fuckery and abort.
function detectTreeGrowth()
  displaymanager:print("Waiting for tree to grow")
  local growTimer = 0
  while not turtle.detect() do
    sleep(10)
    growTimer = growTimer + 10
    displaymanager:clearError()
    displaymanager:error("Waited for sapling for " .. growTimer .. " seconds")
  end
  displaymanager:clearError()
  displaymanager:print("Sapling has grown!")
end


-- Cut a tree. While standing in front of the tree, go into the tree, and cut the tree.
-- Go back down, and move back to initial position.
-- Count how many logs we got.
-- Anounce
function cutTree()
  displaymanager:print("Cutting the tree down.")
  tryForward()
  local treeHeight = 0
  
  while turtle.detectUp() do
    assert(tryUp(), "Could not dig up/move up, this would break everything. Abort")
    treeHeight = treeHeight + 1
    sleep(0.25)
  end
  
  -- Reached the top
  displaymanager:print("  Reached top of tree, coming back down.")
  
  -- Go back down.
  for i=1, treeHeight do
    assert(tryDown(), "Could not dig down/move down, this would break everything. Abort")
  end
  displaymanager:print("  Reached bottom of tree.")
  
  -- Move back, or die.
  assert(turtle.back(), "Turtle couldn't move back, this would break everything, aborting")
  
  -- Count how many logs we have in the inventory.
  -- gTotalLogsCut
  local logCount = inventorymanager:totalItemCount({"minecraft:spruce_log"})
  gTotalLogsCut = gTotalLogsCut + logCount
  
  displaymanager:print("Finished cutting the tree down.")
  displaymanager:print("  Got " .. logCount .. " logs")
  displaymanager:print("  Total logs this session :" .. gTotalLogsCut)
end


-- Given being in front of a chest which contains "fuels"
-- and given a slot for fuel
-- Refuel the turtle
function refuelFromChest()
  if turtle.getFuelLevel() < gMinimumFuelLevel then
    displaymanager:print("  Fuel below " .. gMinimumFuelLevel .. " refueling")
    -- Refuel with one fuel until enough fuel in the turtle.
    while turtle.getFuelLevel() < gMinimumFuelLevel do
      inventorymanager:cleanInventory() -- Make sure everything is in the right place.
      if not inventorymanager:selectSlotWithItem(fuelItems) then
        displaymanager:error("Could not get fuel, trying with chest.")
        
        while not inventorymanager:selectSlotWithItem(fuelItems) do
          turtle.suck() --Get things from the chest.
          inventorymanager:cleanInventory() -- Make sure everything is in the right place.
          inventorymanager:dumpCargo() -- In case crap made it. If only crap present, it'll loop, even fuel exists in chest. Sad.
          sleep(10) -- Can't wait with pull event, won't see change in chest.
        end
        turtle.refuel(1) -- Just use one fuel, don't want to over fuel
        displaymanager:clearError()
      end
    end
    displaymanager:clearError()
    displaymanager:print("  Turtle refueled")
  end
end


-- Suck some saplings out of the chest, until we have at least one usable.
function refillSaplingsFromChest()
  if inventorymanager:availableItemCount({"minecraft:spruce_sapling"}) < 1 then
    displaymanager:print("  Getting more saplings from chest.")
    while inventorymanager:availableItemCount({"minecraft:spruce_sapling"}) < 1 do
      turtle.suck() --Get things from the chest.
      inventorymanager:cleanInventory() -- Make sure everything is in the right place.
      inventorymanager:dumpCargo() -- In case crap made it. If only crap present, it'll loop, even fuel exists in chest. Sad.
      sleep(10) -- Can't wait with pull event, won't see change in chest.
      if inventorymanager:availableItemCount({"minecraft:spruce_sapling"}) < 1 then
        displaymanager:error("Could not get sapling from chest, trying again.")
      end
    end
    displaymanager:clearError()
    displaymanager:print("  Got more saplings from chest.")
  end
end


-- Manage inventory. If inventory can't be cleared, or fuel and/or sapling are missing, wait for them to show up.
-- Go to the chests (2 back)
-- Drop in the chest in front.
-- Suck sapling from left chest (if needed)
-- Suck fuel from right chest (if needed)
-- refuel.
function doInventoryManagement()
  displaymanager:print("Managing inventory and refuelling.")
  turtle.turnRight() turtle.turnRight() sleep(0.25)
  turtle.forward() turtle.forward() sleep(0.25)
  
  inventorymanager:cleanInventory() -- Clean the inventory first. This will place sapling and fuel that got collected in the right slots.
  
  -- Dump cargo inventory in front chest.
  displaymanager:print("  Dumping cargo")
  if not inventorymanager:dumpCargo() then
    displaymanager:error("Target inventory chest is full, empty it to continue!")
    while not inventorymanager:dumpCargo() do inventorymanager:cleanInventory() sleep(10) end
    displaymanager:clearError()
  end
  
  inventorymanager:cleanInventory() -- Do a second pass.
  
  -- Get saplings from left chest.
  displaymanager:print("  Restocking on saplings")
  turtle.turnLeft()  sleep(0.25)
  refillSaplingsFromChest()
  inventorymanager:cleanInventory() -- Do a second pass.

  -- Getting fuel, if fuel is low.
  displaymanager:print("  Checking fuel level")
  turtle.turnRight() turtle.turnRight()  sleep(0.25)
  refuelFromChest()
  inventorymanager:cleanInventory() -- Do a second pass.
  
  -- Go back to initial position
  turtle.turnRight() sleep(0.25)
  turtle.forward() turtle.forward() sleep(0.25)
end


-- This is the dumb thing, when doing just one tree, with one wide trunk.
-- Better have this running than nothing while making the rest.
function singleTreeManagement()
  -- Plant sappling.
  -- Move one up, wait for sappling to grow.
  -- Go down, go forward. Now under tree.
  -- Cut up until no block left.
  -- Go back down same amount.
  -- Now at tree base.
  -- Move two forward, suck around.
  -- Move back to.
  -- Move back once, turn around, dump inventory.
  doInventoryManagement() -- Startup, try to get everything needed from inventories.
  while true do
    inventorymanager:cleanInventory() displaymanager:printHud()
    placeSapling() -- Also digs if something is there.
    tryUp() -- Move one up where the trunk will grow.
    detectTreeGrowth() -- Wait for the tree to grow.
    tryDown() -- Go back in front of the tree.
    inventorymanager:cleanInventory() displaymanager:printHud()
    cutTree() -- Cut the tree.
    inventorymanager:cleanInventory() displaymanager:printHud()
    turtle.forward() pickUpSaplingsAroundTreeBase() turtle.back()  -- Pick up sapling (and sticks) from ground.
    inventorymanager:cleanInventory() displaymanager:printHud()
    doInventoryManagement() -- Drop logs and excess saplings, get fuel, get sapling, refuel.
  end
  
end


-- It's like a void main (void) or something!
function main()
  displaymanager:clear()
  
  inventorymanager:allocateSlots({1,2,3,4}, {"minecraft:spruce_sapling"})
  -- Maybe add auto bonemealing, if bonemeal exist in inventory?
  inventorymanager:allocateSlots({16}, fuelItems)
  
  displaymanager:setTitle("Forestry Manager v1.0")
  displaymanager:printHud()
  
  
  -- For now, do the single tree management routine.
  -- TODO : Do for large 2x2 spruce
  -- TODO2: Do for a "couple" of large 2x2 spruces.
  singleTreeManagement()
  
end


main()
