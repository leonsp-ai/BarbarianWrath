--
local versionNumber = 2
local fileModified = false -- set this to true if you change this file for your scenario
-- if another file requires this file, it checks the version number to ensure that the
-- version is recent enough to have all the expected functionality
-- if you set fileModified to true, the error generated if this file is out of date will
-- warn you that you've modified this file
--
--
--
--
--  This file allows for a scenario designer to organize events
--  in a manner similar to the legacy system, in that you don't have to
--  group all events of the same type in the same place.
--  This may be more convenient in some cases.
--
--  You can create events in multiple files, but event order is only
--  guaranteed to be preserved within files.  That is, for two files
--  and 4 events with the same execution point
--      discreteEventsFile1.lua
--          Event A
--          Event B
--      discreteEventsFile2.lua
--          Event Y
--          Event Z
--  A will be checked before B and Y before Z,
--  but both A, B, Y, Z and Y, Z, A, B
--  are possible orders to check and execute the code
--
--
--
--

-- ===============================================================================
--
--          Require Lines etc.
--
-- ===============================================================================
-- This section is for the 'require' lines for this file, and anything
-- else that must be at the top of the file.

---@module "discreteEventsRegistrar"
local discreteEvents = require("discreteEventsRegistrar"):minVersion(4)
---@module "generalLibrary"
local gen = require("generalLibrary"):minVersion(1)
---@module "param"
local param = require("parameters"):minVersion(1)
local object = require("object")
---@module "text"
local text = require("text"):minVersion(1)
---@module "diplomacy"
local diplomacy = require("diplomacy"):minVersion(1)
---@module "delayedAction"
local delayed = require("delayedAction"):minVersion(1)
local calendar = require("calendar")
local keyboard = require("keyboard")
local civlua = require("civluaModified")


-- ===============================================================================
--
--          Discrete Events
--
-- ===============================================================================

local barbUnitsTwinnedCount = 0
local barbUnitsTwinnedList = {}
local maxCapitalSize = {}
local lastSizeFixTurn = {}
local unitAliases = {
    diplomat = civ.getUnitType(46),

    cavalry = civ.getUnitType(20),
    chariot = civ.getUnitType(15),
    crusaders = civ.getUnitType(17),
    elephant = civ.getUnitType(16),
    dragoons = civ.getUnitType(19),
    knights = civ.getUnitType(18),

    grenadiers = civ.getUnitType(7),
    legion = civ.getUnitType(4),
    marines = civ.getUnitType(11),
    swordsmen = civ.getUnitType(5),

    boudica = civ.getUnitType(76),
    hengist = civ.getUnitType(78),
    pyrrhus = civ.getUnitType(52),
    spartacus = civ.getUnitType(77),
}

local heroes = {
    boudica = {retinue="chariot", taunt="'Heave we not been robbed entirely of our possessions, while for what litle remains we must pay tribute?'\n\nBoudica of the Iceni leads a horde of chariots against the cities of the world."},
    spartacus = {retinue="legion", taunt="'Maybe there's no peace in this world, for us or for anyone else. I don't know. But I do know that as long as we live, we must stay true to ourselves. We march tonight!'\n\nSpartacus leads legions of the enslaved in revolt against the cities of the world."},
    hengist = {retinue="swordsmen", taunt="'The people are worthless, but the land is rich!'\n\nHengist leads a horde of swordsmen against the cities of the world."},
    florine = {retinue="crusaders", taunt="'Pierced by seven arrows but still fighting, she seeks to open a passage towards the mountains!'\n\nFlorine of Burgundy leads rampaging crusaders against the cities of the world."},
}

discreteEvents.onScenarioLoaded(
    function()
        for hero, _ in pairs(heroes) do
            data.defineFlag(hero)
        end
    end
)

