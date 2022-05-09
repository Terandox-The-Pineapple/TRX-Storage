local pingLimit = 5

if fs.exists("event") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/event.lua event") end
local event = require("event")

if fs.exists("utils") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/utils.lua utils") end
local utils = require("utils")

if fs.exists("data") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/data.lua data") end
local data = require("data")

if fs.exists("shop_utils") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/shop-utils.lua shop_utils") end
local shop_utils = require("shop_utils")

if data.get("stversion", "stversion") == nil then
	data.set("stversion", "1.0", "stversion")
end

local version = tonumber(data.get("stversion", "stversion"))

shell.run("delete Ssv")
shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Storage/main/Version.lua Ssv")
shell.run("Ssv")

if tonumber(data.get("stversion", "stversion")) > version then
	shell.run("delete startup")
	shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Storage/main/Turtle.lua startup")
	shell.run("reboot")
	print("Updated Storage-System")
else
	print("No Updates")
end

print("Version: " .. tonumber(data.get("stversion", "stversion")))

if fs.exists("TRXDictionary") == true then shell.run("delete TRXDictionary") end
if data.get("LangLink", "config") == nil then
	shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/TRXDictionary.lua TRXDictionary")
else
	shell.run("wget " .. data.get("LangLink", "config") .. " TRXDictionary")
end

shell.run("TRXDictionary")

if shop_utils.setLanguage() == false then return false end

local dictionary = data.get("dictionary", "dictionary")
dictionary = textutils.unserialise(dictionary)

local localLang = data.get("language", "config")

local self = {
	facing = "north",
	pos = { x = 0, y = 0, z = 0 },
}

if data.get("channel", "channel") == nil then
	io.write(dictionary[localLang]["server_channel"])
	data.set("channel", io.read(), "channel")
end

local sendChannel = tonumber(data.get("channel", "channel"))

local pingtimer
local pongtimer
local failedPings = 0
local dropoffTimer
local failedDrops = 0
local localChannel
local task = {}
local wireless
local multiCraft = false

local slotTable = {
	1, 2, 3, 5, 6, 7, 9, 10, 11
}

function self.pickup()
	local chest = peripheral.wrap("bottom")
	local invsize = chest.size()
	for slot, item in pairs(chest.list()) do
		local maxslot = chest.getItemLimit(slot)
		turtle.suckDown(maxslot)
	end
end

function self.dropoff()
	for i = 1, 16 do
		if turtle.getItemCount(i) > 0 then
			turtle.select(i)
			turtle.dropDown()
		end
	end
end

function initConnection()
	if localChannel ~= nil then
		wireless.close(localChannel)
	end
	local allPeri = peripheral.getNames()
	for _, peri in pairs(allPeri) do
		peripheral.wrap(peri)
	end
	local wirelessList = { peripheral.find("modem", function(name, modem)
		return modem.isWireless()
	end) }
	for _, wirelessP in pairs(wirelessList) do
		wireless = wirelessP
	end
	localChannel = math.random(1000, 5000)
	wireless.open(localChannel)
	repeat
		wireless.transmit(sendChannel, localChannel, "assign|" .. sendChannel)
		local timer = os.startTimer(5)
		repeat
			tEvent, var, sender, receiver, message = os.pullEvent()
			--print(localChannel.." | "..event.." : "..tostring(message))
		until tEvent == "modem_message" or tEvent == "timer"
		if message == "denied" then
			print(dictionary[localLang]["connection_denied"])
			wireless.close(localChannel)
			localChannel = math.random(1000, 5000)
			wireless.open(localChannel)
		end
	until message == "confirmed"
	print(dictionary[localLang]["connected"] .. sendChannel .. " : " .. localChannel)
	failedPings = 0
end

initConnection()

