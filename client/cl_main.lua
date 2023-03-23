local showUI = false
local isNearATM = false
local number = nil
local accountAlreadyRegistered = nil

CreateThread(function()
    local wait = 500

    while true do
        isNearATM = false
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for k, v in pairs(Config.BankPositions.coords) do
            local dist = #(coords - v)

            if dist <= 3.0 and showUI == false then
                showInfobar(_U('enter_atm'))
                isNearATM = true
                wait = 0
            end
        end

        if isNearATM then
            if IsControlJustReleased(0, 38) then
                TriggerEvent('tsBanking:getPlayerData')

                ESX.TriggerServerCallback('tsBanking:checkIBANNumber', function(bankdata, state)
                    if state == true then
                        accountAlreadyRegistered = true

                        for k, v in pairs(bankdata) do
                            if showUI == false and accountAlreadyRegistered then
                                if Config.Animation then
                                    playAnim('mp_common', 'givetake1_a', Config.Animationtime)
                                    Wait(Config.Animationtime)
                                    SendNUIMessage({
                                        type       = "setPlayerIBAN",
                                        cardnumber = v.iban
                                    })

                                    SendNUIMessage({
                                        type = "openATMMenu"
                                    })
                                else
                                    SendNUIMessage({
                                        type       = "setPlayerIBAN",
                                        cardnumber = v.iban
                                    })

                                    SendNUIMessage({
                                        type = "openATMMenu"
                                    })
                                end
                                showUI = true
                                SetNuiFocus(true, true)
                            else
                                SendNUIMessage({
                                    type = "closeATMMenu"
                                })
                                showUI = false
                                SetNuiFocus(false, false)
                            end
                        end
                    elseif state == false then
                        accountAlreadyRegistered = false
                    end
                end)
            end
        end
        Wait(wait)
    end
end)

RegisterNetEvent('tsBanking:getPlayerData')
AddEventHandler('tsBanking:getPlayerData', function()
    ESX.TriggerServerCallback('tsBanking:getPlayerData', function(playerName, money, accountmoney)
        SendNUIMessage({
            type          = "getPlayerData",
            playerName    = playerName,
            money         = ESX.Math.GroupDigits(money),
            accountmoney  = ESX.Math.GroupDigits(accountmoney),
        })
    end)
end)

RegisterNetEvent('tsBanking:setPlayerIBAN')
AddEventHandler('tsBanking:setPlayerIBAN', function()
    ESX.TriggerServerCallback('tsBanking:checkIBANNumber', function(bankdata)
        for k, v in pairs(bankdata) do
            SendNUIMessage({
                type       = "setPlayerIBAN",
                cardnumber = v.iban,
            })
        end
    end)
end)

RegisterNetEvent('tsBanking:TransferPossible')
AddEventHandler('tsBanking:TransferPossible', function(state, amount)
    SendNUIMessage({
        type = "transfer",
        transferType  = "TransferPossible",
        transferState = state,
        amount = amount,
    })
end)

RegisterNetEvent('tsBanking:depositMoney')
AddEventHandler('tsBanking:depositMoney', function(amount)
    SendNUIMessage({
        type = "deposit",
        amount = amount,
    })
end)

RegisterNetEvent('tsBanking:withdrawMoney')
AddEventHandler('tsBanking:withdrawMoney', function(amount)
    SendNUIMessage({
        type = "withdraw",
        amount = amount,
    })
end)

--[[
    ----------------------
    ACCOUNTNUMBER CREATION
    ----------------------
--]]

RegisterNetEvent('tsBanking:createIBANInput')
AddEventHandler('tsBanking:createIBANInput', function()
    SendNUIMessage({
        type = "createNewIBAN",
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('tsBanking:registerIBAN')
AddEventHandler('tsBanking:registerIBAN', function()
    number = generateNumber(10000, 99999)

    TriggerServerEvent('tsBanking:insertIBAN', number)
end)

RegisterNetEvent('tsBanking:refreshAccountNumber')
AddEventHandler('tsBanking:refreshAccountNumber', function(newAccountnumber)
    TriggerServerEvent('tsBanking:updateAccountnumber', newAccountnumber)
end)

RegisterNetEvent('tsBanking:changeAccountNumber')
AddEventHandler('tsBanking:changeAccountNumber', function(newAccountnumber)
    TriggerServerEvent('tsBanking:checkForValidIBANNumber', newAccountnumber)
end)

--[[
    ------------
    Notification
    ------------
--]]

RegisterNetEvent('tsBanking:pictureNotification')
AddEventHandler('tsBanking:pictureNotification', function(icon, title, subtitle, msg)
    showPictureNotification(icon, title, subtitle, msg)
end)

--[[
    -------------
    NUI CALLBACKS
    -------------
--]]

RegisterNUICallback('deposit', function(data)
    TriggerServerEvent('tsBanking:deposit', tonumber(data.amount))
end)

RegisterNUICallback('withdraw', function(data)
    TriggerServerEvent('tsBanking:withdraw', tonumber(data.amount))
end)

RegisterNUICallback('transfer', function(data)
    TriggerServerEvent('tsBanking:transfer', data.amount, data.banknumber)
end)

RegisterNUICallback('balance', function(data)
    TriggerEvent('tsBanking:getPlayerData')
end)

RegisterNUICallback('registerAccountNumber', function(data)
    TriggerEvent('tsBanking:registerIBAN')
end)

RegisterNUICallback('setAccountNumber', function(data)
    TriggerEvent('tsBanking:setPlayerIBAN')
end)

RegisterNUICallback('changeAccountNumber', function(data)
    local newAccountnumber = data.newAccountnumber

    TriggerEvent('tsBanking:changeAccountNumber', newAccountnumber)
end)

RegisterNUICallback('close', function(data)
    SendNUIMessage({
        type = "closeATMMenu"
    })
    SetNuiFocus(false, false)
    showUI = false
end)

--[[
    ---------
    Functions
    ---------
--]]

function showPictureNotification(icon, title, subtitle, msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg);
    SetNotificationMessage(icon, icon, true, 1, title, subtitle);
    DrawNotification(false, true);
end

function showInfobar(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end

function generateNumber(span1, span2)
    local number = math.random(span1, span2)

    return Config.AccountnumberPrefix .. number
end

--[[
    -----
    OTHER
    -----
--]]

for k, v in pairs(Config.BankPositions.coords) do
    local blip = AddBlipForCoord(v)

    SetBlipSprite(blip, Config.Blip.MarkerID)
    SetBlipScale(blip, Config.Blip.Size)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.Name)
    EndTextCommandSetBlipName(blip)
end
