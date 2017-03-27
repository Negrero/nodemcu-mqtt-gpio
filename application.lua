-- file : application.lua
local module = {}  
m = nil

-- Sends a simple ping to the broker
local function send_ping()  
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID .. "/gpioXX",0,function(conn)        
        print(config.ENDPOINT .. config.ID .. "/gpioXX")
        print("Successfully subscribed to data endpoint")
    end)
    m:subscribe(config.ENDPOINT .. config.ID .. "/status",0,function(conn)        
        print(config.ENDPOINT .. config.ID .."/status")
        print("Successfully subscribed to data endpoint")
    end)
end

local function status() 
    print("start status .....")
    a = "["
    for i = 1, 4 do
        a = a..gpio.read(i)       
        if i ~= 4 then
            a = a..","
        end
    end 
    a =a.."]"
    print(a)
    m:publish(config.ENDPOINT .. config.ID .. "/init",a,0,0)    
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    for i=1, 4 do
      gpio.mode(i, gpio.INT)       
    end     
    m:on("message", function(conn, topic, data)
             
      if data ~= nil then
         print(topic) 
         if topic == "nodemcu/134494/status" then
                                                         
          else
          
            motor = cjson.decode(data)            
            print(topic .. ": " .. data)      
            if motor.status == "start" then
                gpio.write(motor.pin,gpio.HIGH)                
                print("start")
            end
            if motor.status == "stop" then
                gpio.write(motor.pin,gpio.LOW)                
                print("stop")
            end
            if motor.pin == 0 then
                --analog = adc.read(0)
                print(analog)
                pin = 0
                status, temp, humi, temp_dec, humi_dec = dht.read(pin)
                if status == dht.OK then
                    -- Integer firmware using this example
                    print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
                          math.floor(temp),
                          temp_dec,
                          math.floor(humi),
                          humi_dec
                    ))
                
                    -- Float firmware using this example
                    print("DHT Temperature:"..temp..";".."Humidity:"..humi)
                
                elseif status == dht.ERROR_CHECKSUM then
                    print( "DHT Checksum error." )
                elseif status == dht.ERROR_TIMEOUT then
                    print( "DHT timed out." )
                end
            end        
        -- do something, we have received a message
          end
      --status()
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con)     
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 

end

function module.start()  
  print("Start  .....................")  
  mqtt_start()
end

return module  
