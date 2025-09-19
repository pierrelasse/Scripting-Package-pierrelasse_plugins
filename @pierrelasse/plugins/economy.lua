local this = {
    CURRENCY = "money"
}

local storage = bukkit.Storage.new("pierrelasse", "economy")
storage:loadSave()

-- Migration. -- TODO
if  not storage:has("money")
and storage:has("balance") then
    storage:set(storage:get("balance"))
    storage:set("balance", nil)
    print("pierrelasse/plugins/economy: migrated 'balance'->'money'")
end

---@param currencyId string
function this.new(currencyId)
    return setmetatable({ CURRENCY = currencyId }, { __index = this })
end

---@param playerId string
function this.getBalance(playerId)
    return storage:get(this.CURRENCY.."."..playerId) or 0
end

---@param playerId string
---@param value number
function this.setBalance(playerId, value)
    storage:set(this.CURRENCY.."."..playerId, value)
end

---@param playerId string
function this.withdraw(playerId, amount)
    local newBalance = this.getBalance(playerId) - amount
    if newBalance < 0 then return false end
    this.setBalance(playerId, newBalance)
    return true
end

---@param playerId string
function this.deposit(playerId, amount)
    this.setBalance(playerId, this.getBalance(playerId) + amount)
end

---@param playerId string
function this.reset(playerId)
    storage:set(this.CURRENCY.."."..playerId, nil)
end

return this
