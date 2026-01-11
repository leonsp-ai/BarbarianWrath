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
---@module "data"
local data = require("data"):minVersion(2)
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
local bw = require("bw")


-- ===============================================================================
--
--          Discrete Events
--
-- ===============================================================================

-- local map = civ.getMap(0)
-- map.customResources = true


-- local function eventHappyHunting(turn, tribe)
--     if not civ.hasTech(tribe, bw.techAliases.warriorCode) then
--         return
--     end
--     if civ.hasTech(tribe, bw.techAliases.gunpowder) then
--         return
--     end
--     for city in civ.iterateCities() do
--         if city.owner ~= tribe then
--             goto continueIterateCities
--         end
--         for _i, tile in ipairs(gen.cityRadiusTiles(city)) do
--             if tile == nil then
--                 goto continueCityRadiusTiles
--             end
--             if tile.baseTerrain.abbrev == "For" then
--                 text.displayNextOpportunity(
--                     tribe,
--                     string.format(
--                         "%s hunters bring in a bounty of game. Food supplies increase in %s.",
--                         tribe.adjective,
--                         city.name
--                     ),
--                     "Trade Advisor",
--                     nil,
--                     "archer",
--                     true
--                 )
--                 city.food = city.food + 20
--                 return
--             end

--             ::continueCityRadiusTiles::
--         end
--         ::continueIterateCities::
--     end
--     civ.ui.text(
--         string.format(
--             "DEBUG: %s have no forests near their cities.",
--             tribe.name
--         )
--     )
-- end

-- local tribeTurnEvents = {
--     eventHappyHunting,
-- }
-- discreteEvents.onTribeTurnBegin(function(turn,tribe)
--     if math.random(100) <= 95 then
--         return -- no such luck
--     end

--     local i = math.random(#tribeTurnEvents)
--     if i ~= 1 then
--         civ.ui.text(
--             string.format("DEBUG: Trying to call index %d", i)
--         )
--         return
--     end
--     -- tribeTurnEvents[i](turn, tribe)
-- end)

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
gen.versionFunctions(versionTable, versionNumber, fileModified, "MechanicsFiles" .. "\\" .. "randomEvents.lua")
return versionTable
