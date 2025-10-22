---@class pierrelasse.plugins.tpRequests.Request
---@field senderId string
---@field receiverId string
---@field here nil|true

local this = {
    CB = function(player, location)
        bukkit.teleport(player, location) -- TODO
    end
}

---@type java.Map<string, java.Map<pierrelasse.plugins.tpRequests.Request>>
this.requestsByReceiver = java.map()
---@type java.Map<string, java.Map<pierrelasse.plugins.tpRequests.Request>>
this.requestsBySender = java.map()

---@param sender bukkit.entity.Player
---@param receiver bukkit.entity.Player
---@param here? boolean
function this.sendRequest(sender, receiver, here)
    local senderId = bukkit.uuid(sender)
    local receiverId = bukkit.uuid(receiver)

    if senderId == receiverId then return "INVALID_RECEIVER" end

    local senderMap = java.mapComputeIfAbsent(this.requestsBySender, senderId, function() return java.map() end)

    if senderMap.containsKey(receiverId) then return "ALREADY_SENT" end

    ---@type pierrelasse.plugins.tpRequests.Request
    local request = {
        senderId = senderId,
        receiverId = receiverId,
        here = here and true or nil
    }
    senderMap.put(receiverId, request)
    java.mapComputeIfAbsent(this.requestsByReceiver, receiverId, function() return java.map() end)
        .put(senderId, request)
end

---@param receiverId string
---@param senderId string
---@return pierrelasse.plugins.tpRequests.Request?
function this.getRequest(receiverId, senderId)
    local map = this.requestsByReceiver.get(receiverId)
    return map and map.get(senderId)
end

---@param receiverId string
---@return java.array<pierrelasse.plugins.tpRequests.Request>
function this.getRequests(receiverId)
    local map = this.requestsByReceiver.get(receiverId)
    if map == nil then return java.array(nil, 0) end
    return map.values().toArray()
end

---@param receiverId string
function this.getLatestRequest(receiverId)
    local requests = this.getRequests(receiverId)
    if requests == nil or #requests == 0 then return nil, "NO_REQUESTS" end
    return requests[#requests]
end

---@param senderId string
---@param receiverId string
---@return pierrelasse.plugins.tpRequests.Request?
function this.removeRequest(senderId, receiverId)
    local receiveMap = this.requestsByReceiver.get(receiverId)
    local senderMap = this.requestsBySender.get(senderId)
    if receiveMap and senderMap then
        local request = receiveMap.remove(senderId)
        if request ~= nil then
            senderMap.remove(receiverId)
            return request
        end
    end
end

---@param receiverId string
---@param senderId string
---@param cb fun(player: bukkit.entity.Player, location: bukkit.Location): string?
function this.accept(receiverId, senderId, cb)
    local request = this.removeRequest(senderId, receiverId)
    if request == nil then return "REQUEST_NOT_FOUND" end

    local sender = bukkit.playerByUUID(senderId)
    if sender == nil then return "SENDER_NOT_FOUND" end

    local receiver = bukkit.playerByUUID(receiverId)
    if receiver == nil then return "RECEIVER_NOT_FOUND" end

    return cb(
        request.here and receiver or sender,
        request.here and sender.getLocation() or receiver.getLocation()
    )
end

---@param request pierrelasse.plugins.tpRequests.Request
function this.acceptRequest(request)
    return this.accept(request.receiverId, request.senderId, this.CB)
end

---@param receiverId string
function this.acceptLatest(receiverId)
    local request, err = this.getLatestRequest(receiverId)
    if request == nil then return err end
    local senderId = request.senderId
    return this.accept(
        receiverId,
        senderId,
        this.CB
    )
end

return this
