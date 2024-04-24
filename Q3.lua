function kickPlayerFromParty(playerId, membername)

  local player = Player(playerId) -- Player should ideally stay local so as not to replace a global variable
  if not player then  -- We first make sure the first ID corresponds to a real player.
    print('Party owner not found.')
    return false
  end

  local member = Player(membername)
  if not member then  -- Same thing with the name of the member who's about to get kicked.
    print('Party member to kick not found.')
    return false
  end
  
  local party = player:getParty()
  if not party then  -- And we need to know if the first player belongs to a party.
    print('Party not found.')
    return false
  end

  for _k,member in ipairs(party:getMembers()) do  -- ipairs() might be preferable to pairs() for a numbered list of objects.
    if member.getName() == membername then  -- Comparing player objects directly might return false even when they should match,
                                            -- as 'Player()' creates a new object which is technically different than
                                            -- what would be found in the party's member list. So, we compare by name instead.
      
      party:removeMember(member)  -- If they match, we reuse the player which we already know exists to kick him.
      return true  -- There's no need to keep searching in the party if we found and kicked the target already, so we return early.
    end
  end
  return false
end