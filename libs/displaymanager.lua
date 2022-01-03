-- Simple display manager
-- Made for turtles, with a 13x39 display
-- Split the screen in sections, to print some "permanent" information.

-- Check prerequisites for module.
if not turtle then error("Display manager module requires a Turtle") end

term.setCursorBlink(false)
displaymanager = displaymanager or {} -- filler 'namespace'.



-- ----------------------------------------------------------------------------------------------------
function displaymanager:clear()
  term.clear()
  term.setCursorPos(1, 1)
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:printLine()
  local width, _ = term.getSize()
  term.write(string.rep("-", width))
end

function displaymanager:printLineWithText(string)
  string = tostring(string)
  local x,y = term.getCursorPos()
  local width, _ = term.getSize()
  for i=1,width do
    term.write("-")
  end
  term.setCursorPos(x+1,y)
  term.write(" " .. string .. " ")
end


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
local gProgName = "Untitled"
local gTextLines = {}
local gTextLinesIndex = 0
local gTextLinesSize = 7
for i=1,gTextLinesSize do gTextLines[i] = "" end

local gErrorLines = {}
local gErrorLinesIndex = 0
local gErrorLinesSize = 3
for i=1,gErrorLinesSize do gErrorLines[i] = "" end

-- 13 lines, 39 characters
-- Title 2 lines

-- Text 7 lines
-- Separator 1 line
-- Error 3 lines

-- ----------------------------------------------------------------------------------------------------
function displaymanager:setTitle(progName)
  assert(type(progName)=='string', "Title needs to be a string")
  assert(string.len(progName) <= 25, "Title needs to be max 25 char")
  gProgName = progName
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:print(string)
  local width, _ = term.getSize()
  string = tostring(string)
  string = string.sub(string, 1, width)
  gTextLines[gTextLinesIndex+1] = string
  gTextLinesIndex = gTextLinesIndex + 1
  gTextLinesIndex = (gTextLinesIndex % gTextLinesSize)
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:clearText()
  for i=1,gTextLinesSize do gTextLines[i] = "" end
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:error(string)
  local width, _ = term.getSize()
  string = tostring(string)
  string = string.sub(string, 1, width)
  gErrorLines[gErrorLinesIndex+1] = string
  gErrorLinesIndex = gErrorLinesIndex + 1
  gErrorLinesIndex = (gErrorLinesIndex % gErrorLinesSize)
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:clearError()
  for i=1,gErrorLinesSize do gErrorLines[i] = "" end
end


-- ----------------------------------------------------------------------------------------------------
function displaymanager:printHud()
  local width, height = term.getSize()
  
  displaymanager:clear()

  -- Print header, 1 line, 1 separator
  term.setCursorPos(1, 1) write(gProgName)
  if type(turtle.getFuelLevel())=='number' then
    local fuelLevel = turtle.getFuelLevel()
    term.setCursorPos(width+1-10, 1) write( ("Fuel:%05d"):format(fuelLevel) )
  else
    term.setCursorPos(width+1-10, 1) write("Fuel: Inf ")
  end
  print() -- crlf
  
  -- Print text
  -- It's like a bad circular buffer implementation!
  term.setCursorPos(1, 2) displaymanager:printLineWithText("Out:")
  local txtPos = 3
  for i=gTextLinesIndex,gTextLinesSize-1 do
    term.setCursorPos(1, txtPos) write(gTextLines[i+1])
    txtPos = txtPos + 1
  end

  for i=0,gTextLinesIndex-1 do
    term.setCursorPos(1, txtPos) write(gTextLines[i+1])
    txtPos = txtPos + 1
  end

  --term.setCursorPos(1, 10) displaymanager:printLine()
  -- Print error zone, 3 lines
  term.setCursorPos(1, 10) displaymanager:printLineWithText("Err:")
  local txtPos = 11
  for i=gErrorLinesIndex,gErrorLinesSize-1 do
    term.setCursorPos(1, txtPos) write(gErrorLines[i+1])
    txtPos = txtPos + 1
  end

  for i=0,gErrorLinesIndex-1 do
    term.setCursorPos(1, txtPos) write(gErrorLines[i+1])
    txtPos = txtPos + 1
  end  
end











