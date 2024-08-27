pin = 1 -- 1wire
attempts = 437 -- Looking for device attemps times every 0.5 s
timing = 5000 -- Delay before next code research
gpio.mode(pin,gpio.INT)
ow.setup(pin)

-- Search for 1-wire devices

function search()
	local flag = false
	searchtimer:interval(500)
	ow.reset_search(pin)
	count = 1
	repeat  
		addr = ow.search(pin)
		count = count + 1 
		if(addr ~= nil) then     
			searchtimer:stop()							
			local crc = ow.crc8(string.sub(addr,1,7))
			if crc == addr:byte(8) then                   
				if (addr:byte(1) == 0x01) then
					print("Device is enabled.") 
					flag = true            
					code = ''
					for i=7,3,-1 do
						local byte = tonumber(addr:byte(i))
						if  byte~=255 then                               
							if (tonumber(bit.rshift(byte, 4))>9) then
								code = code..bit.clear(byte,4,5,6,7)
							else                   
								code = code..bit.clear(byte,4,5,6,7)..bit.rshift(byte, 4)
							end                                                                        
						end
					end    					
				end
				searchtimer:interval(timing)
			end      			
			-- Do something 
		end
		tmr.wdclr()  
	until(count > attempts or flag)
	print(code)
	return code
end

searchtimer = tmr.create()
searchtimer:register(500, tmr.ALARM_AUTO, search)    
searchtimer:start() 
