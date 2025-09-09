--Initialise Peripherals
local mon = peripheral.find("monitor")
if not mon then error("Monitor not found") end
mon.setTextScale(0.5)
mon.clear()
mon.setCursorPos(1, 1)

local chat = peripheral.find("chat_box")
if not chat then error("Chatbox not found") end


--Config
local logFolder = "logs"
local doLog = true
local maxLogSize = 200*1024 -- 100 KB
local maxLogs = 10
local trigger = {
    "day",
    "night",
    "rain",
    "thunder",
    "clear",
}


--Logging
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

---sets Weather/Time
---@param state string
---@param as string
local function setState(state, as)
    if state == "day" then
        rs.setBundledOutput("back", colors.yellow)
        printLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "night" then
        rs.setBundledOutput("back", colors.black)
        printLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Time to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "rain" then
        rs.setBundledOutput("back", colors.cyan)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "thunder" then
        rs.setBundledOutput("back", colors.blue)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    elseif state == "clear" then
        rs.setBundledOutput("back", colors.white)
        printLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
        logLine(as.. " changed Weather to " ..state.. " at " ..os.time("utc").. " UTC on day " ..os.day("ingame"))
    end
    os.sleep(0.5)
    rs.setBundledOutput("back", colors.green)
end

---looks for accepted command
---@param tab table
---@return boolean
local function findCommand(tab)
    for i, t in pairs(trigger) do
        if tab[2] == t then
            return true
        end
    end
    return false
end

---looks for accepted command format
---@param text string
---@return boolean
---@return string
local function findTrigger(text)
    local words = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(words, word)
    end
    if words[1] == "set" and findCommand(words) and #words == 2 then
        return true, words[2]
    end
    return false
end

local function main()
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        local active, command = findTrigger(message)
        if event and active then
            chat.sendMessageToPlayer("Your command has been recieved and will be processed shortly", username, "&4&lGod of Weather", "[]","&4&l")
            setState(command, username)
        end
        os.sleep(1)
    end
end

cleanupOldLogs()
main()