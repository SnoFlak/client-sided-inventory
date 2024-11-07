local INVENTORY_API = require(script:GetCustomProperty("Inventory_API"))

-- UI Objects
local INVENTORY = script:GetCustomProperty("Inventory"):WaitForObject()
local SLOTS_PANEL = script:GetCustomProperty("SlotsPanel"):WaitForObject()
local TOOLTIP_WINDOW = script:GetCustomProperty("TooltipWindow"):WaitForObject()
local EQUIPMENT_PANEL = script:GetCustomProperty("EquipmentPanel"):WaitForObject()
local DRAG_ICON = script:GetCustomProperty("DragIcon")
local CHARACTER_NAME = script:GetCustomProperty("CharacterName"):WaitForObject()
local STAT_INFO = script:GetCustomProperty("StatInfo"):WaitForObject()

local DELETE_ITEM_BUTTON = script:GetCustomProperty("DeleteItemButton"):WaitForObject()

--color hack bc im lazy
local COMMON = script:GetCustomProperty("COMMON")

-- typical variables needed for the inventory
local INV_STATE = false --if inv is open or not
local localplayer = Game.GetLocalPlayer()
local backpack = nil --players backpack inventory object

local hoveredSlot = nil --slot that is hovered over
local selectedSlot = nil
local isPressed = false --if the mouse is pressed

local listenerRelease --Input.mouseButtonReleasedEvent that is given on localplayer joined
local DIB_HOVER_LISTENER = DELETE_ITEM_BUTTON.hoveredEvent:Connect(function (btn) hoveredSlot = DELETE_ITEM_BUTTON end)

SLOTS = {} --table of slots: [ [SLOT, apiSlot], ...]

LISTENERS_ON = {} --hover listeners for slot buttons
LISTENERS_OFF = {} --unhover listeneres for slot buttons
LISTENERS_HELD = {} --held listeners for slot buttons
LISTENERS_CLICK = {} --clicked listeners for slot buttons

local function returnAPISlot (SLOT)
    for k, v in pairs(SLOTS) do
        if v[1] == SLOT then
            return v[2]
        end
    end
end

local function dragIconInitiation (SLOT) --initialize drag icon
    local dragIcon = World.SpawnAsset(DRAG_ICON, {parent = INVENTORY.parent})
    local dragImg = dragIcon:GetCustomProperty("ItemImage"):WaitForObject()
    local dragRarity = dragIcon:GetCustomProperty("QualityBackground"):WaitForObject()
    local dragQt = dragIcon:GetCustomProperty("Quantity"):WaitForObject()

    local apiItem = returnAPISlot(SLOT)

    dragImg:SetImage(apiItem.image)
    dragRarity:SetColor(apiItem.rarity - Color.New(0, 0, 0, 0.5))
    dragQt.text = apiItem.qt or ""

    selectedSlot = SLOT

    Task.Spawn(function () -- move drag icon to mouse position while mouse is pressed
        while isPressed do
            dragIcon.x = Input.GetCursorPosition().x
            dragIcon.y = Input.GetCursorPosition().y
            Task.Wait()
        end     

        dragIcon:Destroy()
    end)

end

local function colorFrame (FRAME, apiItem) --color the frame of the tooltip window
    local clr

    if apiItem ~= nil then
        clr = apiItem.rarity
    else 
        clr = Color.WHITE
    end

    FRAME:SetColor(clr)
        
    for _, child in pairs(FRAME:GetChildren()) do 
        child:SetColor(clr)
    end 
end

