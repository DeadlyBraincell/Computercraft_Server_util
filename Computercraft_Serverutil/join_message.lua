--Initialisation--
local chat = peripheral.find("chat_box")
if not chat then error("Chatbox not found") end

local playerD = peripheral.find("player_detector")
if not playerD then error("player Detector not found") end


--Util--
local function generateMessage(player)
	local joinMessageCC = {
		{text = "\nWelcome back " ..player.. ".\n"},
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
		{text = "U can also add suggestions on what commands i should implement next"},
		{text = "Also here is a list of all server-side commands\n"},
	}
	local joinMessageServer = {
		{text = "\n"},
		{
			text = "/rtp",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "suggest_command",
				value = "/rtp"
			}
		},
		{text = ": randomly teleport yourself in the dimension you are currently in.\n"},
		{
			text = "/sethome",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "suggest_command",
				value = "/sethome"
			}
		},
		{text = ": set a home you can at all time teleport back using "},
		{
			text = "/home",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "suggest_command",
				value = "/home"
			}
		},
		{".\n"},
		{
			text = "/spawn",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "suggest_command",
				value = "/spawn"
			}
		},
		{text = ": teleports you to the world spawn.\n"},
		{
			text = "/warp",
			underlined = true,
			color = "red",
			clickEvent = {
				action = "suggest_command",
				value = "/warp"
			}
		},
		{text = ": lets you teleport yourself to a predefined warp point."}
	}
	return {textutils.serialiseJSON(joinMessageCC), textutils.serializeJSON(joinMessageServer)}
end



--Main--

local function main()
	while true do
		local event, username, dimension = os.pullEvent("playerJoin")
		if event then
			local messages = generateMessage(username)
			chat.sendFormattedMessageToPlayer(messages[1], username, "Join message", "[]", "&4&l")
			os.sleep(0.5)
			chat.sendFormattedMessageToPlayer(messages[2], username, "Server Commands", "[]", "&4&l")
		end
	end
end

main()