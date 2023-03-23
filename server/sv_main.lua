local canChangeAccountnumber, execute = nil

ESX.RegisterServerCallback('tsBanking:getPlayerData', function(source, cb)
    local xPlayer      = ESX.GetPlayerFromId(source)
    local playerName   = xPlayer.getName()
    local money        = xPlayer.getAccount('money').money
    local accountmoney = xPlayer.getAccount('bank').money

    cb(playerName, money, accountmoney)
end)

--[[
    ----------------------
    Changing accountnumber 
    ----------------------
--]]

ESX.RegisterServerCallback('tsBanking:checkIBANNumber', function(source, cb)
    local src      = source
    local xPlayer  = ESX.GetPlayerFromId(src)
    local state    = false
    local result   = MySQL.query.await('SELECT * FROM tsbanking_ibans WHERE identifier = ?', {xPlayer.identifier})
    local bankdata = {}

    if table.empty(result) then
        TriggerClientEvent('tsBanking:createIBANInput', src)
    else
        for i = 1, #result, 1 do
            table.insert(bankdata, {
                iban = result[i].accountnumber,
                id   = i
            })
        end
        state = true
        cb(bankdata, state)
    end
end)

RegisterServerEvent('tsBanking:checkForValidIBANNumber')
AddEventHandler('tsBanking:checkForValidIBANNumber', function(newAccountnumber)
    local src              = source
    local xPlayer          = ESX.GetPlayerFromId(src)
    local result           = MySQL.query.await('SELECT * FROM tsbanking_ibans WHERE accountnumber = ?', {newAccountnumber})
    local bankdata2        = {}

    if table.empty(result) then
        TriggerClientEvent('tsBanking:refreshAccountNumber', src, newAccountnumber)
    else
        TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_change'), _U('no_change_possible'), 'CHAR_BANK_MAZE', 9)
    end
end)

RegisterServerEvent('tsBanking:insertIBAN')
AddEventHandler('tsBanking:insertIBAN', function(iban)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.insert('INSERT INTO tsbanking_ibans (identifier, name, accountnumber) VALUES (?, ?, ?)', {xPlayer.identifier, xPlayer.getName(), iban})
end)

RegisterServerEvent('tsBanking:updateAccountnumber')
AddEventHandler('tsBanking:updateAccountnumber', function(newAccountnumber)
    local src       = source
    local xPlayer   = ESX.GetPlayerFromId(src)
    local bankMoney = xPlayer.getAccount('bank').money

    if bankMoney < Config.AccountNumberChangeCost then
        TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_change'), _U('no_money_for_change'), 'CHAR_BANK_MAZE', 9)
    else
        xPlayer.removeAccountMoney('bank', Config.AccountNumberChangeCost)

        MySQL.update('UPDATE tsbanking_ibans SET accountnumber = ? WHERE identifier = ?', {newAccountnumber, xPlayer.identifier})
        TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_accountnumber_changed'), _U('notify_accountnumber_changed_success'), 'CHAR_BANK_MAZE', 9)
    end
end)

--[[
    -------------------------------------
    Deposit, withdraw and transfer events 
    -------------------------------------
--]]

RegisterServerEvent('tsBanking:deposit')
AddEventHandler('tsBanking:deposit', function(amount)
    local src     = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if amount ~= nil and amount > 0 then
        if amount > xPlayer.getMoney() then
            amount = xPlayer.getMoney()

            if amount <= 0 then
                TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_deposit'), _U('no_deposit_possible'), 'CHAR_BANK_MAZE', 9)
            else
                TriggerClientEvent('tsBanking:depositMoney', src, amount)

                xPlayer.removeMoney(amount)
                xPlayer.addAccountMoney('bank', amount)

                TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_deposit_headline'), _U('notify_deposit_message', amount), 'CHAR_BANK_MAZE', 9)
            end
        else
            TriggerClientEvent('tsBanking:depositMoney', src, amount)

            xPlayer.removeMoney(amount)
            xPlayer.addAccountMoney('bank', amount)

            TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_deposit_headline'), _U('notify_deposit_message', amount), 'CHAR_BANK_MAZE', 9)
        end
    else
        TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_deposit'), _U('no_deposit_possible'), 'CHAR_BANK_MAZE', 9)
    end
end)

RegisterServerEvent('tsBanking:withdraw')
AddEventHandler('tsBanking:withdraw', function(amount)
    local src       = source
    local xPlayer   = ESX.GetPlayerFromId(src)

    if amount ~= nil and amount > 0 then
        if amount > xPlayer.getAccount('bank').money then
            amount = xPlayer.getAccount('bank').money

            if amount <= 0 then
                TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_withdraw'), _U('no_withdraw_possible'), 'CHAR_BANK_MAZE', 9)
            else
                TriggerClientEvent('tsBanking:withdrawMoney', src, amount)

                xPlayer.removeAccountMoney('bank', amount)
                xPlayer.addMoney(amount)

                TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_withdraw_headline'), _U('notify_withdraw_message', amount), 'CHAR_BANK_MAZE', 9)
            end
        else
            TriggerClientEvent('tsBanking:withdrawMoney', src, amount)

            xPlayer.removeAccountMoney('bank', amount)
            xPlayer.addMoney(amount)
            
            TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_withdraw_headline'), _U('notify_withdraw_message', amount), 'CHAR_BANK_MAZE', 9)
        end
    else
        TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_no_withdraw'), _U('no_withdraw_possible'), 'CHAR_BANK_MAZE', 9)
    end
end)

RegisterServerEvent('tsBanking:transfer')
AddEventHandler('tsBanking:transfer', function(amount, banknumber)
    local src      = source
    local xPlayer  = ESX.GetPlayerFromId(src)
    local name     = xPlayer.getName()
    local amount   = tonumber(amount)
    local balance  = 0

    local result   = MySQL.query.await('SELECT * FROM tsbanking_ibans WHERE accountnumber = ?', {banknumber})
    local bankdata = {}

    for i = 1, #result, 1 do
        table.insert(bankdata, {
            identifier = result[i].identifier,
            id = i
        })
    end

    for k, v in pairs(bankdata) do
        zPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
    end
    local targetName = zPlayer.getName()

    if xPlayer ~= nil and zPlayer ~= nil then
        if xPlayer.source == zPlayer.source then
            TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_transfer_headline'), _U('cant_transfer_to_yourself'), "CHAR_BANK_MAZE", 9)
            TriggerClientEvent('tsBanking:TransferPossible', src, false, amount)
        else
            TriggerClientEvent('tsBanking:TransferPossible', src, true, amount)
            balance = xPlayer.getAccount('bank').money

            if balance <= 0 or balance < amount or amount <= 0 then
                TriggerClientEvent('esx:showAdvancedNotification', _U('bank_name'), _U('notify_transfer_headline'), _U('not_enough_money_transfer'), "CHAR_BANK_MAZE", 9)
            else
                xPlayer.removeAccountMoney('bank', amount)
                zPlayer.addAccountMoney('bank', amount)

                TriggerClientEvent('esx:showAdvancedNotification', src, _U('bank_name'), _U('notify_transfer_headline'), _U('notify_transfer_message', amount, targetName), 'CHAR_BANK_MAZE', 9)
                TriggerClientEvent('esx:showAdvancedNotification', zPlayer.source, _U('bank_name'), _U('notify_transfer_headline'), _U('notify_transfer_message_received', amount, name), 'CHAR_BANK_MAZE', 9)
            end
        end
    end
end)

--[[
    ---------
    Functions
    ---------
--]]

function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end
