if fs.exists("event") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/event.lua event") end
local event = require("event")

if fs.exists("utils") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/utils.lua utils") end
local utils = require("utils")

if fs.exists("data") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/data.lua data") end
local data = require("data")

if fs.exists("button") == false then shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Librarys/main/button.lua button") end
local button = require("button")

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
	shell.run("wget https://raw.githubusercontent.com/Terandox-The-Pineapple/TRX-Storage/main/Handheld.lua startup")
	shell.run("reboot")
	print("Updated Storage-System")
else
	print("No Updates")
end

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

button.setMonitor(term)
--button.setTextColor(colors.green)

if data.get("channel", "channel") == nil then
	io.write(dictionary[localLang]["server_channel"])
	data.set("channel", io.read(), "channel")
end
local localChannel = tonumber(data.get("channel", "channel"))
local targetChannel = tonumber(data.get("channel", "channel"))

local previous = os.clock()
local modem = peripheral.wrap("back")
local ping
local itemlist = {}
local recipes = {}
local cachedItems = {}
local cachedRecipes = {}
local searchScroll = 0
local searchQuery = ""
local requestCount = ""
local requestItemString = ""
local requestCountString = ""
local craftRecipeString = ""
local recipeSearchString = ""
local itemCount
local turtles = {}
local que = {}
local currentRecipe = {}
local currentPattern = {}
local currentPatternString = ""
modem.open(localChannel)

local screens = {
	home = {},
	search = {},
	getCount = {},
	request = {},
	turtles = {},
	que = {},
	requestItem = {},
	craft = {},
	recipes = {},
}

screens.update = button.addButton(1, 20, 26, 1, dictionary[localLang]["send_to_storage"], false, false)
screens.homeButton = button.addButton(1, 2, 26, 1, dictionary[localLang]["home_menu"], false, false)

screens.home.search = button.addButton(2, 5, 11, 1, dictionary[localLang]["search"], false, false)
screens.home.getCount = button.addButton(15, 5, 11, 1, dictionary[localLang]["get_count"], false, false)
screens.home.request = button.addButton(2, 7, 11, 1, dictionary[localLang]["request"], false, false)
screens.home.turtles = button.addButton(15, 7, 11, 1, dictionary[localLang]["turtles"], false, false)
screens.home.que = button.addButton(2, 9, 11, 1, dictionary[localLang]["view_que"], false, false)
screens.home.ping = button.addButton(15, 9, 11, 1, dictionary[localLang]["ping"], false, false)
screens.home.craft = button.addButton(2, 11, 11, 1, dictionary[localLang]["craft"], false, false)
screens.home.addRecipe = button.addButton(15, 11, 11, 1, dictionary[localLang]["new_recipes"], false, false)
screens.home.reload = button.addButton(2, 13, 11, 1, dictionary[localLang]["reload"], false, false)

screens.recipes.newRecipe = button.addButton(4, 18, 21, 1, dictionary[localLang]["add_recipe"], false, false)

screens.request.request = button.addButton(2, 10, 24, 1, dictionary[localLang]["request"], false, false)

screens.requestItem.request = button.addButton(2, 10, 24, 1, dictionary[localLang]["request"], false, false)

screens.getCount.request = button.addButton(2, 10, 24, 1, dictionary[localLang]["request"], false, false)

local currentScreen = screens.home

term.setCursorPos(2, 10)
term.setBackgroundColor(colors.black)

function drawReadBox(title)
	term.setBackgroundColor(colors.green)
	term.setCursorPos(1, 11)
	term.write(title .. "                                   ")
	term.setCursorPos(1, 12)
	term.write(" ")
	term.setBackgroundColor(colors.white)
	term.write("                        ")
	term.setBackgroundColor(colors.green)
	term.write(" ")
	term.setBackgroundColor(colors.green)
	term.setCursorPos(1, 13)
	term.write("                           ")
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	term.setCursorPos(2, 12)
end

