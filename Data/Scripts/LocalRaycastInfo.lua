local localplayer = Game.GetLocalPlayer()
local INFORMATION = script:GetCustomProperty("Information"):WaitForObject()

function Tick() -- handles the informative text for what you're hovering
    local hitResult = World.Raycast(localplayer:GetViewWorldPosition(), localplayer:GetViewWorldPosition() + ((localplayer:GetViewWorldRotation() * Vector3.FORWARD) * 1750))
    --CoreDebug.DrawLine(localplayer:GetViewWorldPosition(), localplayer:GetViewWorldPosition() + ((localplayer:GetViewWorldRotation() * Vector3.FORWARD) * 12000))
    if hitResult ~= nil then
        if hitResult.other ~= localplayer then -- if camera hits anything other than the local player, change the informative text
            if INFORMATION.text ~= hitResult.other.name then 
                INFORMATION.text = hitResult.other.name
            end
        end
    else --if not hitting anything, set text to be empty, if it isnt set to empty already
        if INFORMATION.text ~= "" then 
            INFORMATION.text = ""
        end
    end
end