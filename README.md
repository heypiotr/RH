# WoW Rotation Helper

World of Warcraft addon that powers WeakAuras that help me play my Paladin.

Requires a Dynamic Group aura with Trigger State Updater, and a trigger function like this:

```lua
function (allstates)
    return RH_RotationHelper(allstates, RH_Actions_Paladin_Prot)
end
```