local function toolTipInitiation (SLOT) 
    local apiItem = returnAPISlot(SLOT)

    if apiItem.name ~= nil then --if slot is not an empty slot, show tooltip

        -- populate tooltip window with correct information
        local NAME = TOOLTIP_WINDOW:GetCustomProperty("Name"):WaitForObject()
        local ITEM_IMAGE = TOOLTIP_WINDOW:GetCustomProperty("ItemImage"):WaitForObject()
        local INFO = TOOLTIP_WINDOW:GetCustomProperty("Info"):WaitForObject()
        local FRAME = TOOLTIP_WINDOW:GetCustomProperty("Frame"):WaitForObject()

        TOOLTIP_WINDOW.visibility = Visibility.FORCE_ON --turn tooltip window on

        NAME.text = apiItem.name
        ITEM_IMAGE:SetImage(apiItem.image)
        INFO.text = apiItem.desc

        if apiItem.rarity ~= COMMON then
            colorFrame(FRAME, apiItem)
        else 
            colorFrame(FRAME, nil)
        end

        Task.Spawn(function () -- follow mouse cursor
            while TOOLTIP_WINDOW.visibility == Visibility.FORCE_ON do 
                local curPos = Input.GetCursorPosition()
                TOOLTIP_WINDOW.x = curPos.x + 100
                TOOLTIP_WINDOW.y = curPos.y - 100
                Task.Wait() --wait for tooltip to be hidden, then stop following mouse
            end
        end)
    end
end

local function renderSlots () --render all slots
    --iterate through SLOTS array and update each slots data
    for i=1, backpack.slotCount, 1 do 
        local item 
        local SLOT_INDEX = SLOTS[i]
        local apiSlot 
        if backpack:GetItem(i) ~= nil then
            item = backpack:GetItem(i)
            apiSlot = INVENTORY_API.New(i, item, item.count)
        else 
            apiSlot = INVENTORY_API.New(i, "empty")
        end

        SLOT_INDEX[2] = apiSlot --update the apislot in table to match the inventory
        local BG = SLOT_INDEX[1]:GetCustomProperty("QualityBackground"):WaitForObject()
        local IMG = SLOT_INDEX[1]:GetCustomProperty("ItemImage"):WaitForObject()
        local QT = SLOT_INDEX[1]:GetCustomProperty("Quantity"):WaitForObject()
    
        BG:SetColor(apiSlot.rarity)

        if apiSlot.image ~= nil then 
            BG:SetImage(apiSlot.bg)
            IMG:SetImage(apiSlot.image)
            IMG:SetColor(Color.New(1,1,1,1))
        else 
            BG:SetImage(apiSlot.bg)
            IMG:SetColor(Color.New(0,0,0,0))
        end

        QT.text = apiSlot.qt or ""
    end
end

