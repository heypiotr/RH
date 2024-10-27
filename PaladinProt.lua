---@type Action[]
RH_Actions_Paladin_Prot = {
    {
        spell = RH_Spell_Paladin_ShieldOfTheRighteous,
    },
    {
        spell = RH_Spell_Paladin_HammerOfWrath,
    },
    {
        spell = RH_Spell_Paladin_JudgmentProt,
    },
    {
        spell = RH_Spell_Paladin_BlessedHammer,
        condition = function(state)
            return RH_HasBuff(state, RH_Buff_Paladin_ShakeTheHeavens)
        end,
    },
    {
        spell = RH_Spell_Paladin_WordOfGlory,
        condition = function(state)
            return RH_HasBuff(state, RH_Buff_Paladin_ShakeTheHeavens) and RH_HasBuff(state, RH_Buff_Paladin_ShiningLight)
        end,
    },
    {
        spell = RH_Spell_Paladin_AvengersShield,
    },
    {
        spell = RH_Spell_Paladin_BlessedHammer,
    },
    {
        spell = RH_Spell_Paladin_WordOfGlory,
        condition = function(state)
            local healthPerc = UnitHealth("player") / UnitHealthMax("player")
            return healthPerc < 0.5 and RH_HasBuff(state, RH_Buff_Paladin_ShiningLight)
        end,
    },
    {
        spell = RH_Spell_Paladin_ArcaneTorrent,
    },
    {
        spell = RH_Spell_Paladin_Consecration,
    },
}
