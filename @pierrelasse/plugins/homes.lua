local this = {
    ---@type fun(playerId: string): integer
    GET_MAX_HOMES = function(playerId) return 3 end,

    ALLOWED_WORLDS = java.setOf("world", "world_nether", "world_the_end")
}

---@param location bukkit.Location
local function locationSerialize(location)
    return location.getWorld().getName().." "
        ..math.floor(location.getX()).." "..math.floor(location.getY()).." "..math.floor(location.getZ()).." "
        ..math.floor(location.getYaw()).." "..math.floor(location.getPitch())
end

---@param s string
local function locationDeserialize(s)
    local parts = s:split(" ")

    local world = bukkit.world(parts[1])
    if world == nil then return end

    local x, y, z = tonumber(parts[2], 10), tonumber(parts[3], 10), tonumber(parts[4], 10)
    if x == nil or y == nil or z == nil then return end

    if #parts > 4 then
        local yaw, pitch = tonumber(parts[5], 10), tonumber(parts[6], 10)
        if yaw == nil or pitch == nil then return end
        return bukkit.location6(world, x, y, z, yaw, pitch)
    end

    return bukkit.location4(world, x, y, z)
end

---@package
this.storage = bukkit.Storage.new("pierrelasse", "homes")
this.storage:loadSave()

---@param playerId string
---@return java.array<string>
function this.getHomes(playerId)
    local path = "homes."..playerId

    local keys = this.storage:getKeys(path)
    if keys == nil then
        return makeArray(nil, 0)
    else
        return keys.toArray()
    end
end

---@param playerId string
function this.countHomes(playerId)
    local path = "homes."..playerId

    local keys = this.storage:getKeys(path)
    if keys == nil then return 0 end
    return keys.size()
end

---@param playerId string
function this.canCreateANewHome(playerId)
    return this.countHomes(playerId) < this.GET_MAX_HOMES(playerId)
end

---@param playerId string
---@param homeId string?
function this.hasHome(playerId, homeId)
    if homeId == nil then return false end

    local path = "homes."..playerId.."."..homeId

    return this.storage:has(path)
end

---@param playerId string
---@param homeId string
function this.getHomeLocation(playerId, homeId)
    local path = "homes."..playerId.."."..homeId

    local v = this.storage:get(path)
    if v == nil then return end

    -- TODO: check if world is allowed?

    return locationDeserialize(v)
end

---@param playerId string
---@param homeId string
---@param location bukkit.Location?
function this.setHomeLocation(playerId, homeId, location)
    local path = "homes."..playerId.."."..homeId

    if location == nil then
        this.storage:set(path, nil)
        return
    end

    if not this.storage:has(path) then
        if not this.ALLOWED_WORLDS.contains(location.getWorld().getName()) then
            return "LOCATION_NOT_ALLOWED"
        end

        if not this.canCreateANewHome(playerId) then
            return "LIMIT_REACHED"
        end
    end

    local v = locationSerialize(location)
    this.storage:set(path, v)
end

return this
