--Initialisation--
local mon = peripheral.find("monitor")
if not mon then error("Monitor not found") end
mon.setTextScale(0.5)
mon.clear()
mon.setCursorPos(1, 1)

local chat = peripheral.find("chat_box")
if not chat then error("Chatbox not found") end


--Config--

--log
local logFolder = "logs"
local doLog = true
local maxLogSize = 200*1024 -- 100 KB
local maxLogs = 10

--Commands
local argumens = {
    "day",
    "night",
    "rain",
    "thunder",
    "clear",
}
local triggers = {
	"time",
	"weather"
}

--Redstone
--Make sure to Check for any conflicts in the config
--Checks have not yet been implemented
--side = redstone output side
--col = bundled redstone color
local config = {
	weatherConfig = {
		rain = {
			side = "back",
			col = colors.cyan
		},
		thunder = {
			side = "back",
			col = colors.blue
		},
		clear = {
			side = "back",
			col = colors.white
		}
	},
	timeConfig = {
		night = {
			side = "back",
			col = colors.black
		},
		day = {
			side = "back",
			col = colors.yellow
		}
	},
	resetConfig = { --set to any combination not used yet
		reset = {
			side = "down",
			col = colors.green
		}
	}
}

--Util--

---checks if a side was already configured for that color
---returns true if conflict was found
---@param value table
---@param reference table
---@return boolean
local function isConflicting(value, reference)
	for k, v in pairs(reference) do
		if value.side == v.side and value.col == v.col then
			return true
		end
	end
	return false
end

---checks config for Conflicts
---@param c table
local function checkForConflicts(c)
	local ref = {}
	for i, type in pairs(c) do
		for set, config in pairs(c[i]) do
			if not isConflicting(config, ref) then
				table.insert(ref, config)
			else
				return true
			end
		end
	end
end

---Looks for given value in Table
---@param value any
---@param tab table
---@return boolean
function IsInTable(value, tab)
	for i = 1, #tab do
		if tab[i] == value then
			return true
		end
	end
	return false
end

---converts string into a table of words
---@param text string
---@return table
local function listWords(text)
	local words = {}
	for word in string.gmatch(text, "%S+") do
        table.insert(words, word)
    end
	return words
end

---looks if valid commnd-structure is present
---@param text string
---@return boolean
---@return table | nil
local function findCommand(text)
	local tab = listWords(text)
	if tab[2] == "set" and IsInTable(tab[1], triggers) and IsInTable(tab[3], argumens) then
		local command = {
			trigger = tab[1],
			state = tab[3]
		}
		return true, command
	else
		return false, nil
	end
end

local function validate(event, username, message, uuid, isHidden)
	if event == nil then
		error("Event is nil")
		print(tostring(event))
	elseif username == nil then
		error("username is nil")
		print(tostring(username))
	elseif message == nil then
		error("message is nil")
		print(tostring(message))
	elseif uuid == nil then
		error("uuid is nil")
		print(tostring(uuid))
	elseif isHidden == nil then
		error("isHidden is nil")
		print(tostring(isHidden))
	end
end

--Logging--
if not fs.exists(logFolder) then fs.makeDir(logFolder) end

local function getNextLogFile()
  local files = fs.list(logFolder)
  table.sort(files)

  local numbered = {}
  for _, f in ipairs(files) do
    local n = f:match("^log_(%d+)%.log$")
    if n then table.insert(numbered, tonumber(n)) end
  end

  table.sort(numbered)

  local nextIndex = (numbered[#numbered] or 0) + 1
  return string.format("%s/log_%03d.log", logFolder, nextIndex)
end

local function logLine(line)
  if not doLog then return end
  local files = fs.list(logFolder)
  table.sort(files)
  local path
  if #files > 0 then
    local latest = files[#files]
    path = logFolder .. "/" .. latest
    if fs.getSize(path) >= maxLogSize then
      path = getNextLogFile()
    end
  else
    path = getNextLogFile()
  end
  local timestamp = os.date("%H:%M:%S", os.epoch("local") / 1000)
  local f = fs.open(path, "a")
  if f then
    f.writeLine(string.format("[%s] %s", timestamp, line))
    f.close()
  end
end

local function cleanupOldLogs()
  local files = fs.list(logFolder)
  local logFiles = {}
  for _, f in ipairs(files) do
    if f:match("^log_%d+%.log$") then
      table.insert(logFiles, f)
    end
  end
  table.sort(logFiles)
  while #logFiles > maxLogs do
    fs.delete(logFolder .. "/" .. table.remove(logFiles, 1))
  end
end

local function printLine(line)
    local x, y = mon.getCursorPos()
    mon.write(line)
    mon.setCursorPos(x, y + 1)
end

local function sendFeedback(player,success, command)
	if success then
		chat.sendMessageToPlayer("Your command \""..command.."\" has been recieved and will be processed shortly.", player, "&4&lGod of Weather", "[]","&4&l")
	else
		local message = {
			{text = "Your command \""..command.."\" was not recognised. Please check for any mistakes. If you think that this is a mistake.\n"},
			{text = "If you think this is a bug please contact the developer "},
			{
				text = "here",
				underlined = true,
				color = "aqua",
				clickEvent = {
					action = "open_url",
					value = "https://github.com/DeadlyBraincell/Computercraft_Weather_Master/issues"
				}
			},
			{text = "."}
		}

		local json = textutils.serialiseJSON(message)
		chat.sendFormattedMessage(json, "&4&lGod of Weather", "[]", "&4&l")
	end
end

--Main Code--

---sets Weather to given state
---@param state string
---@param as string
local function setWeather(state, as)
	if state == "rain" then
	    rs.setBundledOutput(config.weatherConfig.rain.side, config.weatherConfig.rain.col)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "thunder" then
        rs.setBundledOutput(config.weatherConfig.thunder.side, config.weatherConfig.thunder.col)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "clear" then
        rs.setBundledOutput(config.weatherConfig.clear.side, config.weatherConfig.clear.col)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    end
end

---sets Time to given state
---@param state string
---@param as string
local function setTime(state, as)
	if state == "day" then
        rs.setBundledOutput(config.timeConfig.day.side, config.timeConfig.day.col)
        printLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "night" then
        rs.setBundledOutput(config.timeConfig.night.side, config.timeConfig.night.col)
        printLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
	end
end


local function main()
	if checkForConflicts(config) then
		error("conflicting Redstone config")
	end
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
		validate(event, username, message, uuid, isHidden)
        local isCommand, command = findCommand(message)
		if isHidden then
			sendFeedback(username, isCommand, message)
		end
        if isHidden and event and isCommand then
			if command.trigger == "weather" then
				setWeather(command.state, username)
			elseif command.trigger == "time" then
				setTime(command.state, username)
			end
			rs.setBundledOutput(config.resetConfig.reset.side, config.resetConfig.reset.col)
        end
        os.sleep(1)
    end
end

cleanupOldLogs()
main()