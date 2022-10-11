NDCore = exports["ND_Core"]:GetCoreObject()
local notified = false
local open = false
local blips = {}
local selectedCharacter = NDCore.Functions.GetSelectedCharacter()
if selectedCharacter then
    TriggerServerEvent("ND_Properties:getProperties")
end

CreateThread(function()
    for _, location in pairs(accessLocations) do
        local blip = AddBlipForCoord(location)
        SetBlipSprite(blip, 350)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Real estate agency")
        EndTextCommandSetBlipName(blip)
    end

    while true do
        ped = PlayerPedId()
        pedCoords = GetEntityCoords(ped)
        Wait(500)
    end
end)

CreateThread(function()
    local wait = 500
    while true do
        Wait(wait)
        for _, location in pairs(accessLocations) do
            local dist = #(pedCoords - location)
            if dist < 12.0 then
                wait = 0
                DrawMarker(1, location.x, location.y, location.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 0.5, 48, 156, 96, 150, false, false, 2, false, nil, nil, false)
                if dist < 1.2 then
                    if not notified and not open then
                        notified = true
                        lib.showTextUI("[E] - View properties")
                    end
                    if IsControlJustPressed(0, 51) then
                        open = true
                        local propertiesUI = {}
                        for _, property in pairs(properties) do
                            if not property.notForSale then
                                local key = #propertiesUI + 1
                                propertiesUI[key] = {}
                                propertiesUI[key].id = property.propertyid
                                propertiesUI[key].price = property.price
                                propertiesUI[key].location = property.address
                                propertiesUI[key].desc = property.description
                                propertiesUI[key].images = property.images
                            end
                        end
                        SendNUIMessage({
                            type = "display",
                            status = true,
                            properties = json.encode(propertiesUI)
                        })
                        SetNuiFocus(true, true)
                        lib.hideTextUI()
                    end
                elseif notified then
                    notified = false
                    lib.hideTextUI()
                end
                break
            else
                wait = 500
            end
        end
    end
end)

RegisterNetEvent("ND_Doorlocks:returnDoors", function()
    TriggerServerEvent("ND_Properties:getProperties")
end)

RegisterNetEvent("ND_Properties:returnProperties", function(ownedProperties)
    exports["ND_Doorlocks"]:doorsResetDefault()
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    for _, property in pairs(properties) do
        for _, ownedProperty in pairs(ownedProperties) do
            if (ownedProperty.id == property.propertyid) then
                if ownedProperty.sale ~= nil or ownedProperty.sale ~= 0 or ownedProperty.sale ~= "0" then
                    property.price = ownedProperty.sale
                else
                    property.notForSale = true
                end
                if ownedProperty.owner then
                    if blips[property.propertyid] then
                        RemoveBlip(blips[property.propertyid])
                    end
                    blips[property.propertyid] = AddBlipForCoord(property.coords)
                    local blip = blips[property.propertyid]
                    SetBlipSprite(blip, 40)
                    SetBlipColour(blip, 0)
                    SetBlipScale(blip, 0.8)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Property (owned)")
                    EndTextCommandSetBlipName(blip)
                elseif ownedProperty.hasAccess then
                    if blips[property.propertyid] then
                        RemoveBlip(blips[property.propertyid])
                    end
                    blips[property.propertyid] = AddBlipForCoord(property.coords)
                    local blip = blips[property.propertyid]
                    SetBlipSprite(blip, 40)
                    SetBlipColour(blip, 3)
                    SetBlipScale(blip, 0.8)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Property (access)")
                    EndTextCommandSetBlipName(blip)
                end
                if (ownedProperty.hasAccess or ownedProperty.owner) then
                    for _, doorInfo in pairs(property.doors) do
                        doorInfo.hasAccess = true
                    end
                    break
                else
                    for _, doorInfo in pairs(property.doors) do
                        doorInfo.hasAccess = false
                    end
                    break
                end
            end
        end
    end
    for _, property in pairs(properties) do
        for _, doorInfo in pairs(property.doors) do
            for _, door in pairs(doorInfo.doors) do
                door.propertyid = property.propertyid
            end
            Wait(50)
            exports["ND_Doorlocks"]:doorAdd(doorInfo)
        end
    end
end)