local function populateSlots () --create slots in backpack
    --inventory panel variables
    local x = 0
    local y = 0
    local rowCap = 10

    --equipment panel variables
    local ex = 90
    local ey = 0

    if backpack == nil then
        return
    end

    for i=1, 30, 1 do --CREATE SLOTS FOR INVENTORY PANEL
        --iterate through backpack slots
        local item
        local apiSlot

        if backpack:GetItem(i) ~= nil then --create a new api obj if slot is not empty in inventory, else, create an empty slot
            item = backpack:GetItem(i)
            apiSlot = INVENTORY_API.New(i, item, item.count)
        else 
            apiSlot = INVENTORY_API.New(i, "empty")
        end

        local SLOT = World.SpawnAsset(apiSlot.slotObj, {parent = SLOTS_PANEL})
        local BG = SLOT:GetCustomProperty("QualityBackground"):WaitForObject()
        local IMG = SLOT:GetCustomProperty("ItemImage"):WaitForObject()
        local QT = SLOT:GetCustomProperty("Quantity"):WaitForObject()

        BG:SetColor(apiSlot.rarity)

        if apiSlot.image ~= nil then --if slot has a background, set the item images
            BG:SetImage(apiSlot.bg)
            IMG:SetImage(apiSlot.image)
            IMG:SetColor(Color.New(1,1,1,1))
        else 
            BG:SetImage(apiSlot.bg)
            IMG:SetColor(Color.New(0,0,0,0))
        end

        QT.text = apiSlot.qt or "" --did this because it was easier than doing weird shit in the api

        --declare listeners for slot buttons

        local listener = SLOT.hoveredEvent:Connect(function () 
            hoveredSlot = SLOT
            toolTipInitiation(SLOT)
        end)

        local listenerOff = SLOT.unhoveredEvent:Connect(function () 
            hoveredSlot = nil
            TOOLTIP_WINDOW.visibility = Visibility.FORCE_OFF
        end)

        local listenerHeld = SLOT.pressedEvent:Connect(function (btn) 
            --do shit that i have to call yet... might be easier to make an actual function to pass in instead of coding it in here
            local apiItem = returnAPISlot(SLOT)

            
            if backpack:GetItem(apiItem.id) ~= nil then 
                isPressed = true
                selectedSlot = SLOT
                dragIconInitiation(btn)
            end
        end)

        local listenerClick = SLOT.clickedEvent:Connect(function (btn) ---yessirr
        end)

        --add listeners to their tables
        LISTENERS_ON[i] = listener
        LISTENERS_OFF[i] = listenerOff
        LISTENERS_HELD[i] = listenerHeld
        LISTENERS_CLICK[i] = listenerClick

        --math for positioning the slots in inventory UI
        SLOT.x = x 
        SLOT.y = y

        x = x + 75

        if i % rowCap == 0 then
            y = y + 75
            x = 0
            rowCap = rowCap + 10
        end

        --add slot to array
        SLOTS[i] = {SLOT, apiSlot}

    end 

    for i=31, 37, 1 do --CREATE EQUIPMENT SLOTS
        local equipment 
        local apiSlot 

        if backpack:GetItem(i) ~= nil then
            equipment = backpack:GetItem(i)
            apiSlot = INVENTORY_API.New(i, equipment, equipment.count)
        else 
            apiSlot = INVENTORY_API.New(i, "empty")
        end

        local SLOT = World.SpawnAsset(apiSlot.slotObj, {parent = EQUIPMENT_PANEL})
        SLOT:SetButtonColor(Color.New(0,0,0,0))
        local BG = SLOT:GetCustomProperty("QualityBackground"):WaitForObject()
        local IMG = SLOT:GetCustomProperty("ItemImage"):WaitForObject()
        local QT = SLOT:GetCustomProperty("Quantity"):WaitForObject()

        QT.text = ""

        BG:SetColor(apiSlot.rarity)

        if apiSlot.image ~= nil then 
            BG:SetImage(apiSlot.bg)
            IMG:SetImage(apiSlot.image)
            IMG:SetColor(Color.New(1,1,1,1))
        else 
            BG:SetImage(apiSlot.bg)
            IMG:SetColor(Color.New(0,0,0,0))
        end

        local listener = SLOT.hoveredEvent:Connect(function () 
            hoveredSlot = SLOT
            toolTipInitiation(SLOT)
        end)

        local listenerOff = SLOT.unhoveredEvent:Connect(function () 
            hoveredSlot = nil
            TOOLTIP_WINDOW.visibility = Visibility.FORCE_OFF
        end)

        local listenerHeld = SLOT.pressedEvent:Connect(function (btn) 
            --do shit that i have to call yet... might be easier to make an actual function to pass in instead of coding it in here
            local apiItem = returnAPISlot(SLOT)

            
            if backpack:GetItem(apiItem.id) ~= nil then 
                isPressed = true
                selectedSlot = SLOT
                dragIconInitiation(btn)
            end
        end)

        local listenerClick = SLOT.clickedEvent:Connect(function (btn) ---yessirr
        end)

        --add listeners to their tables
        LISTENERS_ON[i] = listener
        LISTENERS_OFF[i] = listenerOff
        LISTENERS_HELD[i] = listenerHeld
        LISTENERS_CLICK[i] = listenerClick

        --do positioning math here 

        if i == 32 or i == 35 or i == 36 then
            ey = ey + 75
            if i == 35 then
                ex = 90
            else
                ex = 15
            end
        elseif i == 34 then
            ex = 165  
        else
            ex = 90
        end

        if i == 32 or i == 34 then 
            SLOT.x = ex
            SLOT.y = ey + 25
        else
            SLOT.x = ex
            SLOT.y = ey
        end
        --add slot to array
        SLOTS[i] = {SLOT, apiSlot}

        ex = ex + 75

    end

    backPackChangedListener = backpack.changedEvent:Connect(renderSlots)
