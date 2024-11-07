-- State property for logic to read from
local CUR_STATE = script:GetCustomProperty("CUR_STATE") -- State Property
local ACTION_TYPE = script:GetCustomProperty("ActionType") -- Type of Actions that are allowed. Special case use for tools

--local player variable
local localPlayer = Game.GetLocalPlayer()

--Handle all of the states of the player

-- 1 = idle: no weapons equipped, no windows open, empty slate
-- 2 = window: window is open; silence weapons if available 
-- 3 = combat: no windows open, listen to actions and inputs for combat
-- 4 = gathering: currently gathering
-- add more as needed
local STATE = 1 --set the initial state to idle

function SetState(newState)
    CUR_STATE:SetCustomProperty(newState)
end

function SetActionType(newActionType) 
    ACTION_TYPE:SetCustomProperty(newActionType)
end