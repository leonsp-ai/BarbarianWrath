--
---@module "text"
local text = require("text"):minVersion(1)

---@class bw
local bw = {}  -- create a table to represent the module

---@field bw.improvementAliases bw.improvementAliases
bw.improvementAliases = {
    courthouse = civ.getImprovement(7)
}

---@field bw.techAliases bw.techAliases
bw.techAliases = {
    gunpowder = civ.getTech(35),
    warriorCode = civ.getTech(86),
}

---@field bw.unitAliases bw.unitAliases
bw.unitAliases = {
    caravan = civ.getUnitType(48),
    diplomat = civ.getUnitType(46),
    engineers = civ.getUnitType(1),
    freight = civ.getUnitType(49),
    settlers = civ.getUnitType(0),

    cavalry = civ.getUnitType(20),
    chariot = civ.getUnitType(15),
    crusaders = civ.getUnitType(17),
    elephant = civ.getUnitType(16),
    dragoons = civ.getUnitType(19),
    knights = civ.getUnitType(18),

    alpine_troops = civ.getUnitType(58),
    archer = civ.getUnitType(70),
    grenadiers = civ.getUnitType(7),
    legion = civ.getUnitType(4),
    marines = civ.getUnitType(11),
    partisans = civ.getUnitType(9),
    swordsmen = civ.getUnitType(5),

    artillery = civ.getUnitType(24),
    cannon = civ.getUnitType(26),
    catapult = civ.getUnitType(23),
    howitzer = civ.getUnitType(25),

    aarne_juutilainen = civ.getUnitType(60),
    bolivar = civ.getUnitType(56),
    boudica = civ.getUnitType(76),
    che_guevara = civ.getUnitType(51),
    florine = civ.getUnitType(53),
    hengist = civ.getUnitType(78),
    joan = civ.getUnitType(54),
    pyrrhus = civ.getUnitType(52),
    napoleon = civ.getUnitType(57),
    rozka_korczak = civ.getUnitType(59),
    spartacus = civ.getUnitType(77),
    toussant = civ.getUnitType(79),
    wallenstein = civ.getUnitType(55),
}

text.registerUnitsImage("Units.bmp")
-- ---@field bw.imageTable bw.imageTable
-- bw.imageTable = {
--     archer = text.unitTypeImage(bw.unitAliases.archer),
-- }
-- text.setImageTable(bw.imageTable, "imageTable")

return bw
