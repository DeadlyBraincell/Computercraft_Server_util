local root = "https://raw.githubusercontent.com/DeadlyBraincell/Computercraft_Server_util/main/"

shell.run("wget "..root.."startup.lua")
shell.run("cd Computercraft_Serverutil")
shell.run("wget "..root.."Computercraft_Serverutil/join_message.lua")
shell.run("wget "..root.."Computercraft_Serverutil/weather_controller.lua")
shell.run("cd ..")