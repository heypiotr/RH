local RH_CooldownMargin = 0.2

---@type table<number, number>
local RH_SpellOverrides = {
    [RH_Spell_Paladin_HammerOfLight] = RH_Spell_Paladin_EyeOfTyr,
}

---@type table<number, number>
local RH_HolyPowerCosts = {
    [RH_Spell_Paladin_ArcaneTorrent] = -1,
    [RH_Spell_Paladin_BlessedHammer] = -1,
    [RH_Spell_Paladin_HammerOfLight] = 3,
    [RH_Spell_Paladin_HammerOfWrath] = -1,
    [RH_Spell_Paladin_JudgmentProt] = -1,
    [RH_Spell_Paladin_ShieldOfTheRighteous] = 3,
    [RH_Spell_Paladin_WordOfGlory] = 3,
}

---@type table<number, boolean>
local RH_OffGCD = {
    [RH_Spell_Paladin_ShieldOfTheRighteous] = true,
}

---@param state State
---@return boolean
local function RH_WillHaveShiningLight(state)
    if state.assumedCast ~= RH_Spell_Paladin_ShieldOfTheRighteous then
        return false
    end
    local shiningLightProgress = RH_GetUnitBuff("player", RH_Buff_Paladin_ShiningLightProgress)
    return shiningLightProgress ~= nil and shiningLightProgress.applications == 2
end

---@param state State
---@param spell number
---@return boolean
function RH_HasBuff(state, spell)
    local auraData = RH_GetUnitBuff("player", spell)
    if auraData then
        -- Overrides for when the buff is currently available
        local expirationTime = auraData.expirationTime
        if spell == RH_Buff_Paladin_BastionOfLight then
            -- Judgment will have consumed the buff
            if state.assumedCast == RH_Spell_Paladin_JudgmentProt and auraData.applications == 1 then
                return false
            end
        elseif spell == RH_Buff_Paladin_ShakeTheHeavens then
            -- Assumed cast will have extended the buff
            local assumedCast = state.assumedCast
            if assumedCast == RH_Spell_Paladin_BlessedHammer or assumedCast == RH_Spell_Paladin_HammerOfWrath or assumedCast == RH_Spell_Paladin_JudgmentProt then
                expirationTime = expirationTime + 1
            end
        elseif spell == RH_Buff_Paladin_ShiningLight then
            -- Word of Glory will have consumed the buff
            if state.assumedCast == RH_Spell_Paladin_WordOfGlory and auraData.applications == 1 then
                return false
            end
        end
        return expirationTime == 0 or expirationTime > state.time
    else
        -- Overrides for when the buff is currently missing
        if spell == RH_Buff_Paladin_ShiningLight and RH_WillHaveShiningLight(state) then
            return true
        end
        return false
    end
end

---@param state State
---@param unit string
---@param spell number
---@return boolean
function RH_HasDebuff(state, unit, spell)
    local auraData = RH_GetUnitDebuff(unit, spell)
    return auraData ~= nil and auraData.expirationTime > state.time
end

---@param state State
---@return number
local function RH_ConsecrationRemaining(state)
    if state.assumedCast == RH_Spell_Paladin_Consecration then
        return 999
    end

    local haveTotem, totemName, startTime, duration = GetTotemInfo(1)
    if not haveTotem or totemName ~= "Consecration" then
        return 0
    end

    local remaining = startTime + duration - state.time
    return math.max(0, remaining)
end

local function RH_GetGCD()
    return math.max(0.75, 1.5 / (1 + GetHaste() / 100))
end

---@class (exact) Charges
---@field current number
---@field max number
---@field cooldownRemaining number

