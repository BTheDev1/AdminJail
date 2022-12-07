local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

PlayerData = {}

local jailTime = 0
local isMale = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

TriggerEvent('chat:addSuggestion', '/ajail', 'Admin Jail someone.', {{ name="id", help="ID of the player."}, { name="time", help="The amount of time they will go to jail."}, { name="reason", help="The reason you are admin jailing this player."}})
TriggerEvent('chat:addSuggestion', '/ajailrelease', 'UnAdmin Jail someone.', {{ name="id", help="ID of the player."}})
TriggerEvent('chat:addSuggestion', '/ajailtime', 'Time left of your admin sentence.', {})

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(newData)
	PlayerData = newData

	Citizen.Wait(25000)

	ESX.TriggerServerCallback("esx_ajail:retrieveJailTime", function(inJail, newJailTime)
		if inJail then
			TriggerEvent('chat:addMessage', {
				template = '<div class="chat-message text-system">SERVER: You\'ve been assigned to cell AJail{0} as of now. Cell assigning happens upon connect.</div>',
				args = { math.random(100,999) }
			})
			jailTime = newJailTime

			JailLogin()
		end
	end)
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
	PlayerData["job"] = response
end)

RegisterNetEvent("esx_ajail:jailPlayer")
AddEventHandler("esx_ajail:jailPlayer", function(newJailTime)
	jailTime = newJailTime

	Cutscene()
end)

RegisterNetEvent("esx_ajail:unJailPlayer")
AddEventHandler("esx_ajail:unJailPlayer", function()
	jailTime = 0

	UnJail()
end)

function JailLogin()
	local JailPosition = Config.JailPositions["Cell"]
	SetEntityCoords(PlayerPedId(), JailPosition["x"], JailPosition["y"], JailPosition["z"] - 1)

	exports['notify']:Info({ title = 'Prison', text = "Still in prison." })

	InJail()
end

function UnJail()
	InJail()

	ESX.Game.Teleport(PlayerPedId(), Config.Teleports["Boiling Broke"])

	exports['notify']:Info({ title = 'Jail', text = "You were released from adminjail." })
end

function InJail()

	--Jail Timer--

	Citizen.CreateThread(function()

		while jailTime > 0 do

			jailTime = jailTime - 1

			TriggerServerEvent("esx_ajail:updateJailTime", jailTime)

			if jailTime == 0 then
				UnJail()

				TriggerServerEvent("esx_ajail:updateJailTime", 0)
			end

			Citizen.Wait(60000)
		end

	end)

	--Jail Timer--

end

RegisterCommand('ajailtime', function(source, args, rawCommand)
	TriggerEvent("chat:addMessage", {
		template = '<div style="color: rgba(255, 99, 71, 1); width: fit-content; max-width: 300%; overflow: hidden; word-break: break-word; "> Jailtime left: {0} minute(s). </div>',
		args = { jailTime }
	})
end)

function getSex()
	if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
		isMale = true
	elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
		isMale = false
	end
	return isMale
end