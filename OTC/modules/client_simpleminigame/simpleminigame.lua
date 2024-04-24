Minigame = {}
local minigameWindow  -- The window where the minigame will take place.
local minigameMenuButton  -- The button that will let us open the minigame window.
local minigameJumpButton  -- The button in the actual minigame which we will be playing.

local jumpButtonMoveSpeed = 10  -- The amount of pixels to move at every update.
local jumpButtonMoveInterval = 50  -- Time between every update, in milliseconds.

local running = false  -- Whether the minigame window is open or not

-- The window's padding, i.e. the boundaries within the window that the jump button will be confined to,
-- to prevent it from clipping out of the window or hugging its borders too closely.
local rightPadding = 100
local leftPadding = 50
local topPadding = 50
local botPadding = 100

-- Generates new randomized coordinates on the right of the padded area, at a random height.
local function getNewJumpButtonCoords()
  local rect = minigameWindow:getRect()
  local x = rect.x + rect.width - rightPadding
  local y = math.random(rect.y + topPadding, rect.y + rect.height - botPadding)
  return x,y
end

-- Moves the jump button back to the right side of the window
local function resetJumpButton()
  local x, y = getNewJumpButtonCoords()
  minigameJumpButton:setX(x)
  minigameJumpButton:setY(y)
end

-- Keeps the button moving leftwards until it is clicked or it reaches the end of the window
local function moveJumpButton()
  if minigameJumpButton then
    local rect = minigameJumpButton:getRect()
    if rect.x - minigameWindow:getX() < leftPadding then
      resetJumpButton()
    else
      minigameJumpButton:setX(rect.x - jumpButtonMoveSpeed)
    end
    scheduleEvent(moveJumpButton, jumpButtonMoveInterval)  -- This event keeps calling this function every few milliseconds,
                                                           -- acting as a sort of update function for our minigame.
  end
end

-- On module initialization we connect lua bindings and create a button to toggle the minigame in and out, on the top menu module.
function init()
  connect(g_game, { onOpenMinigameWindow = Minigame.create,
                    onGameEnd = Minigame.destroy })
  minigameMenuButton = modules.client_topmenu.addLeftButton('minigameMenuButton', tr('Simple Minigame'), '/images/topbuttons/terminal', toggle)
end

-- When the module is unloaded (like on exiting the client) we disconnect the bindings and delete all related variables, including the top menu button.
function terminate() 
  disconnect(g_game, { onOpenMinigameWindow = Minigame.create,
                       onGameEnd = Minigame.destroy })
  minigameMenuButton:destroy()
  minigameMenuButton = nil
  Minigame.destroy()
end

-- Every time we click the top menu button for the minigame, we make sure whether it is already running or not, and close or open it accordingly.
function toggle()
  if running then
    Minigame.destroy()
  else
    Minigame.create()
  end
end

-- Public method which the button can access on click. Could make 'resetJumpButton' public and call that instead, but I think this
-- is cleaner as it divides methods into public and private, and would allow us to do something different in 'jump' later on.
function jump() 
  resetJumpButton()
end

-- When we open the minigame, we make sure to clean off any remaining variables and initialize them again.
function Minigame.create()
  Minigame.destroy()

  minigameWindow = g_ui.displayUI('simpleminigame.otui')
  minigameJumpButton = minigameWindow:getChildById('jumpbutton')
  resetJumpButton()
  scheduleEvent(moveJumpButton, jumpButtonMoveInterval)
  running = true
end

-- When the game is closed, we delete all related variables.
function Minigame.destroy()
  if minigameWindow then
    minigameWindow:destroy()  -- With this we destroy both the window and the jump button, as its child.
    minigameWindow = nil
    minigameJumpButton = nil
  end
  running = false
end