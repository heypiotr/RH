---@class (exact) State
---@field time number
---@field gcdRemaining number
---@field holyPower number
---@field assumedCast number|nil
---@field assumedCastTime number|nil

---@class (exact) OptionalState
---@field time number|nil
---@field holyPower number|nil
---@field assumedCast number|nil
---@field assumedCastTime number|nil

---@class (exact) Action
---@field spell number
---@field label string|nil
---@field condition (fun(state:State):boolean)|nil

---@class (exact) NextAction
---@field spell number
---@field label string|nil
---@field cooldownRemaining number
---@field state State

--- https://github.com/WeakAuras/WeakAuras2/wiki/Trigger-State-Updater-(TSU)#states-and-settings
---@class (exact) AllStatesEntry
---@field show boolean
---@field changed boolean
---@field index number
---@field icon number|nil
---@field name string|nil
---@field progressType "timed"|nil
---@field duration number|nil
---@field expirationTime number|nil
---@field spell number|nil
