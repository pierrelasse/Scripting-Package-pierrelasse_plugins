local cfg = require("@pierrelasse/plugins/customItems/_cfg")


local this = {}

---@type java.Map<string, pierrelasse.plugins.customItems.Item>
this.map = java.map()

---@param id string
function this.get(id)
    return this.map.get(id)
end

---@param id string
---@param item pierrelasse.plugins.customItems.Item
function this.register(id, item)
    if item.id ~= id then error() end
    local err = item:validate()
    if err ~= nil then
        error("could not validate item "..id..": "..err)
    end
    this.map.put(id, item)
end

---@param id string
---@param builder fun(item: pierrelasse.plugins.customItems.Item)
function this.make(id, builder)
    local item = this.new(id)
    builder(item)
    this.register(id, item)
end

---@param itemStack bukkit.ItemStack?
---@return string?
function this.getIdFromItem(itemStack)
    if itemStack == nil or not itemStack.hasItemMeta() then return end
    return bukkit.modifyItem(itemStack)
        :getData(cfg.ITEM_ID, "STRING")
end

---@param itemStack bukkit.ItemStack?
function this.getFromItem(itemStack)
    local id = this.getIdFromItem(itemStack)
    return id and this.get(id)
end

---@type fun(id: string, builder: fun(item: pierrelasse.plugins.customItems.Item))
this.make = nil

return this