function craft(replyChannel, message, isFinal)
	local count = tonumber(utils.split(message, "|", 2))
	local pattern = textutils.unserialize(utils.split(message, "|", 3))

	for itemID, item in pairs(pattern["#items"]) do
		for i, id in pairs(pattern["#pattern"]) do
			local slot = i
			if slot == 4 or slot == 5 or slot == 6 then
				slot = slot + 1
			elseif slot == 7 or slot == 8 or slot == 9 then
				slot = slot + 2
			end
			if itemID == id then
				turtle.select(slot)
				turtle.suckDown(count)
			end
		end
	end

	turtle.select(16)
	turtle.craft(count)

	if isFinal == true then
		self.dropoff()
		wireless.transmit(replyChannel, localChannel, "sendBack")
	else
		self.dropoff()
		wireless.transmit(sendChannel, localChannel, "sendBack")
	end
end

function craftcheck(replyChannel, localChannel, pattern, maxCount)
	for i = 1, 9 do
		local slot = i
		if slot == 4 or slot == 5 or slot == 6 then
			slot = slot + 1
		elseif slot == 7 or slot == 8 or slot == 9 then
			slot = slot + 2
		end

		turtle.select(slot)

		if pattern[i] ~= " " then
			turtle.suckDown(1)
		end
	end
	turtle.select(16)
	local is_crafted = turtle.craft()
	for i = 1, 16 do
		turtle.select(i)
		turtle.dropDown()
	end
	wireless.transmit(replyChannel, localChannel, "craftingCheckFinish|" .. is_crafted .. "|" .. maxCount)
end

local messageHandles = {
	["ping"] = function(replyChannel, message)
		return "pong"
	end,

	["craft"] = function(replyChannel, message)
		wireless.transmit(replyChannel, localChannel, "status|working")
		craft(replyChannel, message, true)
	end,

	["innerCraft"] = function(replyChannel, message)
		craft(replyChannel, message, false)
	end,

	["pong"] = function()
		pongtimer = nil
		failedPings = failedPings - 1
		if failedPings < 0 then failedPings = 0 end
	end,

	["loadstring"] = function(_, message)
		local func = loadstring(utils.split(message, "|", 2))
		setfenv(func, getfenv())
		func()
	end,

	["run"] = function(_, message)
		wireless.transmit(sendChannel, localChannel, "status|working")
		shell.run(utils.split(message, "|", 2))
		pingtimer = os.startTimer(10)
		return ("status|idle")
	end,

	["returnPattern"] = function(replyChannel, message)
		local pattern = utils.split(message, "|", 2)
		local maxCount = utils.split(message, "|", 3)
		local currentPattern = {}
		for i = 1, 9 do
			local item = utils.split(pattern, ";", i)
			currentPattern[#currentPattern + 1] = item
		end
		craftcheck(replyChannel, localChannel, currentPattern, maxCount)
	end,
}

function handleMessages(side, channel, replyChannel, message)
	--print(tostring(replyChannel).." : "..tostring(message))
	if replyChannel == nil then return end
	local messageType = utils.split(message, "|", 1)
	if messageHandles[messageType] == nil then return end
	local returnMessage = messageHandles[messageType](replyChannel, message)
	if returnMessage == nil then return end
	wireless.transmit(replyChannel, localChannel, returnMessage)
end

event.addHandler("modem_message", handleMessages)

function timerExpired(id)
	--print("Timer: "..tostring(id).." | Pingtimer:"..tostring(pingtimer))
	if id == pingtimer then
		wireless.transmit(sendChannel, localChannel, "ping")
		pongtimer = os.startTimer(1)
		pingtimer = nil
	elseif id == pongtimer then
		failedPings = failedPings + 1
		print(dictionary[localLang]["ping_not_answered"] .. failedPings)
		if failedPings > pingLimit then
			initConnection()
		end
	elseif id == dropoffTimer then
		failedDrops = failedDrops + 1
		if failedDrops > 5 then
			wireless.transmit(sendChannel, localChannel, "status|idle")
			return
		end
		wireless.transmit(sendChannel, localChannel, "requestDropoff")
		dropoffTimer = os.startTimer(5)
	end
end

event.addHandler("timer", timerExpired)

while true do
	pingtimer = os.startTimer(10)
	repeat
		event.handleCCEvents()
	until pingtimer == nil
end
