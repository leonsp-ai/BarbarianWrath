civ.scen.onActivateUnit(function(unit, source, repeatMove))
    if unit.owner.id == 0 then
        unit.veteran = true
    end
end)