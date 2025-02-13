---@type Action[]
RH_Actions_Paladin_Holy = {
    {
        spell = RH_Spell_Paladin_WordOfGlory,
        condition = function(state)
            return state.holyPower == 5
        end,
    },
    {
        spell = RH_Spell_Paladin_HolyPrism,
    },
    {
        spell = RH_Spell_Paladin_HolyShock,
    },
    {
        spell = RH_Spell_Paladin_HammerOfWrath,
    },
    {
        spell = RH_Spell_Paladin_JudgmentHoly,
    },
    {
        spell = RH_Spell_Paladin_CrusaderStrike,
    },
    {
        spell = RH_Spell_Paladin_Consecration,
    },
}
