---@meta

---@enum PowerType
local PowerType = {
    HolyPower = 9
}

Enum = {
    PowerType = PowerType
}

---@return number
function GetHaste()
end

---@return number
function GetSpecialization()
end

---@return number
function GetTime()
end

---@param slot number
---@return boolean haveTotem
---@return string totemName
---@return number startTime
---@return number duration
function GetTotemInfo(slot)
end

---@param spellID number
---@return boolean
function IsSpellOverlayed(spellID)
end

---@param unitToken string
---@return number
function UnitHealth(unitToken)
end

---@param unitToken string
---@return number
function UnitHealthMax(unitToken)
end

---@param unitToken string
---@param powerType PowerType
---@return number
function UnitPower(unitToken, powerType)
end

---@alias SpellIdentifier string | number

C_Spell = {}

---@param spellIdentifier SpellIdentifier
---@return number
function C_Spell.GetOverrideSpell(spellIdentifier)
end

---@class (exact) SpellChargeInfo
---@field currentCharges number
---@field maxCharges number
---@field cooldownStartTime number
---@field cooldownDuration number

---@param spellIdentifier SpellIdentifier
---@return SpellChargeInfo|nil
function C_Spell.GetSpellCharges(spellIdentifier)
end

---@class (exact) SpellCooldownInfo
---@field startTime number
---@field duration number
---@field isEnabled boolean

---@param spellIdentifier SpellIdentifier
---@return SpellCooldownInfo
function C_Spell.GetSpellCooldown(spellIdentifier)
end

---@class (exact) SpellInfo
---@field iconID number
---@field spellID number

---@param spellIdentifier SpellIdentifier
---@return SpellInfo
function C_Spell.GetSpellInfo(spellIdentifier)
end

---@param spellIdentifier SpellIdentifier
---@return boolean isUsable
---@return boolean insufficientPower
function C_Spell.IsSpellUsable(spellIdentifier)
end

C_UnitAuras = {}

---@class (exact) AuraData
---@field applications number
---@field expirationTime number
---@field spellId number

---@param unit string
---@param index number
---@param filter? string
---@return AuraData|nil
function C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
end
