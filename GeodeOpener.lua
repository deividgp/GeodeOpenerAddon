GO = {}

GO.name = "GeodeOpener"
GO.name = "GeodeOpener"
GO.version = "v0.9.2"
GO.author = "Deividgp"

GO.defaults = {
  autoOpener = false,
}

local geodeIds = {134595, 134583, 134588, 134590, 134591, 171531, 134618, 134622, 134623}
local limitText = "GeodeOpener stopped because looting would put you over the stone limit"
local notEnoughText = "There is not enough space. Use some crystals"
local cooldown = 500
local openCd = 1000
local lootCd = 500

--Checks if there are geodes with a specific id
local function existsId(itemId)
  for index, value in ipairs(geodeIds) do
      if value == itemId then
          return true
      end
  end
  return false
end

--Checks if the user can open more crystals
local function hasMaxSpace()
  if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) >=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
    return true
  end
  return false
end

--Resets the cooldown variable so it's ready for the next iteration (500 ms)
local function resetCd()
  cooldown = lootCd
end

--Proceeds to open the geode
local function openGeode(bagId, slotId)
  if IsProtectedFunction("UseItem") then
    CallSecureProtected("UseItem", bagId, slotId)
  else
    UseItem(bagId, slotId)
  end
end

--Proceeds to loot the geode
local function lootGeode()
  --Check if looting that geode would put the user over the stone limit
  if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) + GetLootCurrency(CURT_CHAOTIC_CREATIA) <=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
    --Loots and ends the looting action (after cooldown)
    zo_callLater(function()
      LootCurrency(CURT_CHAOTIC_CREATIA)
      EndLooting()
    end, cooldown)
    return true
  else
    --If not enough space ends the looting
    zo_callLater(function()
      EndLooting()
    end, cooldown)
    d(warningText)
    return false
  end
end

--Main function
local function loopGeodes()
  --Main loop to iterate through the whole backpack
  for slotId=0, GetBagSize(BAG_BACKPACK) do
    local itemId = GetItemId(BAG_BACKPACK, slotId)
    if existsId(itemId) then
      --Opens after cooldown
      zo_callLater(function()
        openGeode(BAG_BACKPACK, slotId)
      end, cooldown)
      --Adds cooldown (+500 ms)
      cooldown = cooldown + lootCd
      enoughSpace = lootGeode()
      --If there is not enough space for crystals
      if enoughSpace == false then
        resetCd()
        return
      end
      --Adds more cooldown (+1000 ms)
      cooldown = cooldown + openCd

    end
  end
  resetCd()
end

--Function to check if the user has enough space before starting the loop
local function initializeLoop()
  if hasMaxSpace() == true then
    d(notEnoughText)
  else
    loopGeodes()
  end
end

function GO.OnPlayerActivated(event)
  initializeLoop()
end

--Once addons are fully loaded (login or reloadui)
function GO.OnAddOnLoaded(event, addOnName)
  --Checks if the loaded addon is GeodeOpener
  if GO.name ~= addOnName then return end

  --Removes the event to free up some space
  EVENT_MANAGER:UnregisterForEvent(GO.name, EVENT_ADD_ON_LOADED)

  --Slash commands
  SLASH_COMMANDS["/geodeopener"] = initializeLoop
  SLASH_COMMANDS["/go"] = initializeLoop

  --Saves the default variables
  GO.vars = ZO_SavedVars:NewAccountWide("GeodeOpenerSavedVars", 1, nil, GO.defaults)
  GO.CreateSettingsMenu()

  --If autoOpener is on (starts everytime you reload ui)
  if GO.vars.autoOpener then
    EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_PLAYER_ACTIVATED, GO.OnPlayerActivated)
  end
end

EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_ADD_ON_LOADED, GO.OnAddOnLoaded)