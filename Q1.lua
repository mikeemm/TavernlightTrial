-- There are a lot of things to say about this code, so I'll comment
-- the original first and then write the improved version afterwards

-- This function is referenced only in 'onLogout', so unless we assume that
-- this is part of a bigger file the contents of which have been cut, it is
-- reduntant, especially since it is a local function, and as such,
-- isn't exposed publicly and thus cannot be called by code from other files
local function releaseStorage(player)
  player:setStorageValue(1000, -1)
end

function onLogout(player)
  -- This conditional is likely unnecessary, as we should probably always
  -- release this storage item, but since it is using numbers and not booleans 
  -- and we do not know what the storage value signifies, we must keep this
  -- in mind in case the value determines the type of item contained or the state
  -- it is in, since we might only want to release it under specific conditions.
  if player:getStorageValue(1000) == 1 then
    addEvent(releaseStorage, 1000, player)
    --   1000 here is likely being mistaken as the event's time delay,
    --   but its use on 'getStorageValue' and 'setStorageValue' suggests that
    --   it is instead being used as an index value, so if we really wished
    --   to use an event, we should replace it with a delay variable, like:
    -- addEvent(releaseStorage, releaseStorageDelay, player)
    --   That being said, there is no known reason why we'd want to wait before
    --   releasing items on logout, so we should probably release immediately instead:
    -- releaseStorage(player)
    --   If 'releaseStorage' is not going to be used anywhere else, we might as well
    --   delete it and call 'setStorageValue' directly instead:
    -- player:setStorageValue(1000, -1)
  end
  -- This is also always returning true no matter what, while it would have no reason
  -- to even return anything in a function called 'onLogout', which puts no emphasis
  -- on the return value.
  return true
end

-- Below is a much simplified version, assuming that:
--   'releaseStorage' is only called in 'onLogout' and nowhere else in the original source file, and is not likely to be reused later.
--   The stored value is either always 1/-1, or we always want it to be released no matter what.
--   We want to release it immediately.
--   'onLogout' does not need to return whether it released the storage value or not.

function onLogout(player)
  player:setStorageValue(1000, -1)
end

-- If we do want to return true or false depending on if the storage had to be released or not,
-- then we could do something like this:

local storageIndex = 1000  -- Easier to reference and modify later

function onLogout(player)
  if player:getStorageValue(storageIndex) ~= -1
    player:setStorageValue(storageIndex, -1)
    return true
  else
    return false
  end
end

-- We could do more versions, including using 'releaseStorage' again, but the ideal version highly depends on
-- the context and interpretation of the situation according to the factors outlined earlier.