local buttonFunctions = {
	[screens.homeButton] = function()
		currentScreen = screens.home
	end,

	[screens.update] = function()
		modem.transmit(targetChannel, localChannel, "toStorage")
	end,

	[screens.home.ping] = function()
		previous = os.clock()
		modem.transmit(targetChannel, localChannel, "ping")
	end,

	[screens.home.search] = function()
		currentScreen = screens.search
		modem.transmit(targetChannel, localChannel, "requestItemList")
		searchQuery = ""
	end,

	[screens.home.request] = function()
		requestItemString = ""
		currentScreen = screens.request
	end,

	[screens.home.getCount] = function()
		requestCountString = ""
		currentScreen = screens.getCount
	end,

	[screens.home.turtles] = function()
		currentScreen = screens.turtles
		modem.transmit(targetChannel, localChannel, "requestTurtles")
		local tEvent, side, channel, replyChannel, message = os.pullEvent("modem_message")
		event.trigger(tEvent, side, channel, replyChannel, message)
	end,

	[screens.home.que] = function()
		currentScreen = screens.que
		modem.transmit(targetChannel, localChannel, "requestQue")
		local tEvent, side, channel, replyChannel, message = os.pullEvent("modem_message")
		event.trigger(tEvent, side, channel, replyChannel, message)
	end,

	[screens.home.craft] = function()
		currentScreen = screens.craft
		recipeSearchString = ""
		searchScroll = 10000
		modem.transmit(targetChannel, localChannel, "requestRecipes")
		local tEvent, side, channel, replyChannel, message = os.pullEvent("modem_message")
		event.trigger(tEvent, side, channel, replyChannel, message)
	end,

	[screens.home.addRecipe] = function()
		currentScreen = screens.recipes
		currentRecipe = {}
		currentPattern = {}
		modem.transmit(targetChannel, localChannel, "readRecipe")
	end,

	[screens.request.request] = function()
		requestCount = ""
		currentScreen = screens.requestItem
	end,

	[screens.requestItem.request] = function()
		local count = tonumber(requestCount)
		if type(count) ~= "number" or count == 0 then
			return
		end
		local message = "requestItem|" .. tostring(requestItemString) .. "|" .. tostring(count)
		currentScreen = screens.home
		modem.transmit(targetChannel, localChannel, message)
	end,

	[screens.getCount.request] = function()
		local message = "getItemCount|" .. tostring(requestCountString)
		modem.transmit(targetChannel, localChannel, message)
		local tEvent, side, channel, replyChannel, message = os.pullEvent("modem_message")
		event.trigger(tEvent, side, channel, replyChannel, message)
		requestCountString = ""
		onChar("")
	end,

	[screens.home.reload] = function()
		local message = "reload"
		currentScreen = screens.home
		modem.transmit(targetChannel, localChannel, message)
	end,

}

function handleClicks(buttonID)
	if buttonFunctions[buttonID] == nil then return end
	buttonFunctions[buttonID]()
end

event.addHandler("onButtonClick", handleClicks)

