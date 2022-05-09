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
	shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Storage/main/Server.lua startup")
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

if data.get("channel", "channel") == nil then
	io.write(dictionary[localLang]["channel_number"])
	data.set("channel", io.read(), "channel")
end
local localChannel = tonumber(data.get("channel", "channel"))

if data.get("output", "output") == nil then
	io.write(dictionary[localLang]["name_of_output_chest"])
	data.set("output", io.read(), "output")
end

if data.get("crafting", "crafting") == nil then
	io.write(dictionary[localLang]["name_of_crafting_dropper"])
	data.set("crafting", io.read(), "crafting")
end

local outputX = { chest = peripheral.wrap(tostring(data.get("output", "output"))), name = tostring(data.get("output", "output")) }
local craftingX = { chest = peripheral.wrap(tostring(data.get("crafting", "crafting"))), name = tostring(data.get("crafting", "crafting")) }

local chests = {}

local chestcount = 0

local allPeri = peripheral.getNames()

for _, peri in pairs(allPeri) do
	peripheral.wrap(peri)
end

local wirelessList = { peripheral.find("modem", function(name, modem)
	return modem.isWireless()
end) }

local wireless = nil

for _, wirelessP in pairs(wirelessList) do
	wireless = wirelessP
end

local modemList = { peripheral.find("modem", function(name, modem)
	return not modem.isWireless()
end) }

local modem = nil

for _, modemP in pairs(modemList) do
	modem = modemP
end


local taskQue = {}

local turtles = {}

local craftQue = {}

local craftMissions = {}

local itemsUsed = {}


local modems = {}
modem.open(localChannel)
modems["wired"] = modem
wireless.open(localChannel)
modems["wireless"] = wireless

local pingLimit = 10

if data.get("itemList", "itemList") == nil then
	data.set("itemList", nil, "itemList")
end
local itemsInited = false
local items = data.get("itemList", "itemList")

if items == nil then
	items = {}
else
	items = items:gsub("<", "[")
	items = items:gsub(">", "]")
	items = textutils.unserialize(items)
	itemsInited = true
end

local turtleTimer = os.startTimer(10)

