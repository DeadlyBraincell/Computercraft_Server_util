local root = "https://raw.githubusercontent.com/DeadlyBraincell/Computercraft_Server_util/main/"

shell.run("wget "..root.."startup.lua")
fs.makeDir("/Computercraft_Serverutil")
shell.run("cd Computercraft_Serverutil")
shell.run("wget "..root.."Computercraft_Serverutil/join_message.lua")
shell.run("wget "..root.."Computercraft_Serverutil/command_handler.lua")
shell.run("cd ..")
--wget https://raw.githubusercontent.com/DeadlyBraincell/Computercraft_Server_util/main/install.lua