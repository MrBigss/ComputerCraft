require "libs.digFunctions"
-- Inventory manager functions
-- This defines a set of slots to be used for inventory management, and functions to use them.
-- Basically, makes sure there are slots to get materials in.

-- Check prerequisites for module.
if not turtle then error("Inventory manager module requires a Turtle (to place chests)") end

-- ----------------------------------------------------------------------------------------------------
-- Check if a value is a valid turtle inventory slot number.
-- ----------------------------------------------------------------------------------------------------
local function isAValidTurtleSlotNumber(slot)
  local wSlot = tonumber(slot)
  if not wSlot then error("This is not a slot number {" .. slot .. "}") end
  if (wSlot<1 or wSlot>16) then error("Slot number must be 1 to 16, what is this? {" .. slot .. "}") end
  return true
end
-- ----------------------------------------------------------------------------------------------------

local mChestSlots = {}
local mStairsSlots = {}
local mInventorySlots = {}

-- Chest slot
if not gChestSlots then error("The inventory manager module requires slots for chest to be defined") end
for key, slot in ipairs(gChestSlots) do
  if not isAValidTurtleSlotNumber(slot) then print ("Error") end
  mChestSlots[key] = tonumber(slot)
end

-- Stair Slots
if not gStairSlots then error("The inventory manager module requires slots for stairs to be defined") end
for key, slot in ipairs(gStairSlots) do
  if not isAValidTurtleSlotNumber(slot) then print ("Error") end
  mStairsSlots[key] = tonumber(slot)
end

-- Inventory slot
if not gInventorySlots then error("The inventory manager module requires slots for inventory to be defined") end
for key, slot in ipairs(gInventorySlots) do
  if not isAValidTurtleSlotNumber(slot) then print ("Error") end
  mInventorySlots[key] = tonumber(slot)
end


inventorymanager = inventorymanager or {} -- filler 'namespace'.


-- ----------------------------------------------------------------------------------------------------
-- Returns true if all slots are completely full.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.allSlotsAreEmpty(Slots)
  for _, slot in ipairs(Slots) do
    if turtle.getItemCount(slot) ~= 0 then
      return false -- At least one slot has something
    end
  end
  return true -- All slots empty.
end


-- ----------------------------------------------------------------------------------------------------
-- Returns true if all slots are completely full.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.someSlotsAreEmpty(Slots)
  for _, slot in ipairs(Slots) do
    if turtle.getItemCount(slot) == 0 then
      return true -- At least one slot empty
    end
  end
  return false -- All slots have something.
end


-- ----------------------------------------------------------------------------------------------------
-- Returns true if all slots are completely full.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.checkAllSlotsFull(Slots)
  for _, slot in ipairs(Slots) do
    if turtle.getItemSpace(slot) > 1 then
      return false -- Some slots not full.
    end
  end
  return true -- All filler slots are full.
end


-- ----------------------------------------------------------------------------------------------------
-- Selects a non empty (>1) item slot.
-- returns true if ok. Returns false if all slots are at 1 item.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.selectNonEmptySlot(Slots)
  for _, slot in ipairs(Slots) do
    if turtle.getItemCount(slot) > 1 then
      turtle.select(slot)
      return true
    end
  end
  return false
end


-- ----------------------------------------------------------------------------------------------------
-- Wait until all chest slots are filled before continuing.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.waitForAllSlotsToBeFull(Slots, slotName)
  local wFilled = false
  if not inventorymanager.checkAllSlotsFull(Slots) then
    print("Not all " .. slotName .. " slots are full.")
    print("Fill all slots to continue.")
    while not inventorymanager.checkAllSlotsFull(Slots) do
      os.pullEvent("turtle_inventory")
    end
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Get a chest ready.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.getChestReady()
  while not inventorymanager.selectNonEmptySlot(mChestSlots) do
    inventorymanager.waitForAllSlotsToBeFull(mChestSlots, "chest") --This sleeps
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Place chest, and dump inventory into it.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.dumpInventory()
  --Turn around
  turtle.turnRight()
  turtle.turnRight()
  if not tryDig() then error("Could not dig a space for the inventory chest, aborting.") end
  inventorymanager.getChestReady()
  if not turtle.place() then error("Could not place inventory chest, aborting.") end -- Place chest, or die
  for key, slot in ipairs(gInventorySlots) do
    turtle.select(slot)
    turtle.drop()
  end
  --Turn around
  turtle.turnRight()
  turtle.turnRight()
end


-- ----------------------------------------------------------------------------------------------------
-- Check if there is at least one inventory slot completely empty. If not, drop a chest and put 
-- everything in it.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.checkInventoryAndEmptyIfFull()
  if not inventorymanager.someSlotsAreEmpty(mInventorySlots) then
    print("Inventory full, trying to place a chest and to dump everything into the chest.")
    inventorymanager.dumpInventory()
  end
end


-- ----------------------------------------------------------------------------------------------------
-- Place a stair underneath the turtle. Manage if stairs are running out.
-- ----------------------------------------------------------------------------------------------------
function placeStairsUnder()
  if not tryDigDown() then error("Couldn't dig down to put a stair, aborting") end
  -- Get a stair
  while not inventorymanager.selectNonEmptySlot(mStairsSlots) do
    inventorymanager.waitForAllSlotsToBeFull(mStairsSlots, "stairs") --This sleeps
  end
  if not turtle.placeDown() then error("Could not place stair, aborting.") end -- Place stair, or die
end


-- ----------------------------------------------------------------------------------------------------
-- Check if everything is in place before starting up. If not, wait everything is fixed.
-- ----------------------------------------------------------------------------------------------------
function inventorymanager.checkPrerequisites()
  print("Checking inv. manager pre-requisites")
  --Check chest present.
  if not inventorymanager.checkAllSlotsFull(mChestSlots) then
    inventorymanager.waitForAllSlotsToBeFull(mChestSlots, "chest") -- This sleeps
  end
  
  --Check stairs present
  if not inventorymanager.checkAllSlotsFull(mStairsSlots) then
    inventorymanager.waitForAllSlotsToBeFull(mStairsSlots, "stairs") -- This sleeps
  end
  
  --Check inventory empty.
  if not inventorymanager.allSlotsAreEmpty(mInventorySlots) then
    print("Empty all slots designated as 'inventory' to continue")
    while not inventorymanager.allSlotsAreEmpty(mInventorySlots) do
      os.pullEvent("turtle_inventory")
    end
  end
end

