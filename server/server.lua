ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("ajail", function(src, args, raw)

	local xPlayer = ESX.GetPlayerFromId(src)
	
	if xPlayer.getGroup() == 'management' or 'admin' or 'mod' or 'developer' then
		local jailPlayer = args[1]
		local xTarget = ESX.GetPlayerFromId(jailPlayer)
		local jailTime = tonumber(args[2])
		local jailReason = tostring(args[3])
		if jailPlayer ~= nil then
			if jailTime ~= nil then
				JailPlayer(jailPlayer, jailTime)
				TriggerClientEvent('chat:addMessage', -1, {
					template = '<div style="color: rgba(255, 99, 71, 1); width: fit-content; max-width: 125%; overflow: hidden; word-break: break-word; "> AdmCmd: {1} was admin jailed by SYSTEM for {2} minute(s), Reason: {3} </div>',
					args = { xPlayer.getGroup() .. ' ' .. xPlayer.getName(), xTarget.getName(), jailTime, jailReason }
				})
			else
				TriggerClientEvent('notify:Error', source, { title = 'Error', text = 'Jail invaild.' })
			end
		else
			TriggerClientEvent('notify:Error', source, { title = 'Error', text = 'Player id invaild.' })
		end
	else
		TriggerClientEvent('notify:Error', source, { title = 'Error', text = 'You must be a officer for this.' })
	end
end)

RegisterCommand("ajailrelease", function(src, args)

	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer.getGroup() ~= "user" then

		local jailPlayer = args[1]

		if GetPlayerName(jailPlayer) ~= nil then
			UnJail(jailPlayer)
		else
			TriggerClientEvent('notify:Error', source, { title = 'Error', text = 'This id is not online.' })
		end
	else
		TriggerClientEvent('notify:Error', source, { title = 'Error', text = 'You must be an officer for this.' })
	end
end)

RegisterServerEvent("esx_ajail:jailPlayer")
AddEventHandler("esx_ajail:jailPlayer", function(targetSrc, jailTime)
	local src = source
	local targetSrc = tonumber(targetSrc)

	JailPlayer(targetSrc, jailTime)
end)

RegisterServerEvent("esx_ajail:unJailPlayer")
AddEventHandler("esx_ajail:unJailPlayer", function(targetIdentifier)
	local src = source
	local xPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier)

	if xPlayer ~= nil then
		UnJail(xPlayer.source)
	else
		MySQL.Async.execute(
			"UPDATE users SET ajail = @newJailTime WHERE identifier = @identifier",
			{
				['@identifier'] = targetIdentifier,
				['@newJailTime'] = 0
			}
		)
	end
end)

RegisterServerEvent("esx_ajail:updateJailTime")
AddEventHandler("esx_ajail:updateJailTime", function(newJailTime)
	local src = source

	EditJailTime(src, newJailTime)
end)

function JailPlayer(jailPlayer, jailTime)
	TriggerClientEvent("esx_ajail:jailPlayer", jailPlayer, jailTime)

	EditJailTime(jailPlayer, jailTime)
end

function UnJail(jailPlayer)
	TriggerClientEvent("esx_ajail:unJailPlayer", jailPlayer)

	EditJailTime(jailPlayer, 0)
end

function EditJailTime(source, jailTime)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier

	MySQL.Async.execute(
       "UPDATE users SET ajail = @newJailTime WHERE identifier = @identifier",
        {
			['@identifier'] = Identifier,
			['@newJailTime'] = tonumber(jailTime)
		}
	)
end

ESX.RegisterServerCallback("esx_ajail:retrieveJailedPlayers", function(source, cb)
	
	local jailedPersons = {}

	MySQL.Async.fetchAll("SELECT firstname, lastname, ajail, identifier FROM users WHERE ajail > @ajail", { ["@ajail"] = 0 }, function(result)

		for i = 1, #result, 1 do
			table.insert(jailedPersons, { name = result[i].firstname .. " " .. result[i].lastname, jailTime = result[i].jail, identifier = result[i].identifier })
		end

		cb(jailedPersons)
	end)
end)

ESX.RegisterServerCallback("esx_ajail:retrieveJailTime", function(source, cb)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier


	MySQL.Async.fetchAll("SELECT ajail FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		local JailTime = tonumber(result[1].ajail)

			if JailTime > 0 then
	
				cb(true, JailTime)
			else
				cb(false, 0)
			end
	end)
end)