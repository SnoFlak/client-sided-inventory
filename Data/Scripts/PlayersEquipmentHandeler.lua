local BACKPACKS_FOLDER = script:GetCustomProperty("Backpacks_Folder"):WaitForObject()
local ITEM_TABLE = require(script:GetCustomProperty("ItemTable"))

local localplayer = Game.GetLocalPlayer()

local backpackPropertyListeners = {}
local propertyPreviousStates = {}

local function equipItem (newEquipmentItem, OWNER) 
    local newItemVisual = World.SpawnAsset(newEquipmentItem)
    newItemVisual:AttachToPlayer(OWNER, newItemVisual:GetCustomProperty("socket"))
    -- handle attaching multi-piece equipment
    local isMultiPieced = false
    local itemChildren = newItemVisual:GetChildren()
    --check to see if equipment has multiple pieces
    for _, child in pairs(itemChildren) do
        if child.name ~= "Art" then 
            isMultiPieced = true
            break
        end
    end

    if isMultiPieced then 
        for _, child in pairs(itemChildren) do
            local AttachTo = child:GetCustomProperty("socket")
            if AttachTo ~= nil then 
                child:AttachToPlayer(OWNER, AttachTo)
            end
        end
    end

end

local function updatePlayerEquipment (backpack, equipmentProperty) 
    local BACKPACK_OWNER = backpack.owner

    --create comparison tables
    local newEquipmentString = backpack:GetCustomProperty(equipmentProperty)
    local oldEquipmentString = propertyPreviousStates[backpack.owner.id]

    local newItems = {CoreString.Split(newEquipmentString, "/")}
    local oldItems = {CoreString.Split(oldEquipmentString, "/")}

    local tableIdentifier
    local newEquipmentItem

    local hasAttachedObjects = false
    local foundAttachedObject = false

    local isRing = false

    --find which slot was changed (might be unnecessary?)

    for k, v in pairs(newItems) do 
        if v ~= oldItems[k] then 
            if tonumber(v) == 0 then --if unequipping item, and not swapping
                newEquipmentItem = 0
                tableIdentifier = ITEM_TABLE[tonumber(oldItems[k])]
                if k == 6 then 
                    isRing = true
                end
                break
            else
                tableIdentifier = ITEM_TABLE[tonumber(v)]
                newEquipmentItem = ITEM_TABLE[tonumber(v)].ItemObject
                if k == 6 then 
                    isRing = true
                end
                break
            end
        end
    end

    --IF EQUIPMENT IS NOT A RING, UPDATE VISUALS (rings have no visuals)

    if isRing == false then 
        for _, v in ipairs(backpack.owner:GetAttachedObjects()) do 
            if hasAttachedObjects == false then
                hasAttachedObjects = true
            end

            --verify that the player has the item attached
            if tableIdentifier ~= 0 then 
                if v:GetAttachedToSocketName() == tableIdentifier.Socket then
                    foundAttachedObject = true
                    -- print("found attached object")
                end
            else 
                print("no table identifier")
            end
        end

        --if equipped, then destroy it and proceed to attach new item
        --else, attach new item
        --grab coreObject from ITEM_TABLE and attach to player (itemTableItem.ItemObject)

        if hasAttachedObjects == false then --if the player has NOTHING attached to them, proceed to add the item
            equipItem(newEquipmentItem, BACKPACK_OWNER)
        else --if the player does have something attached to them
            if foundAttachedObject == true then --if it found the item matching the slot, destroy old item, and attach new item
                for _, v in ipairs(BACKPACK_OWNER:GetAttachedObjects()) do 
                    if v:GetAttachedToSocketName() == tableIdentifier.Socket then
                        if v.name ~= tableIdentifier.Socket then
                            v:Destroy()
                            break
                        end
                    end
                end
                if newEquipmentItem ~= 0 then --if item isnt a ring, attach new item
                    equipItem(newEquipmentItem, BACKPACK_OWNER)
                end
            else --add new item anyways
                equipItem(newEquipmentItem, BACKPACK_OWNER)
            end
        end
    end
    --save new string to propertyPreviousStates
    propertyPreviousStates[backpack.owner.id] = newEquipmentString
end

local function initializePlayerEquipment (OWNER, itemData) 
    local Items = {CoreString.Split(itemData, "/")}

    local newEquipmentItem

    for k, v in pairs(Items) do 
        if k == 8 then 
            break
        end
        if k ~= 6 then 
            if tonumber(v) == 0 then 
                newEquipmentItem = 0 
            else 
                newEquipmentItem = ITEM_TABLE[tonumber(v)].ItemObject
                equipItem(newEquipmentItem, OWNER)
            end
        end
    end
end


Game.playerJoinedEvent:Connect(function(player)
    Task.Spawn(function ()
        local waiting = true

        while waiting do 
            Task.Wait()
            
            for k, v in ipairs(BACKPACKS_FOLDER:GetChildren()) do 
                if k == 1 then 
                    waiting = false
                end
            end

            if waiting == true then 
            end
        end

        for k, v in ipairs(BACKPACKS_FOLDER:GetChildren()) do 
            if v.owner.id == player.id then  
                --set up listeners for backpacks      
                if backpackPropertyListeners[player.id] == nil then 
                    backpackPropertyListeners[v.owner.id] = v.customPropertyChangedEvent:Connect(updatePlayerEquipment)
                    propertyPreviousStates[v.owner.id] = v:GetCustomProperty("Equipment")
                    break
                end
            end
        end

        --if a new player joins, spawn their armor in
        for k, v in ipairs(BACKPACKS_FOLDER:GetChildren()) do 
            if v.owner.id == player.id then 
                initializePlayerEquipment(v.owner, v:GetCustomProperty("Equipment"))
                break
            end
        end

    end)
end)

Game.playerLeftEvent:Connect(function (player) 
    backpackPropertyListeners[player.id]:Disconnect()
    backpackPropertyListeners[player.id] = nil
    propertyPreviousStates[player.id] = nil
    for _, item in pairs(player:GetAttachedObjects()) do 
        if Object.IsValid(item) then 
            item:Destroy()
        end
    end
end)