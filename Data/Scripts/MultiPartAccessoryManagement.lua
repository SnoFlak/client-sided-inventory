local ROOT = script.parent

local otherItems = {}

for _, child in ipairs(ROOT:GetChildren()) do 
    if child ~= "Script" then 
        otherItems[child.name] = child
    end
end

ROOT.destroyEvent:Connect(function()
    for _, item in pairs(otherItems) do 
        if Object.IsValid(item) then 
            item:Detach()
            item:Destroy()
        end
    end
end)