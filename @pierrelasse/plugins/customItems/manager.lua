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
    item.id = id
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

---@type fun(id: string, builder: fun(item: pierrelasse.plugins.customItems.Item))
this.make = nil

return this
