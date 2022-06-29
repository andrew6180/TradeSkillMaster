-- load the parent file (TSM) into a local variable
local TSM = select(2, ...)

local idCache = setmetatable({}, {
    -- Use weak references both for key and values
    __mode = 'kv',
    -- This is called only if the key has not been found in the table
    __index = function(self, key)
        -- ID to check is stored in the table itself, so it can get GC'ed
        local id = rawget(self, '__id') or 0
        while id < 100000 do
            id = id + 1
            local name = GetSpellInfo(id)
            if name then
                -- Store any name we encounter, it may be of some use later
                self[name] = id
                if name == key then
                    -- Stop the loop as soon as we have found the spell
                    break
                end
            end
        end
        -- Remember where to start from next time
        rawset(self, '__id', id)
        -- Finally try to get the spell id
        return rawget(self, key)
    end,
})

TSM.SpellName2ID = function(spellName)
    return spellName and idCache[spellName]
end
