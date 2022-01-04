-- Inventory manager - Version 2.0
-- This defines a "framework" to manage the inventory.
-- Preventing some slots from getting emptied.
-- Making some slots into general storage. (cargo)
-- And basically making management based on item names instead of slot numbers, when possible.


-- Check prerequisites for module.
if not turtle then error("Inventory manager module requires a Turtle") end

-- ----------------------------------------------------------------------------------------------------
-- Utility functions.
-- ----------------------------------------------------------------------------------------------------

-- Check that the parameter is a number, and a valid slot number
function isValidSlotNumber(slot)
  if type(slot)=='number' and math.floor(slot) == slot and slot >= 1 and slot <= 16 then 
    return true
  else
    return false
  end
end


-- Check that a number is a number.
function isValidNumber(count)
  if type(count)=='number' then return true else return false end
end


-- Get the number of elements in a table (used to check if no name assigned to a slot)
function tableSize(iTable)
  local len = 0
  for _, _ in pairs(iTable) do len = len + 1 end
  return len
end


-- Try to get rid of trash.
function throwTrash(slot)
  local previousSlot = turtle.getSelectedSlot()
  turtle.select(slot)
  if not turtle.drop() and not turtle.dropUp() and not turtle.dropDown() then
    turtle.select(previousSlot)
    return false
  else
    turtle.select(previousSlot)
    return true
  end
end


-- Check that the item list is a table, containing strings.
function assertIsTableOfStings(itemsTable)
  assert(type(itemsTable)=='table', "Item names must be in a table format")
  for _, itemName in ipairs(itemsTable) do assert(type(itemName)=='string', "Item names need to be strings") end
end

-- ----------------------------------------------------------------------------------------------------
-- Main "object"
-- Initializations.
-- ----------------------------------------------------------------------------------------------------

gCargoSlotName = "cargo" -- The name that can be given to a slot to be used as generic cargo.
gTrashSlotName = "trash" -- The name that can be given to a slot to be used as a swap/trash slot. Will always be dumped at all time.

if not gTrashSlot then error("Inventory manager needs a trash slot designated with the variable 'gTrashSlot'") end
if not isValidSlotNumber(gTrashSlot) then error("Trash slot must be a valid inventory slot number") end

inventorymanager = inventorymanager or {} -- filler 'namespace'.

-- List of the slots, and which items they are assigned to them.
-- If no items are assigned to them, then these slots are generic cargo slots.
-- If emptying "the inventory", the it'll only empty the generic cargo slots.
-- If asked to select a item, but there's not enough, it'll say false, and select the first generic cargo slot.
inventorymanager.gInventory = {}
for i = 1, 16 do inventorymanager.gInventory[i] = {} end -- Initialize inventory management.
inventorymanager.gInventory[gTrashSlot] = {gTrashSlotName}

-- ----------------------------------------------------------------------------------------------------
-- "Private" Inventory management functions.
-- ----------------------------------------------------------------------------------------------------


-- Return a list of the slots which have no items assigned to them.
function inventorymanager:findUnassignedSlots()
  local slots = {}
  for i = 1, 16 do
    if tableSize(inventorymanager.gInventory[i]) == 0 then -- If no names assigned to that inventory slot.
      table.insert(slots, i)
    end
  end
  return slots
end


-- Check if a slot is assigned already or not.
-- True if assigned, false if not.
function inventorymanager:isSlotAssigned(slot)
  return tableSize(inventorymanager.gInventory[slot]) > 0 or slot == gTrashSlot
end

-- Check if a slot is assigned already, and not the trash slot.
function inventorymanager:isSlotAssignedAndNotTrash(slot)
  return tableSize(inventorymanager.gInventory[slot]) > 0 and slot ~= gTrashSlot
end


-- Unassign a slot
function inventorymanager:unassignSlot(slot)
  if slot == gTrashSlot then error("Trying to unassign the trash slot") end
  inventorymanager.gInventory[slot] = {}
end


-- Check if an item matches the assigned item in an assigned slot.
-- Fails if not item assigned.
function inventorymanager:matchesAssignedItems(slot, item)
  for _, assignedItem in ipairs(inventorymanager.gInventory[slot]) do
    if assignedItem == item then return true end
  end
  return false
end


-- Show which slots are assigned what.
-- Debug, don't use (much)
function inventorymanager:printSlotAssignations()
  for slot=1,16 do
    if inventorymanager:isSlotAssigned(slot) then
      local items = ""
      for _, item in ipairs(inventorymanager.gInventory[slot]) do
        items = items .. item .. " "
      end
      print("Slot " .. slot .. " assigned " .. items)
    end
  end
end


-- ----------------------------------------------------------------------------------------------------
-- "Public" Inventory management functions.
-- This is what the user of this library "should" be using.
-- ----------------------------------------------------------------------------------------------------


-- Allocate some slots to a certain item. Make sure slots don't overlap.
-- If can be allocated, returns true. If slot already reserved, return false.
function inventorymanager:allocateSlots(slots, itemNames)
  assertIsTableOfStings(itemNames)
  --assert(type(itemNames)=='table', "Item names must be in a table format")
  --for _, itemName in ipairs(itemNames) do assert(type(itemName)=='string', "Item names need to be strings") end
  assert(type(slots)=='table', "Slots must be in a table format")
  for _, slot in ipairs(slots) do assert(isValidSlotNumber(slot), "Slots numbers need to a whole number between 1 and 16") end
  
  table.sort(itemNames)
  table.sort(slots)
  
  for _, slot in pairs(slots) do
    if inventorymanager:isSlotAssigned(slot) then error("Slot " .. slot .. " was already assigned to something else, or the trash slot.") end
    inventorymanager.gInventory[slot] = itemNames
  end