function onChar(letter)
	if string.len(letter) > 0 then
		local letter = string.lower(letter)
	end
	if currentScreen == screens.search then
		searchQuery = searchQuery .. letter
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.black)
		if string.len(searchQuery) >= 23 then
			term.write(string.sub(searchQuery, string.len(searchQuery) - 22, string.len(searchQuery)))
		else
			term.write(searchQuery)
			for i = string.len(searchQuery), 23 do
				term.write(" ")
			end
		end
		cachedItems = {}
		for name, count in pairs(itemlist) do
			if string.len(searchQuery) == 0 or string.match(name, searchQuery) ~= nil then
				cachedItems[#cachedItems + 1] = { name = name, count = count }
			end
		end
		searchScroll = 0
		drawSearch(true)
	elseif currentScreen == screens.requestItem then
		requestCount = requestCount .. letter
		term.setCursorPos(2, 6)
		term.setTextColor(colors.black)
		if string.len(requestCount) >= 4 then
			term.write(string.sub(requestCount, string.len(requestCount) - 4, string.len(requestCount)))
		else
			term.write(requestCount)
			for i = string.len(requestCount), 4 do
				term.write(" ")
			end
		end
	elseif currentScreen == screens.request then
		requestItemString = requestItemString .. letter
		term.setCursorPos(2, 6)
		term.setTextColor(colors.black)
		if string.len(requestItemString) >= 23 then
			term.write(string.sub(requestItemString, string.len(requestItemString) - 22, string.len(requestItemString)))
		else
			term.write(requestItemString)
			for i = string.len(requestItemString), 23 do
				term.write(" ")
			end
		end
	elseif currentScreen == screens.getCount then
		requestCountString = requestCountString .. letter
		term.setCursorPos(2, 6)
		term.setTextColor(colors.black)
		if string.len(requestCountString) >= 23 then
			term.write(string.sub(requestCountString, string.len(requestCountString) - 22, string.len(requestCountString)))
		else
			term.write(requestCountString)
			for i = string.len(requestCountString), 23 do
				term.write(" ")
			end
		end
	elseif currentScreen == screens.craft then
		searchScroll = 0
		recipeSearchString = recipeSearchString .. letter
		term.setCursorPos(2, 6)
		term.setTextColor(colors.black)
		term.setBackgroundColor(colors.white)
		if string.len(recipeSearchString) >= 23 then
			term.write(string.sub(recipeSearchString, string.len(recipeSearchString) - 22, string.len(recipeSearchString)))
		else
			term.write(recipeSearchString)
			for i = string.len(recipeSearchString), 23 do
				term.write(" ")
			end
		end
		cachedRecipes = {}
		for _, name in pairs(recipes) do
			if string.len(recipeSearchString) == 0 or string.match(name, recipeSearchString) ~= nil then
				cachedRecipes[#cachedRecipes + 1] = name
			end
		end
		drawCraft(true)
	end
end

event.addHandler("char", onChar)

function showList()
	if currentScreen == screens.search then
		cachedItems = {}
		for name, count in pairs(itemlist) do
			if string.len(searchQuery) == 0 or string.match(name, searchQuery) ~= nil then
				cachedItems[#cachedItems + 1] = { name = name, count = count }
			end
		end
		searchScroll = 0
		drawSearch(true)
	end
end

function onKey(key)
	if currentScreen == screens.search then
		if key == 259 then -- backspace
			searchQuery = string.sub(searchQuery, 1, string.len(searchQuery) - 1)
			onChar("")
		elseif key == 257 then
			cachedItems = {}
			for name, count in pairs(itemlist) do
				if string.len(searchQuery) == 0 or string.match(name, searchQuery) ~= nil then
					cachedItems[#cachedItems + 1] = { name = name, count = count }
				end
			end
			searchScroll = 0
			drawSearch(true)
		end
	elseif currentScreen == screens.requestItem then
		if key == 259 then -- backspace
			requestCount = string.sub(requestCount, 1, string.len(requestCount) - 1)
			onChar("")
		elseif key == 257 then
			buttonFunctions[screens.requestItem.request]()
			button.drawAllButtons()
		end
	elseif currentScreen == screens.request then
		if key == 259 then -- backspace
			requestItemString = string.sub(requestItemString, 1, string.len(requestItemString) - 1)
			onChar("")
		elseif key == 257 then
			buttonFunctions[screens.request.request]()
			button.drawAllButtons()
		end
	elseif currentScreen == screens.getCount then
		if key == 259 then -- backspace
			requestCountString = string.sub(requestCountString, 1, string.len(requestCountString) - 1)
			onChar("")
		elseif key == 257 then
			buttonFunctions[screens.getCount.request]()
			button.drawAllButtons()
		end
	elseif currentScreen == screens.craft then
		if key == 259 then -- backspace
			recipeSearchString = string.sub(recipeSearchString, 1, string.len(recipeSearchString) - 1)
			onChar("")
		end
	end
end

event.addHandler("key", onKey)

local drawFunctions = {
	[screens.search] = function(fromChar)
		term.setCursorPos(2, 5)
		term.setBackgroundColor(colors.black)
		term.write(dictionary[localLang]["search"] .. ":")
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.write(searchQuery)
		for i = 1, 24 - string.len(searchQuery) do
			term.write(" ")
		end
		--term.setBackgroundColor(colors.white)
		--term.write("                        ")
		term.setCursorPos(2, 6)
		if fromChar == nil then
			--onChar("")
		end
		term.setTextColor(colors.yellow)
		for i = 1, 10 do
			local id = i + searchScroll
			local item = cachedItems[id]
			if item == nil then
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1, 8 + i)
				term.write("                          ")
			else
				term.setCursorPos(1, 8 + i)
				if math.floor(i / 2) == math.ceil(i / 2) then
					term.setBackgroundColor(colors.gray)
				else
					term.setBackgroundColor(colors.lightGray)
				end
				local itemString = tostring(item.name) .. " x " .. tostring(item.count)
				term.write(itemString)
				for i = string.len(itemString), 25 do
					term.write(" ")
				end
			end
		end
	end,
	[screens.requestItem] = function()
		term.setCursorPos(2, 5)
		term.setBackgroundColor(colors.black)
		term.write(dictionary[localLang]["count"] .. ":")
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.write("     ")
		term.setCursorPos(2, 6)
		onChar("")
	end,
	[screens.request] = function()
		term.setCursorPos(2, 5)
		term.setBackgroundColor(colors.black)
		term.write(dictionary[localLang]["item_name"] .. ":")
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.write("                        ")
		term.setCursorPos(2, 6)
		onChar("")
	end,
	[screens.turtles] = function()
		term.setBackgroundColor(colors.black)
		term.setCursorPos(1, 4)
		term.write(dictionary[localLang]["turtles"] .. ":")
		for id, turtle in pairs(turtles) do
			term.setCursorPos(1, 5 + id * 2)
			if math.floor(id / 2) == math.ceil(id / 2) then
				term.setBackgroundColor(colors.gray)
			else
				term.setBackgroundColor(colors.lightGray)
			end
			term.setTextColor(colors.yellow)
			term.write("id: " .. turtle.id .. " " .. dictionary[localLang]["status"] .. ": " .. turtle.status)
			if turtle.task ~= "nil" then
				term.setCursorPos(1, 5 + id * 2 + 1)
				term.write(turtle.task)
			end
		end
	end,
	[screens.que] = function()
		term.setBackgroundColor(colors.black)
		term.setCursorPos(1, 4)
		term.write(dictionary[localLang]["que"] .. ":")
		for id, command in pairs(que) do
			term.setCursorPos(1, 5 + id)
			if math.floor(id / 2) == math.ceil(id / 2) then
				term.setBackgroundColor(colors.gray)
			else
				term.setBackgroundColor(colors.lightGray)
			end
			term.setTextColor(colors.yellow)
			if command ~= nil then
				term.write(command)
			end
		end
	end,
	[screens.getCount] = function()
		term.setCursorPos(2, 5)
		term.setBackgroundColor(colors.black)
		term.write(dictionary[localLang]["item_name"])
		term.setCursorPos(2, 8)
		term.write(dictionary[localLang]["result"] .. ": " .. tostring(itemCount))
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.write("                        ")
		term.setCursorPos(2, 6)
		onChar("")
	end,
	[screens.craft] = function()
		term.setCursorPos(2, 5)
		term.setBackgroundColor(colors.black)
		term.write(dictionary[localLang]["search_recipes"])
		term.setCursorPos(2, 6)
		term.setBackgroundColor(colors.white)
		term.write(recipeSearchString)
		for i = 1, 24 - string.len(recipeSearchString) do
			term.write(" ")
		end
		term.setCursorPos(2, 6)
		term.setTextColor(colors.yellow)
		for i = 1, 10 do
			local id = i + searchScroll
			local item = cachedRecipes[id]
			if item == nil then
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1, 8 + i)
				term.write("                          ")
			else
				term.setCursorPos(1, 8 + i)
				if i % 2 == 1 then
					term.setBackgroundColor(colors.gray)
				else
					term.setBackgroundColor(colors.lightGray)
				end
				local itemString = tostring(item)
				term.write(itemString)
				for i = string.len(itemString), 25 do
					term.write(" ")
				end
			end
		end
	end,
	[screens.recipes] = function()
		term.setCursorPos(2, 4)
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.write(dictionary[localLang]["create_recipe"])
		term.setCursorPos(2, 5)
		term.write("--------------------")
	end,
}

function onClick(mouseButton, x, y)
	if currentScreen == screens.search then
		if y > 8 and y < 20 then
			local item = cachedItems[y - 8 + searchScroll]
			if item == nil then return end
			requestItemString = item.name
			requestCount = ""
			currentScreen = screens.requestItem
			button.drawAllButtons()
		end
	elseif currentScreen == screens.craft then
		if y > 8 and y < 20 then
			local item = cachedRecipes[y - 8 + searchScroll]
			if item == nil then return end
			drawReadBox("Procedure count: ")
			local count = tonumber(read())
			if count == nil then return end
			local message = "requestCraft|" .. item .. "|" .. count
			currentScreen = screens.home
			button.drawAllButtons()
			modem.transmit(targetChannel, localChannel, message)
		end
	end
end

event.addHandler("mouse_click", onClick)

local messageHandles = {
	["ping"] = function(replyChannel, message)
		return "pong"
	end,
	["pong"] = drawPing,
	["returnItemList"] = function(replyChannel, message)
		itemlist = {}
		local items = utils.split(message, "|", 2)
		local i = 1
		while true do
			local item = utils.split(items, ";", i)
			if string.len(item) == 0 then
				break
			end
			local name = utils.split(item, ":", 1)
			local count = tonumber(utils.split(item, ":", 2))
			if name == nil or count == nil then
				break
			end
			itemlist[name] = count
			i = i + 1
		end
	end,
	["returnRecipes"] = function(replyChannel, message)
		recipes = {}
		local recipesString = utils.split(message, "|", 2)
		local i = 1
		while true do
			local recipe = utils.split(recipesString, ";", i)
			print(recipe)
			if string.len(recipe) == 0 then
				break
			end
			recipes[#recipes + 1] = recipe
			i = i + 1
		end
	end,
	["returnQue"] = function(_, message)
		que = {}
		local i = 1
		while true do
			local command = utils.split(message, "|", i + 1)
			if command == nil then
				break
			end
			que[#que + 1] = command
			i = i + 1
		end
		drawFunctions[currentScreen](false)
	end,
	["returnTurtles"] = function(_, message)
		turtles = {}
		local turtlesString = utils.split(message, "|", 2)
		local i = 1
		while true do
			local turtle = utils.split(turtlesString, ";", i)
			if turtle == nil or string.len(turtle) == 0 then
				break
			end
			local id = tostring(utils.split(turtle, ",", 1))
			local status = tostring(utils.split(turtle, ",", 2))
			local task = tostring(utils.split(turtle, ",", 3))
			if id == nil or status == nil then
				break
			end
			turtles[#turtles + 1] = { id = id, status = status, task = task }
			i = i + 1
		end
		drawFunctions[currentScreen](false)
	end,
	["returnItemCount"] = function(_, message)
		itemCount = utils.split(message, "|", 2)
		drawFunctions[currentScreen](false)
	end,
	["returnPatternT"] = function(_, message)
		local pattern = utils.split(message, "|", 2)
		currentPatternString = pattern
		for i = 1, 9 do
			local item = utils.split(pattern, ";", i)
			currentPattern[#currentPattern + 1] = item
		end
		return "returnPatternS|" .. pattern
	end,
	["PatternTrue"] = function(_, message)
		local recipeName = utils.split(message, "|", 2)
		local patterCount = utils.split(message, "|", 3)
		if currentScreen == screens.recipes then
			term.setCursorPos(2, 6)
			term.write(dictionary[localLang]["recipe_saved"])
		end
		return "addRecipe|" .. recipeName .. "|" .. currentPatternString .. "|" .. patterCount
	end,
	["PatternFalse"] = function(_, message)
		if currentScreen == screens.recipes then
			term.setCursorPos(2, 6)
			term.write(dictionary[localLang]["recipe_not_exist"])
		end
		return "indexItems"
	end,

}

function handleMessages(side, channel, replyChannel, message)
	if replyChannel == nil then return end
	local messageType = utils.split(message, "|", 1)
	if messageHandles[messageType] == nil then return end
	local returnMessage = messageHandles[messageType](replyChannel, message)
	if returnMessage == nil then return end
	modem.transmit(replyChannel, localChannel, returnMessage)
end

event.addHandler("modem_message", handleMessages)

function drawSearch(...)
	drawFunctions[screens.search](...)
end

function drawCraft(...)
	drawFunctions[screens.craft](...)
end

function drawPing()
	if previous ~= nil then
		ping = os.clock() - previous
		previous = nil
	end
	term.setCursorPos(1, 1)
	term.setBackgroundColor(256)
	--term.setTextColor(colors.green)
	term.write(ping .. "                                           ")
end

function drawOthers()
	for screenName, buttons in pairs(screens) do
		if type(buttons) ~= "number" then
			for name, buttonID in pairs(buttons) do
				if buttons == currentScreen then
					button.setVisible(buttonID, true)
				else
					button.setVisible(buttonID, false)
				end
			end
		end
	end
	button.drawAllButtons(true)
	drawPing()
	if drawFunctions[currentScreen] == nil then return end
	drawFunctions[currentScreen]()
end

event.addHandler("onButtonsDrawn", drawOthers)
drawOthers()

function scrolled(direction)
	if currentScreen == screens.search then
		searchScroll = searchScroll + direction
		drawSearch()
	elseif currentScreen == screens.craft then
		searchScroll = searchScroll + direction
		drawFunctions[screens.craft]()
	end
end

event.addHandler("mouse_scroll", scrolled)

while true do
	event.handleCCEvents()
end
