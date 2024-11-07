local ABILITIES_FOLDER = script:GetCustomProperty("AbilitiesFolder"):WaitForObject()
local ABILITIES_TABLE = require(script:GetCustomProperty("AbilitiesTable"))
local USER_ABILITIES_FOLDER_TEMPLATE = script:GetCustomProperty("UserAbilitiesFolderTemplate")

local folders = {}

-- gets called from the InventoryServer script; handles spawning the abilities of the newly attached weapon
function WipeAbilities (player) 
    for k, v in ipairs(folders[player.id]:GetChildren()) do
        v:Destroy()
    end
end

function SpawnAbilities (player, abilitiesString)
    WipeAbilities(player)

    local folder = folders[player.id]

    -- split the data for the abilities to spawn
    local Abils = {CoreString.Split(abilitiesString, "/")}

    for _, v in ipairs(Abils) do 
        if v ~= "" then 
            local Abil = ABILITIES_TABLE[tonumber(v)].Ability
            local AbilObj = World.SpawnAsset(Abil, {parent = folder})
            AbilObj.owner = player
        end
    end
end

Game.playerJoinedEvent:Connect(function(player)
    --create an ability folder for the player
    local folder = World.SpawnAsset(USER_ABILITIES_FOLDER_TEMPLATE, {parent = ABILITIES_FOLDER})
    folder:SetCustomProperty("OWNER", player.name)
    folders[player.id] = folder

end)

Game.playerLeftEvent:Connect(function(player) 
    --nullify local storage
    folders[player.id] = nil

    --destroy players ability folder
    for k, v in ipairs(ABILITIES_FOLDER:GetChildren()) do 
        local FOwner = v:GetCustomProperty("OWNER")

        if FOwner == player.name then 
            v:Destroy()
            break
        end
    end
end)