-- file : config.lua
local module = {}

module.SSID = {}  
module.SSID["Interwifi_Andres,,"] = "Carmona1"

module.HOST = "192.168.0.10"  
module.PORT = 1883 
module.ID = node.chipid()

module.ENDPOINT = "nodemcu/"  
return module 
