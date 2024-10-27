---@param unit string
---@param spell number
---@param filter? string
---@return AuraData|nil
local function RH_GetUnitAura(unit, spell, filter)
    for i = 1, 255 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
        if auraData and spell == auraData.spellId then
            return auraData
        end
    end
end

---@param unit string
---@param spell number
---@return AuraData|nil
function RH_GetUnitBuff(unit, spell)
    return RH_GetUnitAura(unit, spell, "HELPFUL")
end

---@param unit string
---@param spell number
---@return AuraData|nil
function RH_GetUnitDebuff(unit, spell)
    return RH_GetUnitAura(unit, spell, "HARMFUL")
end
