function printSmallGuildNames(memberCount)
  -- this method is supposed to print names of all guilds that have less than memberCount max members

  -- A non-number memberCount would break the string formatting below and give an error.
  memberCount = tonumber(memberCount)
  if not memberCount then
    print('Provided memberCount is not a number:')
    print(memberCount)
    return
  end
  
  local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
  local resultName = db.storeQuery(string.format(selectGuildQuery, memberCount)) -- We are fetching names, not IDs.
  
  -- If the query failed, we tell the user we were unsuccessful and end early.
  if not resultName then
    print('No guilds found.')
    return
  end

  -- If the query found any amount of guilds, then:
  print('Found guilds:')
  repeat
    local guildName = result.getString(resultName, "name") -- We need to specify that we're fetching from the results we just got.
    print(guildName)
  until not result.next(resultName)  -- We iterate on the query results until we've printed all guilds we've found.
  result.free(resultName)  -- And then we remove the query results from the aggregator.
end