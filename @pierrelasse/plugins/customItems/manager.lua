local cfg = require("@pierrelasse/plugins/customItems/_cfg")
local Item = require("@pierrelasse/plugins/customItems/Item")


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
    item.id = id
    this.map.put(id, item)
end

---@param id string
---@param builder fun(item: pierrelasse.plugins.customItems.Item)
function this.make(id, builder)
    local item = Item.new()
    item.id = id

    builder(item)

    local err = item:validate()
    if err ~= nil then
        error("could not validate item "..id..": "..err)
    end

    this.map.put(id, item)
end

---@param itemStack bukkit.ItemStack?
function this.getFromItem(itemStack)
    if itemStack == nil or not itemStack.hasItemMeta() then return end
    local id = bukkit.modifyItem(itemStack)
        :getData(cfg.ITEM_ID, "STRING")
    if id == nil then return end
    return this.get(id)
end

return this
