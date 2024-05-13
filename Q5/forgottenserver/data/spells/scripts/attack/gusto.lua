-- This is the coverage of area I saw in the video
-- This area doesn't actually show up on the client without modifying how the code renders on the client
-- Couldn't figure out if it's possible to adjust that through what the server sends so
-- I just hacked the client and just made the Effect::drawEffect() render it's x pattern with an offset of 1
-- for the purposes of the video
AREA_CROSS3X3_LEFT = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 2, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

-- There isn't much to comment about this code because I just tried to find the reference spell
-- and modify things from there. I couldn't figure out a way to create the popping in and out
-- of the the tornadoes like the video does it, except by using addEvent() to make multiple
-- calls to combat:execute with a slightly different area pattern. However doing so
-- gave me a warning of creature being an unsafe variable so I don't think that's a good approach


-- Not knowing much about Lua, this was just a straight forward way I thought of to make
-- nearly a random value between 0 and 1
local function RandomOne()
	local value = math.random()
	if value < 0.5 then
		return 0
	end
	return 1
end

-- This will generate a random pattern that fits the area of what I saw in reference video.
-- This pattern doesn't actually show up the same way as the video if my generated pattern rolled all 
-- ones. What I ended up doing was just hacking the renderer for the sake of the
-- proof video to offset the Effect::drawEffect() x pattern by 1
local function randomAreaCross3x3()
	return
	{
		{0, 0, 0, RandomOne(), 0, 0, 0},
		{0, 0, RandomOne(), RandomOne(), 1, 0, 0},
		{0, RandomOne(), RandomOne(), RandomOne(), RandomOne(), RandomOne(), 0},
		{RandomOne(), RandomOne(), RandomOne(), 2, RandomOne(), RandomOne(), RandomOne()},
		{0, RandomOne(), RandomOne(), RandomOne(), RandomOne(), RandomOne(), 0},
		{0, 0, RandomOne(), RandomOne(), 1, 0, 0},
		{0, 0, 0, RandomOne(), 0, 0, 0}
	}
end

-- Here just to initialize the combat array which will be used later on
function makeCombatArray()
	local combats =
	{
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
		Combat(),
	}

	for i, combat in ipairs(combats) do
		combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
		combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
		combat:setArea(createCombatArea(randomAreaCross3x3()))
	end

	return combats
end

local combats = makeCombatArray()

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.5) + 25
	local max = (level / 5) + (magicLevel * 11) + 50
	return -min, -max
end

-- Why can't it find onGetFormulaValues in a loop, I got no time to know
-- all I know is that it is responsible for the range of damage
for i, combat in ipairs(combats) do
	combats[i]:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
end

function executeCombat(creature, variant, combat)
	combat:execute(creature, variant)
end

function onCastSpell(creature, variant)
	-- I couldn't find a way to properly make the attack pattern work, at best this actually
	-- makes it visually work, but it doesn't properly apply damage as creature is apparently
	-- a unsafe variable. There might be another way to do this in a more correct manner
	-- but I've already spent some time figuring out how all of this worked in the first place
	for i = 1, 10, 1 do
		addEvent(executeCombat, 100 * i, creature, variant, combats[i])
	end
end