RegisterNetEvent("ND_Properties:refresh", function()
    TriggerServerEvent("ND_Properties:getProperties")
end)

RegisterNetEvent("ND_Properties:updateDoors", function(updatedDoors)
    if blips[updatedDoors.propertyid] then
        RemoveBlip(blips[updatedDoors.propertyid])
    end
    blips[updatedDoors.propertyid] = AddBlipForCoord(updatedDoors.coords)
    local blip = blips[updatedDoors.propertyid]
    SetBlipSprite(blip, 40)
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Property (owned)")
    EndTextCommandSetBlipName(blip)

    TriggerServerEvent("ND_Properties:getProperties")
end)

function manage(result, players)
    local owned = {}

    for _, ownedProperty in pairs(result, players) do
        for _, property in pairs(properties) do
            if property.propertyid == ownedProperty.id then
                local plyList = {}
                for k, v in pairs(players) do
                    plyList[k] = v
                end
                local key = #owned + 1
                owned[key] = {}
                owned[key].propertyid = property.propertyid
                owned[key].address = property.address
                owned[key].images = property.images
                for ply, plyt in pairs(plyList) do
                    for _, char in pairs(json.decode(ownedProperty.access)) do
                        if plyt.character == char.character then
                            plyList[ply] = nil
                        end
                    end
                end
                owned[key].hasAccess = json.decode(ownedProperty.access)
                owned[key].sale = ownedProperty.sale
                owned[key].players = plyList
            end
        end
    end

    return owned
end

RegisterNetEvent("ND_Properties:updateUI", function(id, player)
    for _, property in pairs(properties) do
        if property.propertyid == id then
            property.notForSale = true
            if GetPlayerServerId(PlayerId()) == player then
                lib.notify({
                    title = "Property purchased",
                    description = "Your new property on " .. property.address .. " has been marked on your map!",
                    type = "success",
                    position = "bottom"
                })
            end
            break
        end
    end
    if not open then return end
    local propertiesUI = {}
    for _, property in pairs(properties) do
        if not property.notForSale then
            local key = #propertiesUI + 1
            propertiesUI[key] = {}
            propertiesUI[key].id = property.propertyid
            propertiesUI[key].price = property.price
            propertiesUI[key].location = property.address
            propertiesUI[key].desc = property.description
            propertiesUI[key].images = property.images
        end
    end
    SendNUIMessage({
        type = "update",
        properties = json.encode(propertiesUI)
    })
end)

RegisterNetEvent("ND_Properties:returnOwnedProperties", function(result, players)
    local owned = manage(result, players)

    SendNUIMessage({
        type = "manage",
        propertiesManage = json.encode(owned)
    })
end)

RegisterNetEvent("ND_Properties:refreshAccess", function(result, players)
    local owned = manage(result, players)

    SendNUIMessage({
        type = "refreshAccess",
        propertiesManage = json.encode(owned)
    })
end)

RegisterNUICallback("close", function(data)
    open = false
    notified = true
    lib.showTextUI("[E] - View properties")
    SetNuiFocus(false, false)
end)

RegisterNUICallback("checkAccount", function(data)
    local id = data.id
    local character = NDCore.Functions.GetSelectedCharacter()
    local money = character.bank
    for _, property in pairs(properties) do
        if property.propertyid == id then
            if money >= property.price then
                SendNUIMessage({
                    type = "purchase",
                    success = true
                })
                TriggerServerEvent("ND_Properties:purchaseProperty", property.propertyid)
            else
                SendNUIMessage({
                    type = "purchase",
                    success = false
                })
            end
            break
        end
    end
end)

RegisterNUICallback("sound", function(data)
    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)
end)

RegisterNUICallback("manage", function(data)
    TriggerServerEvent("ND_Properties:getOwnedProperties")
end)

RegisterNUICallback("grantAccess", function(data)
    TriggerServerEvent("ND_Properties:grantAccess", data.id, data.property)
end)

RegisterNUICallback("removeAccess", function(data)
    TriggerServerEvent("ND_Properties:removeAccess", data.character, data.property)
end)