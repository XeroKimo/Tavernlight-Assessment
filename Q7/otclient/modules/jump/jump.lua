local jumpWindow
local jumpButton
local slidingButton

-- I figured that positions are ints, so in order to be able to accumulate position over time
-- I'm storing the subpositions in a accumulator
local xAccumulator = 0

-- The speed at which the button will slide across the window
local slidingSpeed = 200

-- will be used to detect the valid positions the sliding button can exist in
local boundingBox

-- some hard coded value I chose that appears to be close enough as the actual margin the code
-- auto aligns to if I don't constantly force a button to change positions and would go out of bounds
local margin = 16

-- some hard coded value that seems to be close enough of the actual offset I have to take into account
-- for the title bar of the window
local titleBarMargin = 20

-- some of these functions are just copy overs from a reference window, I used the option's window in this case
-- as it had many things that I would've needed, like the button already existing. Just had to strip everything
-- that wasn't needed, and figure out how to connect things from there
function init()
  jumpWindow = g_ui.displayUI('jump')
  jumpWindow:hide()
  jumpButton = modules.client_topmenu.addRightButton('jumpButton', tr('Jump!'), '/images/topbuttons/options', toggle)
  slidingButton = jumpWindow:getChildById('slidingButton')
  recalculateBoundingBox()
end

function terminate()
  g_keyboard.unbindKeyDown('Ctrl+Shift+F')
  g_keyboard.unbindKeyDown('Ctrl+N')
  jumpWindow:destroy()
  jumpButton:destroy()
end

function recalculateBoundingBox()
  boundingBox = jumpWindow:getRect()
  boundingBox.x = boundingBox.x + margin
  boundingBox.y = boundingBox.y + margin + titleBarMargin

  -- I'm not quite sure as to why I have to subtract the margin twice, it just got to a closer number
  -- as to the maximum position of the button
  boundingBox.width = boundingBox.width - slidingButton:getWidth() - margin * 2
  boundingBox.height = boundingBox.height - slidingButton:getHeight() - margin * 2 - titleBarMargin
end

function toggle()
  if jumpWindow:isVisible() then
    hide()
  else
    show()
  end
end

function onGeometryChanged(oldRect, newRect)
  recalculateBoundingBox()
end

function randomYPos()
  return math.random(boundingBox.y, boundingBox.y + boundingBox.height)
end

-- I dunno how to comment .otui files so I'll just comment here
-- I bounded the button's on click event to this function so that we reset every single time its clicked
function resetButtonPosition()
  local pos = { x = boundingBox.x + boundingBox.width , y = randomYPos() }
  print(recttostring(boundingBox))
  slidingButton:setPosition(pos)
end

function show()
  -- whenever we show the window, make sure to put the position of the button back to the right of the window
  resetButtonPosition()
  jumpWindow:show()
  jumpWindow:raise()
  jumpWindow:focus()
end

function hide()
  jumpWindow:hide()
end

-- bounded the window's onTick event to this function so that we can slide our button around.
-- I couldn't figure out any other way to this aside from hacking in my own tick function
-- Just realized as I'm writing this comment that I could've bounded a function to addEvent()
-- and every single time it ran, that I call addEvent() again, which would allow me to make my
-- own fixed update kind of function... well rip my 2 days of trying to figure out how everything
-- related to UI worked and getting this tick function to exist
function onTick()
  xAccumulator = xAccumulator + slidingSpeed * g_clock.deltaTime();

  -- Every time xAccumulator reaches some number, we'll update the position of the sliding button
  -- I chose 20 at random as it appears to look close enough to what the video was doing
  if xAccumulator > 20 then
    local nearestInt = math.floor(xAccumulator)
    xAccumulator = xAccumulator - nearestInt
    local pos = { x = slidingButton:getX() - nearestInt, y = slidingButton:getY() }
    slidingButton:setPosition(pos)
    
    if slidingButton:getX() <= boundingBox.x then
      resetButtonPosition()
    end
  end
end