---@param state State
---@param spell number
---@return Charges|nil
local function RH_GetCharges(state, spell)
    local charges = C_Spell.GetSpellCharges(spell)
    if not charges then
        return nil
    end

    local current = charges.currentCharges
    local max = charges.maxCharges
    local cooldownStartTime = charges.cooldownStartTime
    local cooldownDuration = charges.cooldownDuration

    if spell == state.assumedCast then
        if current == max then
            cooldownStartTime = state.assumedCastTime
        end
        current = current - 1
    end

    if cooldownStartTime > 0 then
        local newChargeAt = cooldownStartTime + cooldownDuration
        if newChargeAt < state.time then
            cooldownStartTime = newChargeAt
            current = current + 1
        end
    end

    ---@type number
    local cooldownRemaining
    if current == max then
        cooldownRemaining = 0
    else
        cooldownRemaining = math.max(0, cooldownStartTime + cooldownDuration - state.time)
    end

    ---@type Charges
    local ret = { current = current, max = max, cooldownRemaining = cooldownRemaining }
    return ret
end

---@param state State
---@param spell number
---@return boolean
local function RH_ChargesWillCap(state, spell)
    local charges = RH_GetCharges(state, spell)
    -- Never call this for spells without charges
    ---@cast charges -?
    local current, max, cooldownRemaining = charges.current, charges.max, charges.cooldownRemaining
    return current == max or (current == max - 1 and cooldownRemaining < RH_GetGCD())
end

---@param time number
---@param cooldown {startTime:number, duration:number}
---@return number
local function RH_GetCooldownRemaining(time, cooldown)
    if cooldown.startTime == 0 then
        return 0
    end
    return math.max(0, cooldown.startTime + cooldown.duration - time)
end

---@param state State
---@param spell number
---@return number
---@return boolean gcd
local function RH_GetCooldown(state, spell)
    if spell == state.assumedCast then
        local charges = RH_GetCharges(state, spell)
        if not charges then
            return 999, false
        elseif charges.current == 0 then
            return charges.cooldownRemaining, false
        end
    end

    local cooldown = C_Spell.GetSpellCooldown(spell)
    local cooldownRemaining = RH_GetCooldownRemaining(state.time, cooldown)
    local gcd = state.gcdRemaining > 0 and cooldownRemaining == state.gcdRemaining
    return cooldownRemaining, gcd
end

---@param state State
---@return boolean
local function RH_IsHammerOfWrathUsable(state)
    local targetHealth = UnitHealth("target")
    local targetMaxHealth = UnitHealthMax("target")
    return (targetHealth and targetMaxHealth and targetHealth < 0.2 * targetMaxHealth) or
        RH_HasBuff(state, RH_Buff_Paladin_AvengingWrath)
end

---@param state State
---@param spell number
---@return boolean
function RH_IsUsable(state, spell)
    if spell == RH_Spell_Paladin_HammerOfWrath then
        return RH_IsHammerOfWrathUsable(state)
    end

    local base = RH_SpellOverrides[spell]
    if base and not (state.assumedCast == base or IsSpellOverlayed(spell)) then
        return false
    end

    local isUsable, insufficientPower = C_Spell.IsSpellUsable(spell)
    if not isUsable and not insufficientPower then
        return false
    end

    return true
end

---@param state State
---@param spell number
---@return number
local function RH_GetHolyPowerCost(state, spell)
    ---@type number
    local cost = RH_HolyPowerCosts[spell] or 0

    if spell == RH_Spell_Paladin_JudgmentProt then
        if RH_HasBuff(state, RH_Buff_Paladin_AvengingWrath) then
            cost = cost - 1
        end
        if RH_HasBuff(state, RH_Buff_Paladin_BastionOfLight) then
            cost = cost - 2
        end
    elseif spell == RH_Spell_Paladin_WordOfGlory and RH_HasBuff(state, RH_Buff_Paladin_ShiningLight) then
        cost = 0
    end

    if cost > 0 and RH_HasBuff(state, RH_Buff_Paladin_DivinePurpose) then
        local assumedCastCost = RH_HolyPowerCosts[state.assumedCast] or 0
        -- If assumed cast is a spender, it will have consumed DP
        if not (assumedCastCost > 0) then
            cost = 0
        end
    end

    return cost
end

---@param old State
---@param new OptionalState
---@return State
local function RH_NewState(old, new)
    for k, v in pairs(old) do
        if not new[k] then new[k] = v end
    end
    return new --[[@as State]]
end

