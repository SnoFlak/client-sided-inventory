local PLAYER_BASE_MODEL = script:GetCustomProperty("PlayerBaseModel")


Game.playerJoinedEvent:Connect(function(player)
    Task.Wait();
    local bodyInstance = World.SpawnAsset(PLAYER_BASE_MODEL)
    bodyInstance:AttachToPlayer(player, "root")
    for _, v in ipairs(bodyInstance:GetChildren()) do 
        v:AttachToPlayer(player, v.name)
    end
end)

Game.playerLeftEvent:Connect(function(player)
    local playerObjs = player:GetAttachedObjects()
    for _, v in ipairs(playerObjs) do 
        v:Destroy()
    end
end)