function serverInit()
	local allP = peripheral.getNames()
	for pID, data in pairs(allP) do
		if data ~= outputX.name and data ~= "left" and data ~= "right" and data ~= "front" and data ~= "back" and data ~= "bottom" and data ~= "top" and data ~= craftingX.name then
			chests[#chests + 1] = { chest = peripheral.wrap(data), name = data }
		end
	end
	chestcount = #chests
end

serverInit()

function indexItems()
	print(dictionary[localLang]["start_counting_all_items"])
	for chestID, chest in pairs(chests) do
		if itemsInited == true then break end
		for i, stack in pairs(chest.chest.list()) do
			local para = chest.chest.list()
			if #para >= 1 then
				local data = stack
				local info = chest.chest.getItemDetail(i)
				if info == nil then break end
				if items[string.lower(info.displayName)] == nil then
					items[string.lower(info.displayName)] = { [chestID] = data.count }
				else
					if items[string.lower(info.displayName)][chestID] == nil then
						items[string.lower(info.displayName)][chestID] = data.count
					else
						items[string.lower(info.displayName)][chestID] = items[string.lower(info.displayName)][chestID] + data.count
					end
				end
			else
				break
			end
		end
	end
	itemsInited = true
	print(dictionary[localLang]["listed_all_items"])
	local itemsString = textutils.serialise(items)
	itemsString = itemsString:gsub("%[", "<")
	itemsString = itemsString:gsub("%]", ">")
	data.set("itemList", itemsString, "itemList")
	chestUpdates = {}
end

indexItems()

function getItemCount(name)
	local item = items[string.lower(name)]
	if item == nil then return 0 end
	local count = 0
	for chestID, itemCount in pairs(item) do
		count = count + itemCount
	end
	return count
end

function getItemPosition(name, count)
	local item = items[string.lower(name)]
	if item == nil then return end
	if name == " " or name == "" or name == nil then return end
	local positions = {}
	if count == 0 then
		count = 1
	end
	local remainder = count
	for chestID, itemCount in pairs(item) do
		remainder = remainder - itemCount
		positions[#positions + 1] = { name = chests[chestID].name, count = itemCount, id = chestID }
		if remainder <= 0 then
			return positions
		end
	end
	return positions
end

function getIdleTurtle()
	for id, turtle in pairs(turtles) do
		if turtle.status == "idle" then
			return turtle
		end
	end
	return nil
end

function statusUpdate(channel, turtle, previous, new)
	--print("Que:\n"..textutils.serialise(taskQue))
	event.handleCCEvents(0.05)
	if new == "idle" then
		turtle.task = nil
		if #taskQue == 0 then
			if #craftQue == 0 then return end
			indexItems()
			for i, queEntry in ipairs(craftQue) do
				if craftItem(queEntry.item, queEntry.count, true) == true then
					craftItem(queEntry.item, queEntry.count, nil, queEntry.final)
					craftQue[i] = nil
					for j = i + 1, #craftQue do
						craftQue[j - i] = craftQue[j]
					end
					craftQue[#craftQue] = nil
					return
				end
			end
			return
		end
		modems["wireless"].transmit(channel, localChannel, taskQue[1])
		turtle.task = taskQue[1]
		turtle.status = "working"
		for id, data in ipairs(taskQue) do
			taskQue[id - 1] = data
		end
		taskQue[0] = nil
		taskQue[#taskQue] = nil
	end
end

event.addHandler("onTurtleStatusChange", statusUpdate)

function turtleTimed(turtle, channel)
	local command = turtle.task
	if command == nil then return end
	local turtle = getIdleTurtle()
	if turtle == nil then
		taskQue[#taskQue + 1] = command
	else
		modems["wireless"].transmit(turtle.channel, localChannel, command)
		turtle.task = command
		turtle.status = "working"
	end
end

event.addHandler("onTurtleTimeout", turtleTimed)

function createRecipe(targetItem, recipeString)
	data.set(targetItem, recipeString)
end

function checkTurtleConnectionTimer(timer)
	if timer ~= turtleTimer then return end
	for channel, turtle in pairs(turtles) do
		if turtle.lastMessage < os.clock() - 20 then
			turtle.missed = turtle.missed + 1
			if turtle.missed > pingLimit then
				print("Turtle " .. channel .. " has timed out")
				event.trigger("onTurtleTimeout", turtle, channel)
				turtles[channel] = nil
				checkTurtleConnectionTimer(timer)
				break
			end
		else
			turtle.missed = 0
		end
	end
	--[[
	for channel,turtle in pairs(turtles) do
		if turtle.timer == timer then
			ping(channel)
			if turtle.pingTimer == nil then
				turtle.missed = 0
				turtle.pingTimer = os.startTimer(10)
			end
		elseif turtle.pingTimer == timer  and turtle.missed == pingLimit then
			--print("Turtle " .. channel .. " has timed out")
			event.trigger("onTurtleTimeout",turtle,channel)
			turtles[channel] = nil
			return
		elseif turtle.pingTimer == timer and turtle.missed then
			turtle.pingTimer = os.startTimer(10)
			turtle.missed = turtle.missed + 1
		end
	end
	]]
	turtleTimer = os.startTimer(10)
end

event.addHandler("timer", checkTurtleConnectionTimer)

function getSlots(itemx, count, id, validate)
	local itemss = chests[id].chest.list();
	local count = tonumber(count)
	local remainder = count
	local slots = {}
	for slot, item in pairs(itemss) do
		--print(item.all().display_name)
		local info = chests[id].chest.getItemDetail(slot)
		if string.lower(info.displayName) == string.lower(itemx) then
			local count = info.count
			if count > remainder then
				slots[#slots + 1] = slot
				print(slot)
				remainder = 0
			else
				slots[#slots + 1] = slot
				print(slot)
				remainder = remainder - count
			end
		end
		if remainder <= 0 then
			return slots
		end
	end
	if validate == "doIt" then
		return slots
	else
		return {}
	end
end

function pushto(slot, id, name, count, targetSlot, output, crafting, out, itemName)
	name = tostring(name)
	local adID = getIdByName(name)
	local pushed = 0
	if output == true then
		pushed = outputX.chest.pushItems(name, slot, count, targetSlot)
		if pushed > 0 then
			if items[string.lower(itemName)] == nil then
				items[string.lower(itemName)] = { [adID] = pushed }
			else
				if items[string.lower(itemName)][adID] == nil then
					items[string.lower(itemName)][adID] = pushed
				else
					items[string.lower(itemName)][adID] = items[string.lower(itemName)][adID] + pushed
				end
			end
		end
	elseif crafting == true then
		pushed = craftingX.chest.pushItems(name, slot, count, targetSlot)
		if pushed > 0 then
			if items[string.lower(itemName)] == nil then
				items[string.lower(itemName)] = { [adID] = pushed }
			else
				if items[string.lower(itemName)][adID] == nil then
					items[string.lower(itemName)][adID] = pushed
				else
					items[string.lower(itemName)][adID] = items[string.lower(itemName)][adID] + pushed
				end
			end
		end
	elseif out == true then
		pushed = chests[id].chest.pushItems(outputX.name, slot, count, targetSlot)
		if pushed > 0 then
			items[string.lower(itemName)][id] = items[string.lower(itemName)][id] - pushed
			if items[string.lower(itemName)][id] <= 0 then
				if getItemCount(itemName) == 0 then items[string.lower(itemName)] = nil end
			end
		end
	else
		pushed = chests[id].chest.pushItems(craftingX.name, slot, count, targetSlot)
		if pushed > 0 then
			items[string.lower(itemName)][id] = items[string.lower(itemName)][id] - pushed
			if items[string.lower(itemName)][id] <= 0 then
				if getItemCount(itemName) == 0 then items[string.lower(itemName)] = nil end
			end
		end
	end
	return pushed
end

function getIdByName(name)
	for chestID, chest in pairs(chests) do
		if chest.name == name then
			return chestID
		end
	end
end

function craftItem(itemName, count, check, final)
	print(dictionary[localLang]["count"] .. ": " .. count)
	local recipe = tostring(data.get(itemName, "db/recipes"))
	if recipe == nil or recipe == "nil" then return false end
	local pattern = textutils.unserialize(parsePattern(recipe))
	local trueCount = math.ceil(count / pattern["#amount"])
	--local command = "craft|"..trueCount.."|"..textutils.serialize(pattern)
	if final == nil or final == false then
		--command = "innerCraft|"..trueCount.."|"..textutils.serialize(pattern)
	end
	print(itemName .. " : " .. count)

	local isPossible = false
	for itemId, item in pairs(pattern["#items"]) do
		local used = itemsUsed[item] or 0
		local trueItemCount = pattern[item].count * trueCount
		if (getItemCount(item) - used) >= trueItemCount then
			isPossible = true
			if itemsUsed[item] == nil then
				itemsUsed[item] = trueItemCount
			else
				itemsUsed[item] = itemsUsed[item] + trueItemCount
			end
		else
			if craftItem(item, trueItemCount, true, false) == true then
				isPossible = true
			else
				if check == true then
					print(dictionary[localLang]["item_not_found"])
				end
				return false
			end
		end
	end

	if isPossible == true then
		local counter = count
		while counter > 0 do
			if counter > 64 then
				craftMissions[#craftMissions + 1] = { itemName = itemName, count = 64, final = final }
				counter = counter - 64
			else
				craftMissions[#craftMissions + 1] = { itemName = itemName, count = counter, final = final }
				counter = 0
			end
		end
		if final == true then
			local turtle = getIdleTurtle()
			if turtle == nil then
				print(dictionary[localLang]["no_turtle_idle"])
				craftMissions = {}
				return false
			else
				pushToCraft()
			end
		end
		return true
	end
	print(dictionary[localLang]["request_not_possible"])
	return false
end

function pushToCraft()
	if #craftMissions >= 1 then
		print(dictionary[localLang]["start_crafting"])
		local mission = craftMissions[1]
		local recipe = tostring(data.get(mission.itemName, "db/recipes"))
		if recipe == nil or recipe == "nil" then return false end
		local pattern = textutils.unserialize(parsePattern(recipe))
		local trueCount = math.ceil(mission.count / pattern["#amount"])
		for itemID, item in pairs(pattern["#items"]) do
			local itemCount = pattern[item].count
			local itemCount = itemCount * trueCount
			local positions = getItemPosition(item, itemCount)
			if item ~= nil and positions ~= nil then
				local remainder = itemCount
				for chestID, data in pairs(positions) do
					local count = data.count
					local myslots = getSlots(item, count, data.id, "doIt")
					print(textutils.serialize(myslots))
					for slotID, slot in pairs(myslots) do
						local counterC = chests[data.id].chest.getItemDetail(slot).count
						if counterC > remainder then counterC = remainder end
						print("counterC : " .. counterC)
						local debug = pushto(slot, data.id, data.name, counterC, nil, false, false, false, item)
						remainder = remainder - counterC
					end

				end
			end
		end
		local command = "craft|" .. trueCount .. "|" .. textutils.serialize(pattern)
		if mission.final == nil or mission.final == false then
			command = "innerCraft|" .. trueCount .. "|" .. textutils.serialize(pattern)
		end
		local turtle = getIdleTurtle()
		if turtle == nil then return print(dictionary[localLang]["no_turtle_idle"]) end
		modems["wireless"].transmit(turtle.channel, localChannel, command)
		turtle.task = command
		turtle.status = "working"
		table.remove(craftMissions, 1)
	else
		print(dictionary[localLang]["crafting_finished"])
		return true
	end
end

function parsePattern(recipe)
	local patternCount = tonumber(utils.split(recipe, "|", 2))
	local trueRecipe = tostring(utils.split(recipe, "|", 1))
	local itemsData = {}
	local id = 1
	for i = 1, 9 do
		local item = tostring(utils.split(trueRecipe, ";", i))
		if item ~= nil and item ~= " " and item ~= "" then
			if itemsData[item] == nil then
				itemsData[item] = { count = 1, id = id }
				id = id + 1
				if itemsData["#items"] == nil then
					itemsData["#items"] = { item }
				else
					itemsData["#items"][#itemsData["#items"] + 1] = item
				end
			else
				itemsData[item].count = itemsData[item].count + 1
			end
			if itemsData["#pattern"] == nil then
				itemsData["#pattern"] = {}
			end
			itemsData["#pattern"][#itemsData["#pattern"] + 1] = itemsData[item].id
		else
			if itemsData["#pattern"] == nil then
				itemsData["#pattern"] = {}
			end
			itemsData["#pattern"][#itemsData["#pattern"] + 1] = "X"
		end
	end
	itemsData["#amount"] = patternCount

	return textutils.serialise(itemsData)
end

function sendToStorage(output)
	if output == true then
		for slot, item in pairs(outputX.chest.list()) do
			print(item)
			if item ~= nil then
				local info = outputX.chest.getItemDetail(slot)
				print(info.displayName)
				if info ~= nil then
					local itemCount = info.count
					for i = 1, chestcount do
						local pushed = pushto(slot, nil, chests[i].name, itemCount, nil, true, false, false, string.lower(info.displayName))
						itemCount = itemCount - pushed
						if itemCount <= 0 then break end
					end

				end
			end
		end
	else
		for slot, item in pairs(craftingX.chest.list()) do
			if item ~= nil then
				local info = craftingX.chest.getItemDetail(slot)
				if info ~= nil then
					local itemCount = info.count
					for i = 1, chestcount do
						local pushed = pushto(slot, nil, chests[i].name, itemCount, nil, false, true, false, string.lower(info.displayName))
						itemCount = itemCount - pushed
						if itemCount <= 0 then break end
					end
				end
			end
		end
	end

end

function ping(channel)
	modems.wireless.transmit(channel, localChannel, "ping")
end

local messageHandles = {
	["ping"] = function(replyChannel, message)
		if turtles[replyChannel] == nil then return end
		event.trigger("onPing", replyChannel)
		return "pong"
	end,

	["pong"] = function(replyChannel, message)
		if turtles[replyChannel] == nil then return end
		event.trigger("onPong", replyChannel)
	end,

	["getItemCount"] = function(replyChannel, message)
		local itemName = utils.split(message, "|", 2)
		return "returnItemCount|" .. getItemCount(itemName)
	end,

	["requestItemList"] = function(replyChannel, message)
		local itemString = ""
		for itemname, chests in pairs(items) do
			itemString = itemString .. itemname .. ":" .. getItemCount(itemname) .. ";"
		end
		return "returnItemList|" .. itemString
	end,

	["requestTurtles"] = function(replyChannel, message)
		local turtleString = ""
		for channel, turtle in pairs(turtles) do
			turtleString = turtleString .. channel .. "," .. turtle.status .. "," .. tostring(turtle.task) .. ";"
		end
		return "returnTurtles|" .. turtleString
	end,

	["requestQue"] = function(replyChannel, message)
		local queString = ""
		for _, queCommand in pairs(taskQue) do
			queString = queString .. string.gsub(queCommand, "|", ";") .. "|"
		end
		return "returnQue|" .. queString
	end,

	["requestItem"] = function(replyChannel, message)
		local itemName = utils.split(message, "|", 2)
		local count = tonumber(utils.split(message, "|", 3))
		print(dictionary[localLang]["item_request"] .. itemName .. "x" .. count)
		local positions = getItemPosition(itemName, count)
		local remainder = count
		if positions == nil then return end
		for chestID, data in pairs(positions) do
			----print(chestID)
			local count = data.count
			if count > remainder then
				count = remainder
			end

			local myslots = getSlots(itemName, count, data.id)

			for slotID, slot in pairs(myslots) do
				local pushed = pushto(slot, data.id, data.name, remainder, nil, false, false, true, string.lower(itemName))
				remainder = remainder - pushed
			end

			if remainder <= 0 then
				indexItems()
				return
			end
		end
		indexItems()
	end,

	["addRecipe"] = function(replyChannel, message)
		local item = utils.split(message, "|", 2)
		local recipe = utils.split(message, "|", 3)
		local patternCount = utils.split(message, "|", 4)
		recipe = recipe .. "|" .. patternCount
		data.set(item, recipe, "db/recipes")
		print(dictionary[localLang]["adding_recipe"] .. item .. "-" .. recipe)
		indexItems()
	end,

	["requestRecipes"] = function(replyChannel, message)
		local returnString = "returnRecipes|"
		for id, _ in pairs(data.getAll("db/recipes")) do
			returnString = returnString .. id .. ";"
		end
		return returnString
	end,

	["requestCraft"] = function(replyChannel, message)
		local itemName = utils.split(message, "|", 2)
		local count = tonumber(utils.split(message, "|", 3))
		itemsUsed = {}
		craftMissions = {}
		craftItem(itemName, count, nil, true)
	end,

	["sendToTurtles"] = function(replyChannel, message)
		local turtleChannel = utils.split(message, "|", 2)
		local message = utils.split(message, "|", 3)
		local turtle = turtles[replyChannel]
		turtle.task = message
		turtle.status = "working"

	end,

	["indexItems"] = function(replyChannel, message)
		indexItems()
		return "confirmed"
	end,

	["assign"] = function(replyChannel, message)
		local trueChannel = tonumber(utils.split(message, "|", 2))
		if turtles[replyChannel] == nil and trueChannel == localChannel then
			turtles[replyChannel] = {
				channel = replyChannel,
				status = "idle",
				lastMessage = os.clock()
			}
			print(dictionary[localLang]["connected"] .. trueChannel .. " : " .. replyChannel)
			event.trigger("onTurtleAssign", replyChannel, turtles[replyChannel], "confirmed")
			event.trigger("onTurtleStatusChange", replyChannel, turtles[replyChannel], false, "idle")
			return "confirmed"
		else
			print(dictionary[localLang]["turtle_connection_denied"])
			event.trigger("onTurtleAssign", replyChannel, turtles[replyChannel], "denied")
			return "denied"
		end
	end,

	["status"] = function(replyChannel, message)
		if turtles[replyChannel] == nil then
			return "denied"
		end
		local previous = turtles[replyChannel].status
		local status = utils.split(message, "|", 2)
		turtles[replyChannel].status = status
		event.trigger("onTurtleStatusChange", replyChannel, turtles[replyChannel], previous, status)
	end,

	["toStorage"] = function(replyChannel, message)
		sendToStorage(true)
		indexItems()
	end,

	["sendBack"] = function(replyChannel, message)
		sendToStorage(false)
		active = false
		indexItems()
		if turtles[replyChannel] == nil then
			return "denied"
		end
		local previous = turtles[replyChannel].status
		local status = "idle"
		turtles[replyChannel].status = status
		event.trigger("onTurtleStatusChange", replyChannel, turtles[replyChannel], previous, status)
		pushToCraft()
	end,

	["readRecipe"] = function(replyChannel, message)
		local message = ""
		for slot = 1, 9 do
			if craftingX.chest.getItemDetail(slot) ~= nil then
				message = message .. craftingX.chest.getItemDetail(slot).displayName .. ";"
			else
				message = message .. " ;"
			end
		end
		return "returnPatternT|" .. message
	end,

	["returnPatternS"] = function(replyChannel, message)
		local pattern = utils.split(message, "|", 2)
		local command = "returnPattern|" .. pattern
		local turtle = getIdleTurtle()
		modems["wireless"].transmit(turtle.channel, localChannel, command)
	end,

	["craftingCheckFinish"] = function(replyChannel, message)
		if #craftingX.chest.list() == 1 then
			for i, stack in pairs(craftingX.chest.list()) do
				local targetName = craftingX.chest.getItemDetail(i).displayName
				if craftingX.chest.getItemDetail(i).displayName ~= nil then
					local PatternCount = craftingX.chest.getItemDetail(i).count
					sendToStorage(false)
					local command = "PatternTrue|" .. targetName .. "|" .. PatternCount
					modems["wireless"].transmit(localChannel, localChannel, command)
				end
			end
		else
			sendToStorage(false)
			modems["wireless"].transmit(localChannel, localChannel, "PatternFalse|")
		end
	end,

	["reload"] = function(replyChannel, message)
		items = {}
		itemsInited = false
		indexItems()
	end,

}

function handleMessages(side, channel, replyChannel, message)
	--print(replyChannel.." : "..message)
	if turtles[replyChannel] ~= nil then
		turtles[replyChannel].lastMessage = os.clock()
	end
	local messageType = utils.split(message, "|", 1)
	if messageHandles[messageType] == nil then return end
	local returnMessage = messageHandles[messageType](replyChannel, message)
	event.handleCCEvents(0.10)
	if returnMessage == nil then return end
	--print(replyChannel .. " : " .. returnMessage)
	modems["wireless"].transmit(replyChannel, localChannel, returnMessage)
end

event.addHandler("modem_message", handleMessages)

while true do
	event.handleCCEvents()
end

print(dictionary[localLang]["ended_gracefully"])
