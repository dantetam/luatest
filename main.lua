-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--display.newText("Hello World",100,100,native.systemFont,15)

local player = display.newRect(50,50,50,50)
local wP,aP,sP,dP = false
local projectiles = {}
local xSpeeds = {}
local ySpeeds = {}
local debounce = true
local frames = 0

function checkTime(event)
	if frames % 10 == 0 then debounce = true end
	frames = frames + 1
	local speed = 3
	if wP then player:translate(0,-speed) end
	if aP then player:translate(-speed,0) end
	if sP then player:translate(0,speed) end
	if dP then player:translate(speed,0) end
	for i = 1,table.getn(projectiles),1 do
		projectiles[i]:translate(xSpeeds[i],ySpeeds[i])
	end
	for i = table.getn(projectiles),1,-1 do
		if projectiles[i].x < 0 or projectiles[i].y < 0 or projectiles[i].x > display.contentWidth or projectiles[i].y > display.contentHeight then
			local p = projectiles[i]
			table.remove(projectiles, i)
			table.remove(xSpeeds, i)
			table.remove(ySpeeds, i)
			p:removeSelf()
			i = i - 1
		end
	end
end

function projectile(x,y,xSpeed,ySpeed)
	local p = display.newCircle(x,y,5)
	table.insert(projectiles, p)
	table.insert(xSpeeds, xSpeed)
	table.insert(ySpeeds, ySpeed)
end

function keyPressed(event)
	if event.phase == "down" then
		if event.keyName == "w" then wP = true
		elseif event.keyName == "a" then aP = true
		elseif event.keyName == "s" then sP = true
		elseif event.keyName == "d" then dP = true
		end
	elseif event.phase == "up" then
		if event.keyName == "w" then wP = false
		elseif event.keyName == "a" then aP = false
		elseif event.keyName == "s" then sP = false
		elseif event.keyName == "d" then dP = false
		end
	end
end

function mousePressed(event)
	if debounce then
		debounce = false
		if event.isPrimaryButtonDown then
			local deltaX = event.x - player.x
			local deltaY = event.y - player.y
			local angle = math.atan2(deltaY, deltaX)
			projectile(player.x, player.y, math.cos(angle)*5, math.sin(angle)*5)
		end
	end
end

Runtime:addEventListener("key", keyPressed)
Runtime:addEventListener("mouse", mousePressed)
timer.performWithDelay(1000/40, checkTime, 10000)