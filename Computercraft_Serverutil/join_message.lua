--Initialisation--
local chat = peripheral.find("chat_box")
if not chat then error("Chatbox not found") end

local playerD = peripheral.find("player_detector")
if not playerD then error("player Detector not found") end


--Util--
local function generateMessage(player)
	local joinMessage = {
		{text = "Welcome back " ..player.. ".\n"},
		{text = "On this Server we have  varius commands every player can access\n"},
		{text = "This is made possible using Computercraft and Advanced Peripherals\n"},
		{text = "U can find a list of all currently available and planned commands as well as instructions on how to implement this in your world "},
		{
			text = "here",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "open_url",
				value = "https://github.com/DeadlyBraincell/Computercraft_Weather_Master/tree/main"
			}
		},
		{".\n"},
		{text = "U can also add suggestions on what commands i should implement next"}
	}
	return textutils.serialiseJSON(joinMessage)
end



--Main--

local function main()
	while true do
		local event, username, dimension = os.pullEvent("playerJoin")
		if event then
			local message = generateMessage(username)
			chat.sendFormattedMessageToPlayer(message, username, "&4&lJoin message", "[]", "&4&l")
		end
	end
end

main()