-- handle barbarian management
discreteEvents.onTurn(
    function(turn)
        local barbSummary
        if #barbUnitsTwinnedList >= 3 then
            barbSummary = string.format(
                "%s, and %s",
                table.concat(barbUnitsTwinnedList, ", ", 1, #barbUnitsTwinnedList - 1),
                barbUnitsTwinnedList[#barbUnitsTwinnedList]
            )
        elseif #barbUnitsTwinnedList == 2 then
            barbSummary = table.concat(barbUnitsTwinnedList, " and ")
        elseif #barbUnitsTwinnedList == 1 then
            barbSummary = string.format("a %s", barbUnitsTwinnedList[1])
        end
        if #barbUnitsTwinnedList > 0 then
            civ.ui.text(
                string.format("BARBARIANS ON A RAMPAGE! The ranks of the red horde swell with %s.", barbSummary)
            )
        end
        barbUnitsTwinnedCount = 0
        barbUnitsTwinnedList = {}
    end
)

local function countSettlers(city)
    local settlers = 0
    for unit in civ.iterateUnits() do
        if unit.homeCity and unit.homeCity == city and gen.isRequiresFoodSupport(unit.type) then
            settlers = settlers +1
        end
    end
    return settlers
end

local function settlerSupport(tribe, city)
    local settlers = countSettlers(city)
    local settlersEat = (tribe.government <= 2) and civ.cosmic.settlersEatLow or civ.cosmic.settlersEatHigh
    return settlers * settlersEat
end

-- handle city size
discreteEvents.onCityProcessingComplete(
    function(turn, tribe)
        if tribe.id == 0 then
            return -- barbarians
        end
        local capital = civlua.findCapital(tribe)
        if capital == nil then
            return -- no capital
        end

        if maxCapitalSize[capital.name] == nil then
            maxCapitalSize[capital.name] = capital.size
            return
        else
            maxCapitalSize[capital.name] = math.max(maxCapitalSize[capital.name], capital.size)
        end

        if capital.size >= maxCapitalSize[capital.name] then
            return
        end
        local foodProd = gen.computeBaseProduction(capital)
        local foodSupport = settlerSupport(tribe, capital)
        local foodSurplus = foodProd - (2 * capital.size + foodSupport)
        if foodSurplus > 0  then
            if lastSizeFixTurn[capital.name] and lastSizeFixTurn[capital.name] - turn <= 5 then
                civ.ui.text(
                    string.format(
                        "DEBUG: We last fixed %s's population %d turns ago. Accelerating.",
                        capital.name, lastSizeFixTurn[capital.name] - turn
                    )
                )
                maxCapitalSize[capital.name] = maxCapitalSize[capital.name] + 1
            end
            civ.ui.text(
                string.format(
                    "BUG FIX! %s is smaller at %d than the all time high of %d. Restoring the %s population.",
                    capital.name, capital.size, maxCapitalSize[capital.name], tribe.adjective
                )
            )
            capital.size = maxCapitalSize[capital.name]
            lastSizeFixTurn[capital.name] = turn
        end
    end
)

-- prevent barbarian cities from building heroes
discreteEvents.onTurn(
    function(turn)
        for city in civ.iterateCities() do
            if city.owner.id ~= 0 then
                return -- not barbarian
            end
            if not civ.isUnitType(city.currentProduction) then
                return -- not building a unit
            end
            for hero, details in pairs(heroes) do
                if city.currentProduction == unitAliases[hero] then
                    civ.ui.text(
                        string.format(
                            "DEBUG: %s is building a %s. Setting it to build %s instead",
                            city.name, hero, details.retinue
                        )
                    )
                    city.currentProduction = unitAliases[retinue]
                end
            end
        end
    end
)

discreteEvents.onActivateUnit(
    function(unit, source, repeatMove)
        if unit.owner.id ~= 0 then
            return -- only barbarians
        end
        if unit.veteran then
            return -- skip veterans
        end

        local too_many_per_tile = 6
        local twin_unit_count = 1
        local unit_or_units = unit.location.units()
        local w, h, maps = civ.getAtlasDimensions()
        local twin_limit = math.ceil(math.sqrt(w * h) / 6)
        if not civ.isUnit(unit_or_units) and #unit_or_units >= too_many_per_tile then
            return -- don't multiply plentiful barbarians
        end
        if barbUnitsTwinnedCount >= twin_limit then
            -- 8 on a small map
            -- 12 on a normal map
            -- 16 on a large map
            return -- don't multiply too often per turn
        end
        if unit.type.domain ~= 0 then
            return -- don't multiply boats
        end
        local l = unit.location
        local tile = civ.getTile(l.x, l.y, l.z)
        local bt = tile.baseTerrain
        if bt.abbrev == "Oce" then
            return -- don't multiply at sea
        end
        unit.veteran = true

        local newUnits = gen.createUnit(unit.type, unit.owner, {unit.location}, {count = twin_unit_count, homeCity = nil, veteran = true})
        if #newUnits > 0 then
            if unit.type ~= unitAliases.diplomat then
                -- Barbarian leaders don't count against the limit
                barbUnitsTwinnedCount = barbUnitsTwinnedCount + 1
            end
            table.insert(barbUnitsTwinnedList, unit.type.name)
        end

        for hero, details in pairs(heroes) do
            emergeHeroAtUnit(unit, unitAliases[details.retinue], hero, unitAliases[hero], details.taunt)
        end
    end
)

local function emergeHeroAtUnit(unit, retinue, flagName, hero, taunt)
    if unit.type == retinue and not data.flagGetValue(flagName) then
        local heroUnit = gen.createUnit(hero, unit.owner, {unit.location}, {homeCity = nil, veteran = true})
        local retinue = gen.createUnit(retinue, unit.owner, {unit.location}, {count = 3, homeCity = nil, veteran = true})

        if #heroUnit > 0 then
            data.flagSetTrue(flagName)
            civ.ui.text(taunt)
        else
            civ.ui.text(string.format("DEBUG: Failed to emerge hero: %s", flagName))
        end
    end
end

discreteEvents.onCityTaken(
    function(city, defender)
        if city.owner.id ~= 0 then
            return -- only for barbarians
        end
        local reward_unit_count = 2
        local too_many_per_tile = 3
        local unit_or_units = city.location.units()
        local new_unit_type
        if civ.isUnit(unit_or_units) then
            new_unit_type = unit_or_units.type
        elseif #unit_or_units > 0 then
            new_unit_type = unit_or_units[1].type
        elseif civ.isUnitType(city.currentProduction) then
            new_unit_type = city.currentProduction
        else
            return -- cannot determine unit type
        end
        if not civ.isUnit(unit_or_units) and #unit_or_units >= too_many_per_tile then
            return -- don't multiply plentiful barbarians
        end
        local newUnits = gen.createUnit(new_unit_type, city.owner, {city.location}, {count = reward_unit_count, homeCity = nil, veteran = true})
        if #newUnits == 0 then
            civ.ui.text(
                string.format(
                    "BARBARIANS TAKE %s! %s devastated. The outpost is too remote to reinforce.",
                    string.upper(city.name),
                    defender.name
                )
            )
            return -- could not reinforce
        end
        civ.ui.text(
            string.format(
                "BARBARIANS TAKE %s! %s devastated. More %s flock to the red banner.",
                string.upper(city.name),
                defender.name,
                new_unit_type.name
            )
        )
    end
)

-- ===============================================================================
--
--          End of File
--
-- ===============================================================================
--      In order to register discrete events, you don't need
--      to return anything, but the file must be 'required'
--      by another file.  Discrete Events can be registered in any file,
--      provided it has the following require line:
--
--      local discreteEvents = require("discreteEventsRegistrar")

local versionTable = {}
gen.versionFunctions(versionTable, versionNumber, fileModified, "MechanicsFiles" .. "\\" .. "barbarianEvents.lua")
return versionTable
