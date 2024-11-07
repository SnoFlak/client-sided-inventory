-- Ability Functions
local ABILITY_FUNCTIONS = script:GetCustomProperty("AbilityFunctions"):WaitForObject()
-- Ability Functions

local ABILITIES = script:GetCustomProperty("Abilities"):WaitForObject()
local localplayer = Game.GetLocalPlayer()
local AbilityFolder 

local AbilityListeners = {}

local AbilityFunctions = {}
AbilityFunctions["Gather"] = function () print("called Gather Function from Table") end

while AbilityFolder == nil do 
    for k, v in ipairs(ABILITIES:GetChildren()) do 
        local OWNER =  v:GetCustomProperty("OWNER")
        if OWNER == localplayer.name then 
            AbilityFolder = v
        end
    end
    Task.Wait()
end

AbilityFolder.childAddedEvent:Connect(function (parent, child)
    Task.Spawn(function () 
        local ListenerTable = {}
        local FUNC = child:GetCustomProperty("Func")
        
        while FUNC == nil do 
            if Object.IsValid(child) then
                FUNC = child:GetCustomProperty("Func")
                Task.Wait()
            else 
                break
            end
        end
        -- child.readyEvent:Connect()
        if Object.IsValid(child) then 
            -- child.readyEvent:Connect()
            child.castEvent:Connect(AbilityFunctions[FUNC])
            -- child.executeEvent:Connect()
            -- child.cooldownEvent:Connect()
            -- AbilityListeners[child.name] = ListenerTable
        end
    end)
end)

AbilityFolder.childRemovedEvent:Connect(function (parent, child)
    for k, v in pairs(AbilityListeners[child.name]) do 
        v:Disconnect()
    end
    AbilityListeners[child.name] = nil
end)

Game.playerLeftEvent:Connect(function()
    --destroy ability listeners
end)