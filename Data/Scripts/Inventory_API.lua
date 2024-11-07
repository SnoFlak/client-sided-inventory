local TEST_TABLE = require(script:GetCustomProperty("TestTable"))
local INVENTORY_SLOT = script:GetCustomProperty("Inventory_Slot")

local COMMON = script:GetCustomProperty("Common")
local UNCOMMON = script:GetCustomProperty("Uncommon")
local RARE = script:GetCustomProperty("Rare")
local EPIC = script:GetCustomProperty("Epic")
local MASTERWORK = script:GetCustomProperty("Masterwork")

local RARITY_COLORS = {COMMON, UNCOMMON, RARE, EPIC, MASTERWORK}

local ITEM_BACKGROUND = script:GetCustomProperty("ItemBackground")
local ITEM_EMPTY_BACKGROUND = script:GetCustomProperty("ItemEmptyBackground")

local Slot = {} 

Slot.id = nil
Slot.slotObj = INVENTORY_SLOT


Slot.name = nil
Slot.rarity = nil
Slot.bg = nil
Slot.image = nil
Slot.qt = nil
Slot.desc = nil
Slot.type = nil
Slot.itemID = nil

function Slot.New(id, item, qt)
    local newSlot = setmetatable({}, {__index = Slot}) 

    local tableIdentifier

    if item ~= "empty" then
        for k, v in pairs(TEST_TABLE) do 
            if TEST_TABLE[k].Name == item.name then --look for matching name in database
                tableIdentifier = k
                break
            end
        end

        newSlot.itemID = tableIdentifier

        newSlot.rarity = RARITY_COLORS[TEST_TABLE[tableIdentifier].Rarity]
        newSlot.bg = ITEM_BACKGROUND
        newSlot.image = TEST_TABLE[tableIdentifier].Img
        newSlot.desc = TEST_TABLE[tableIdentifier].Desc

        if qt == 1 then
            newSlot.qt = " "
        else 
            newSlot.qt = tostring(qt)
        end

    else 
        newSlot.rarity = COMMON
        newSlot.bg = ITEM_EMPTY_BACKGROUND
    end

    if id > 30 then 
        if id == 31 then
            newSlot.type = "head"
        elseif id == 32 then
            newSlot.type = "weapon"
        elseif id == 33 then
            newSlot.type = "chest"
        elseif id == 34 then
            newSlot.type = "shield"
        elseif id == 35 then
            newSlot.type = "legs"
        elseif id == 36 then
            newSlot.type = "ring"
        elseif id == 37 then
            newSlot.type = "boots"
        end
    else 
        newSlot.type = "inventory"
    end

    newSlot.name = item.name
    newSlot.id = id
    newSlot.slotObj = INVENTORY_SLOT
    
    return newSlot
end

return Slot