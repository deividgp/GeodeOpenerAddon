GO = {}

GO.name = "GeodeOpener"
GO.name = "GeodeOpener"
GO.version = "0.9"
GO.author = "Deividgp"

GO.defaults = {
  autoOpener = true,
}

local introText = "You just activated the Geode Opener addon"
local geodeIds = {134583, 134588, 134590, 134591, 171531, 134618, 134622, 134623}
local warningText = "GeodeOpener stopped because looting would put you over the stone limit"

function existsId(itemId)
  for index, value in ipairs(geodeIds) do
      if value == itemId then
          return true
      end
  end
  return false
end

function openGeodes()
  d(introText)
  for slotId=0, GetBagSize(BAG_BACKPACK) do
    local itemId = GetItemId(BAG_BACKPACK, slotId)
    if existsId(itemId) then
      if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
      else
        UseItem(BAG_BACKPACK, slotId)
      end
      if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) + GetLootCurrency(CURT_CHAOTIC_CREATIA) <=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
        LootAll()
      else
        d(warningText)
        EndLooting()
        return
      end
    end
  end
end

--Same as openGeodes but without chat alerts
function GO.OnPlayerActivated(event)
  for slotId=0, GetBagSize(BAG_BACKPACK) do
    local itemId = GetItemId(BAG_BACKPACK, slotId)
    if existsId(itemId) then
      if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", BAG_BACKPACK, slotId)
      else
        UseItem(BAG_BACKPACK, slotId)
      end
      if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) + GetLootCurrency(CURT_CHAOTIC_CREATIA) <=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
        LootAll()
      else
        EndLooting()
        return
      end
    end
  end
end

function GO.OnAddOnLoaded(event, addOnName)
  if GO.name ~= addOnName then return end

  EVENT_MANAGER:UnregisterForEvent(GO.name, EVENT_ADD_ON_LOADED)
  SLASH_COMMANDS["/geodeopener"] = openGeodes
  SLASH_COMMANDS["/go"] = openGeodes
  GO.vars = ZO_SavedVars:NewAccountWide("GeodeOpenerSavedVars", 1, nil, GO.defaults)
  GO.CreateSettingsMenu()

  if GO.vars.autoOpener then
    EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_PLAYER_ACTIVATED, GO.OnPlayerActivated)
  end
end

EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_ADD_ON_LOADED, GO.OnAddOnLoaded)