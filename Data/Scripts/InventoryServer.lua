local PLAYER_ACTION_MANAGER = script:GetCustomProperty("PlayerActionManager"):WaitForObject()


local Backpack = script:GetCustomProperty("Backpack")
local ITEM_TABLE = require(script:GetCustomProperty("ItemTable"))
local BACKPACKS_FOLDER = script:GetCustomProperty("Backpacks"):WaitForObject()


local playerBackpacks = {}

local itemTypeIdentifiers = {"head", "weapon", "chest", "shield", "legs", "ring", "boots"}

local function updatePlayerEquipment (player, item, type, ANIM_STANCE) 
    -- grab the actual item from the item table, set to variable to be used later

    local playerEquipmentProperty = playerBackpacks[player.id]:GetCustomProperty("Equipment")

    local CleanedData
    local NewData = ""

    if playerEquipmentProperty == "" then -- if property is empty for ANY REASON... get fucked but it gets caught here
        CleanedData = {0,0,0,0,0,0,0}
    else 
        CleanedData = {CoreString.Split(playerEquipmentProperty, "/")}
        CleanedData[8] = nil
    end

    for  i=1, 7, 1 do 
        if type == itemTypeIdentifiers[i] then 
            NewData = NewData .. tostring(item) .. "/"
        else 
            NewData = NewData .. tostring(CleanedData[i]) .. "/"
        end
    end

    playerBackpacks[player.id]:SetCustomProperty("Equipment", NewData)
    -- feed item.itemID to the networked property on backpack
        -- grab current string, split it into table, store in variable
        -- set new variable for the updated string
        -- iterate through the table, until item.type matches the array index
        -- replace the item in the array with the new item
        -- finish up the rest of the string

    -- networked property should update and call logic from another script to update the players equipment
    if ANIM_STANCE ~= "" then 
        player.animationStance = ANIM_STANCE
    end
end

local function swapItems (player, moveTo, moveFrom, moveToApi, moveFromApi)
    --handle players animationStance based on the weapon currently equipped. defaults to "unarmed_stance"
    local AS = ITEM_TABLE[moveFromApi.itemID].AS or "unarmed_stance"
    local AbilString = "empty"

    -- if x/y > 30 then do equipment management bullshit

    local isEquipment = false
    local isSwapping = false

    -- grab items from database that switched to feed into updatePlayerEquipment
    local itemMoveTo = ITEM_TABLE[moveToApi.itemID]
    local itemMoveFrom = ITEM_TABLE[moveFromApi.itemID]

    if moveTo > 30 then -- check if the item is going into an equipment slot
        isEquipment = true
    elseif moveFrom > 30 then -- check if the item is coming out of an equipment slot
        isSwapping = true
    end

    -- check to see if the item is able to be set to the equipment slot; i.e. if it is a weapon, armor, ring, etc.
    -- STRUCTURE:  apiItem.type = num
    -- 31 head
    -- 32 weapon
    -- 33 chest
    -- 34 shield
    -- 35 legs
    -- 36 ring
    -- 37 boots
    if isEquipment == true and isSwapping == false then 
        if itemMoveFrom.EquipSlot == itemTypeIdentifiers[moveToApi.id - 30] then --if the item type matches the slot type, then proceed
            playerBackpacks[player.id]:MoveFromSlot(moveFrom, moveTo)
            AbilString = ITEM_TABLE[moveFromApi.itemID].Abilities or "empty"
            updatePlayerEquipment(player, moveFromApi.itemID, itemMoveFrom.EquipSlot, AS)
        end
    elseif isEquipment == true and isSwapping == true then --if the item matches type, then proceed with swap
        if itemMoveFrom.EquipSlot == itemMoveTo.EquipSlot then
            playerBackpacks[player.id]:MoveFromSlot(moveFrom, moveTo)
            AbilString = ITEM_TABLE[moveFromApi.itemID].Abilities or "empty"
            updatePlayerEquipment(player, moveFromApi.itemID, itemMoveFrom.EquipSlot, AS)
        end
    elseif isEquipment == false and isSwapping == true then --if unequipping
        if playerBackpacks[player.id]:CanMoveFromSlot(moveFrom, moveTo) == true then
            playerBackpacks[player.id]:MoveFromSlot(moveFrom, moveTo)
            --if swapping position has an item, check what item it is
            --if it is a weapon, armor, ring, etc. then proceed with itemMoveFrom.EquipSlot
            --else, set null or something and then catch it in updatePlayerEquipment
            if itemMoveTo ~= nil then 
                AbilString = ITEM_TABLE[moveFromApi.itemID].Abilities or "empty"
                updatePlayerEquipment(player, moveFromApi.itemID, itemMoveFrom.EquipSlot, AS)
            else 
                updatePlayerEquipment(player, 0, itemMoveFrom.EquipSlot, AS)
            end
        end
    else --switch in normal inventory
        if playerBackpacks[player.id]:CanMoveFromSlot(moveFrom, moveTo) == true then
            playerBackpacks[player.id]:MoveFromSlot(moveFrom, moveTo)
        end
    end

    if moveTo == 32 then 
        PLAYER_ACTION_MANAGER.context.SpawnAbilities(player, AbilString) -- SpawnAbilities(player, abilities string)
    elseif moveFrom == 32 and isEquipment == false then
        PLAYER_ACTION_MANAGER.context.WipeAbilities(player)
    end

    -- if only one is in the equipment slots, then populate networked property space
    -- if swapping from equipment slots, then use moveTo to populate networked property space
    -- feed that item into updatePlayerEquipment
end

local function giveItems(player) 
    local bp = playerBackpacks[player.id]
    bp:AddItem(ITEM_TABLE[1].Item)
    bp:AddItem(ITEM_TABLE[2].Item)
    bp:AddItem(ITEM_TABLE[11].Item, {slot = 9})
    bp:AddItem(ITEM_TABLE[2].Item)
    bp:AddItem(ITEM_TABLE[2].Item)
    bp:AddItem(ITEM_TABLE[3].Item)
    bp:AddItem(ITEM_TABLE[4].Item)
    bp:AddItem(ITEM_TABLE[5].Item)
    bp:AddItem(ITEM_TABLE[6].Item)
    bp:AddItem(ITEM_TABLE[7].Item)
    bp:AddItem(ITEM_TABLE[8].Item)
    bp:AddItem(ITEM_TABLE[9].Item)
    bp:AddItem(ITEM_TABLE[10].Item)
end

local function deleteItems (player, deleteFrom) 
    local bp = playerBackpacks[player.id]
    if bp:CanRemoveFromSlot(deleteFrom) == true then 
        bp:RemoveFromSlot(deleteFrom)
        print("SUCCESS: " .. player.name)
    else 
        print("ERROR: cannot remove item" ..  tostring(deleteFrom)  .. "; player: " .. tostring(player.name))
    end
    -- if deleteFrom > 30 then do equipment management bullshit
end

Game.playerJoinedEvent:Connect(function (player)
    -- player:SetVisibility(false)


    local backpack = World.SpawnAsset(Backpack, {parent = BACKPACKS_FOLDER})
    backpack:Assign(player)
    playerBackpacks[player.id] = backpack
    giveItems(player)
end)

Game.playerLeftEvent:Connect(function (player) 
    playerBackpacks[player.id]:Destroy()
end)

Events.ConnectForPlayer("SwapItems", swapItems)
Events.ConnectForPlayer("DeleteItem", deleteItems)