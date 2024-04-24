--[[
	From what I observed from the question 5 video, there were 4 different patterns of big and small tornadoes
	within a diamond-shaped area (with the small ones lasting less), which kept repeating until the end of the spell.

	I thought I'd base it on the Eternal Winter spell, since its tornadoes behaved in the exact same way. What I
	decided to do was to split the diamond area into those 4 small areas I recognized from the video, and to make the spell
	trigger in them multiple times, but in a random order, making the spell feel a bit chaotic while still being able to
	create patterns like the one seen in the video.
--]]

-- First we create the 4 areas, where every 1 is a tornado positioned around the caster, who is represented as a 3.
local areas = {}
areas[1] = {
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 1, 0, 0, 0, 0, 0},
	{1, 0, 0, 3, 0, 0, 1},
	{0, 1, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}
areas[2] = {
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 1, 0},
	{0, 0, 0, 3, 0, 0, 0},
	{0, 0, 0, 1, 0, 1, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0}
}
areas[3] = {
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 1, 3, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0}
}
areas[4] = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 0, 3, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0}
}

local repeats = 20  -- This is the number of times the spell will repeat in one of these areas.
local combatNum = 4  -- The number of necessary combat settings. We need one for each area.
local minDelay = 100  -- The minimum difference between two spell repeats, in milliseconds.
local maxDelay = 200  -- The maximum difference between two spell repeats, in milliseconds.

local combats = {}
for i=1,combatNum do  -- Here we configure every one of these combat objects. They are the settings for each of our small spell casts.
	local combat = Combat()
	combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
	combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
	combat:setArea(createCombatArea(areas[i]))  -- We are not allowed to set parameters like this one while executing the spell,
	                                            -- otherwise we could reuse the same combat and only change the area for every cast.
	
    function onGetFormulaValues(player, level, magicLevel)  -- Original damage formula for Eternal Winter, must be set here
		                                                    -- or it'll be out of scope.
		local min = (level / 5) + (magicLevel * 5.5) + 25
		local max = (level / 5) + (magicLevel * 11) + 50
		return -min, -max
	end
	combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
	combats[i] = combat
end

function spellCallback(cid, variant) -- Here we choose a random combat setting from our table, and cast the spell in one of our four areas.
	local caster = Creature(cid)
	local combatIndex = math.random(1, combatNum)
	doCombat(caster, combats[combatIndex], variant)
end

function onCastSpell(creature, variant)  -- This runs once when the spell is cast.
	local cid = creature:getId()
	local timer = 0
	for i=1,repeats do
		addEvent(spellCallback, timer, cid, variant)  -- We call the function that actually executes all small spells in a batch,
		                                              -- using events to separate each one over time by a slight delay.
		timer = timer + math.random(minDelay, maxDelay)
	end
	return true
end