end

local function wipeListeners () --cleans out the array of listeners
    for k, v in pairs(LISTENERS_ON) do 
        v:Disconnect()
        v = nil
    end
    for k, v in pairs(LISTENERS_OFF) do 
        v:Disconnect()
        v = nil 
    end
    for k, v in pairs(LISTENERS_HELD) do 
        v:Disconnect()
        v = nil 
    end
    for k, v in pairs(LISTENERS_CLICK) do 
        v:Disconnect()
        v = nil 
    end

    LISTENERS_ON = {}
    LISTENERS_OFF = {}
    LISTENERS_HELD = {}
    LISTENERS_CLICK = {}
end

local function clearSlots () --clear slots in backpack
    for k, v in ipairs(SLOTS_PANEL:GetChildren()) do
        v:Destroy()
        v = nil
    end

    for k, v in ipairs(EQUIPMENT_PANEL:GetChildren()) do
        if v.name ~= "Paperdoll" then 
            v:Destroy()
            v = nil
        end
    end

    SLOTS = nil 
    SLOTS = {}

    wipeListeners()
end

local function updateMouseState (bool) --changes mouse state
    if bool == false then
        UI.SetCursorVisible(false)
        UI.SetCanCursorInteractWithUI(false)
    else 
        UI.SetCursorVisible(true)
        UI.SetCanCursorInteractWithUI(true)
    end
end

function mouseBtnRelease(pos, btn)
    if btn == 1 then
        if hoveredSlot ~= nil and hoveredSlot ~= DELETE_ITEM_BUTTON then --if the mouse is hovering a slot, and its not the delete item button
            if hoveredSlot ~= selectedSlot and selectedSlot ~= nil then
                local apiHoveredSlot = returnAPISlot(hoveredSlot)
                local apiSelectedSlot = returnAPISlot(selectedSlot)

                local a = Events.BroadcastToServer("SwapItems", apiHoveredSlot.id, apiSelectedSlot.id, apiHoveredSlot, apiSelectedSlot) --send out broadcast to move slots
                if a ~= 0 then
                    renderSlots()
                end
            end
        elseif hoveredSlot == DELETE_ITEM_BUTTON and selectedSlot ~= nil then --if the mouse is hovering the delete item button
            --delete item 
            local apiSelectedSlot = returnAPISlot(selectedSlot)
            if apiSelectedSlot.id <= 30 then 
                local b = Events.BroadcastToServer("DeleteItem", apiSelectedSlot.id)
                if b ~= 0 then
                    renderSlots()
                end
            end
        end
        isPressed = false
        selectedSlot = nil
    end
end

Input.actionPressedEvent:Connect(function (player, action) -- if player pressed "I"
    if action == "Inventory" then
        if INV_STATE == false then -- turn on inventory
            INVENTORY.visibility = (Visibility.FORCE_ON)
            populateSlots()
            updateMouseState(true)
            INV_STATE = true
        else                       -- turn off inventory
            INVENTORY.visibility = (Visibility.FORCE_OFF)
            --clear inventory based variables
            hoveredSlot = nil
            selectedSlot = nil
            isPressed = false
            --clear slots
            clearSlots()
            updateMouseState(false)
            INV_STATE = false

            if TOOLTIP_WINDOW.visibility == Visibility.FORCE_ON then
                TOOLTIP_WINDOW.visibility = Visibility.FORCE_OFF
            end
        end
    end
end)


Game.playerJoinedEvent:Connect(function (player) 
    if player == localplayer then
        backpack = localplayer:GetInventories()[1]  -- Get the first backpack
    end
    CHARACTER_NAME.text = player.name

    listenerRelease = Input.mouseButtonReleasedEvent:Connect(mouseBtnRelease)
end)