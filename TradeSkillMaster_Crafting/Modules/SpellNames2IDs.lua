-- load the parent file (TSM) into a local variable
local TSM = select(2, ...)

-- TSM.enchantingName = GetSpellInfo(7411)

TSM.SpellName2ID = function(spellName)
    local name

    for spellID = 1, 100000 do
        name = GetSpellInfo(spellID)

        if name == spellName then
            return spellID
        end
    end
end