---@param state State
---@param action Action
---@param candidate NextAction|nil
---@return NextAction|nil
---@return boolean done
local function RH_ReplaceCandidate(state, action, candidate)
    local cooldownRemaining, gcd = RH_GetCooldown(state, action.spell)
    local stateWhenAction = RH_NewState(state, {
        time = state.time + cooldownRemaining,
    })

    local usable = RH_IsUsable(stateWhenAction, action.spell)
    if not usable then
        return nil, false
    end

    local holyPowerCost = RH_GetHolyPowerCost(state, action.spell)
    if state.holyPower < holyPowerCost then
        return nil, false
    end

    if action.condition and not action.condition(stateWhenAction) then
        return nil, false
    end

    if not candidate or cooldownRemaining < candidate.cooldownRemaining - RH_CooldownMargin then
        local stateAfterAction = RH_NewState(stateWhenAction, {
            holyPower = stateWhenAction.holyPower - holyPowerCost,
            assumedCast = action.spell,
            assumedCastTime = stateWhenAction.time,
        })
        if not RH_OffGCD[action.spell] then
            stateAfterAction.time = stateWhenAction.time + RH_GetGCD()
            stateAfterAction.gcdRemaining = 0
        end

        ---@type NextAction
        local newCandidate = {
            spell = action.spell,
            label = action.label,
            cooldownRemaining = cooldownRemaining,
            state = stateAfterAction,
        }
        -- We can break early if the new candidate is usable immediately or after a GCD
        -- Note that this technically de-prioritizes off-GCD actions further down the list
        local done = cooldownRemaining == 0 or gcd
        return newCandidate, done
    else
        return nil, false
    end
end

---@param state State
---@param actions Action[]
---@return NextAction|nil
local function RH_GetNextAction(state, actions)
    ---@type NextAction|nil
    local candidate

    for i, action in ipairs(actions) do
        local newCandidate, done = RH_ReplaceCandidate(state, action, candidate)
        if newCandidate then
            candidate = newCandidate
            if done then break end
        end
    end

    return candidate
end

---@param allstates AllStatesEntry[]
---@param i number
---@param action NextAction|nil
---@return boolean
local function RH_SetWAState(allstates, i, action)
    ---@type number|nil
    local prevSpell
    ---@type number|nil
    local prevDuration, prevExpirationTime
    if allstates[i] then
        prevSpell = allstates[i].spell
        prevDuration = allstates[i].duration
        prevExpirationTime = allstates[i].expirationTime
    end

    if action == nil then
        if prevSpell ~= nil then
            allstates[i] = {
                show = false,
                changed = true,
                index = i,
                duration = nil,
                expirationTime = nil,
                spell = nil,
            }
            return true
        end
    else
        local spell = action.spell

        local spellCooldown = C_Spell.GetSpellCooldown(spell)
        local duration = spellCooldown.duration
        local expirationTime = spellCooldown.startTime + duration

        if spell ~= prevSpell or duration ~= prevDuration or expirationTime ~= prevExpirationTime then
            allstates[i] = {
                show = true,
                changed = true,
                index = i,
                icon = C_Spell.GetSpellInfo(action.spell).iconID,
                name = action.label or "",
                progressType = "timed",
                duration = duration,
                expirationTime = expirationTime,
                spell = action.spell,
            }
            return true
        end
    end

    return false
end

---@param allstates AllStatesEntry[]
---@param actions Action[]
---@return boolean
function RH_RotationHelper(allstates, actions)
    local time = GetTime()

    ---@type State
    local state = {
        time = time,
        gcdRemaining = RH_GetCooldownRemaining(time, C_Spell.GetSpellCooldown(61304)),
        holyPower = UnitPower("player", Enum.PowerType.HolyPower),
    }

    local nextAction, followingAction
    nextAction = RH_GetNextAction(state, actions)
    if nextAction then
        followingAction = RH_GetNextAction(nextAction.state, actions)
    end

    local nextChanged = RH_SetWAState(allstates, 1, nextAction)
    local followingChanged = RH_SetWAState(allstates, 2, followingAction)

    return nextChanged or followingChanged
end