end


-- Clean the inventory, and sort it.
-- First, slot by slot, if it's an assigned slot, try to find more of the same item from other non-assigned slot, and fill the slot with it.
-- Skip unassigned slot for this.
-- (Don't steal last item if reserved slot.)
-- Is it the smoothest, or the most optimal? Nope. Do I care? Bro, I'm playing Minecraft, it's good enough.
function inventorymanager:cleanInventory()
  --throwTrash(gTrashSlot)
  for slot=1,16 do
    turtle.select(slot) -- Just to give an indication of where we are.
    if inventorymanager:isSlotAssigned(slot) and slot~=gTrashSlot then
      --Throw crap out if item is not on list of assigned item.
      if turtle.getItemCount(slot) > 0 then
        -- Move items out of the slot, if they aren't of the assigned type.
        if not inventorymanager:matchesAssignedItems(slot, turtle.getItemDetail(slot).name) then
          --print(turtle.getItemDetail(slot).name .. " doesn't belong in slot " .. slot)
          -- Find a slot to put the stuff in it.
          trashSlot = gTrashSlot
          for nextSlot=slot,16 do
            if turtle.getItemCount(nextSlot) == 0 then trashSlot = nextSlot end
          end
          throwTrash(trashSlot) --If empty, not a problem. If none found, empties thrash slot.
          turtle.select(slot)
          turtle.transferTo(trashSlot)
        end
      end
      
      -- Try to find item in all unassigned slot to steal from, steal it all.
      for sourceSlot=1,16 do
        --turtle.select(sourceSlot)
        if turtle.getItemCount(sourceSlot) > 0 and 
          not inventorymanager:matchesAssignedItems(sourceSlot, turtle.getItemDetail(sourceSlot).name)
          and inventorymanager:matchesAssignedItems(slot, turtle.getItemDetail(sourceSlot).name)
          then
          --print("Things in slot " .. sourceSlot .. " don't match assigned type")
          turtle.select(sourceSlot)
          turtle.transferTo(slot)
        end
      end
      
      -- If we still don't have an item in our slot.
      -- Check to find stuff from previous slots, and if another slot has it, and has more than one, then steal one to set the slot.
      -- if another slot has it, and has no item assigned to the slot, steal it all.
      if turtle.getItemCount(slot) == 0 then
        for sourceSlot=1,slot do
          if turtle.getItemCount(sourceSlot) > 1 and inventorymanager:matchesAssignedItems(slot, turtle.getItemDetail(sourceSlot).name) then
            turtle.select(sourceSlot)
            turtle.transferTo(slot, 1)
          end
        end
      end
    end
  end
end


-- Select a slot with the requested items, which has more than one item.
-- Any slot containing any of the items in the list. (For example, fuel.)
-- If not enough item, also select the trash slot. (In case the result is ignored.)
-- Return true if possible, false if not enough items, or no items.
function inventorymanager:selectSlotWithItem(items)
  assertIsTableOfStings(items)
  
  local wAssignedSlotFound = nil
  -- Do a first pass to get it from the slots with no assignation, first.
  for slot=1,16 do
    for _, item in ipairs(items) do
      if not inventorymanager:isSlotAssignedAndNotTrash(slot) then
        if turtle.getItemCount(slot) > 0 and turtle.getItemDetail(slot).name == item then
          turtle.select(slot)
          return true
        end
      else
        -- Check also if that would work as a slot with assignation, but with more than one item. Just so we don't do the for twice.
        if turtle.getItemCount(slot) > 1 and turtle.getItemDetail(slot).name == item then
          wAssignedSlotFound = slot
        end
      end
    end
  end

  if wAssignedSlotFound then
    turtle.select(wAssignedSlotFound)
    return true
  end
  
  turtle.select(gTrashSlot)
  return false
end


-- Count how many of the items is available.
-- Take into account that items in assigned slot can only use "count-1" items.
function inventorymanager:availableItemCount(items)
  assertIsTableOfStings(items)
  local totalCount = 0
  for _, item in ipairs(items) do
    for slot=1,16 do
      if turtle.getItemCount(slot) > 0 and turtle.getItemDetail(slot).name == item then
        local slotCount = turtle.getItemCount(slot)
        if inventorymanager:isSlotAssignedAndNotTrash(slot) then
          totalCount = totalCount + slotCount - 1
        else
          totalCount = totalCount + slotCount
        end
      end
    end
  end
  return totalCount
end


-- Count how many of the items are present
-- Don't take into account that items in assigned slot can only use "count-1" items.
function inventorymanager:totalItemCount(items)
  assertIsTableOfStings(items)
  local totalCount = 0
  for _, item in ipairs(items) do
    for slot=1,16 do
      if turtle.getItemCount(slot) > 0 and turtle.getItemDetail(slot).name == item then
        totalCount = totalCount + turtle.getItemCount(slot)
      end
    end
  end
  return totalCount
end


-- Check if there is "space left". This is defined as having any non assigned slot (even trash) as not having any item.
function inventorymanager:hasSpaceLeft()
  for slot=1,16 do
    if not inventorymanager:isSlotAssignedAndNotTrash(slot) and turtle.getItemCount(slot)==0 then
      return true
    end
  end
  return false
end


-- Dump cargo into a chest in front. (Includes the trash slot if it has anything.)
function inventorymanager:dumpCargo()
  local couldDump = true
  for slot=1,16 do
    if not inventorymanager:isSlotAssigned(slot) then
      turtle.select(slot)
      if turtle.getItemCount() > 0 and not turtle.drop() then couldDump = false end
    end
  end
  return couldDump
end












