-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--display.newText("Hello World",100,100,native.systemFont,15)

local player = display.newRect(50,50,20,20)
local wP,aP,sP,dP = false

local projectiles = {}
local pSpeedsX = {}
local pSpeedsY = {}

local enemies = {}
local eSpeedsX = {}
local eSpeedsY = {}

local lastBullet = 0
local frames = 0

function checkTime(event)
	--if frames % 10 == 0 then debounce = true end
	--if system.getTimer() - lastBullet >= 1000 then player.fill = {0,255,0} else player.fill = {255,0,0} end
	frames = frames + 1
	local speed = 3
	if wP then player:translate(0,-speed) end
	if aP then player:translate(-speed,0) end
	if sP then player:translate(0,speed) end
	if dP then player:translate(speed,0) end
	for i = 1,table.getn(enemies),1 do
		if math.random() < 0.1 then
			eSpeedsX[i] = math.random()*5 - 2.5
			eSpeedsY[i] = math.random()*5 - 2.5
		end
		enemies[i]:translate(eSpeedsX[i],eSpeedsY[i])
		if enemies[i].x < 0 then
			enemies[i].x = 0
		elseif enemies[i].y < 0 then
			enemies[i].y = 0
		elseif enemies[i].x > display.contentWidth then
			enemies[i].x = display.contextWidth
		elseif enemies[i].y > display.contentHeight then
			enemies[i].y = display.contextHeightdssad
		end
	end
	for i = 1,table.getn(projectiles),1 do
		projectiles[i]:translate(pSpeedsX[i],pSpeedsY[i])
		pSpeedsX[i] = pSpeedsX[i]*1.07
		pSpeedsY[i] = pSpeedsY[i]*1.07
	end
	for i = table.getn(projectiles),1,-1 do
		if projectiles[i].x < 0 or projectiles[i].y < 0 or projectiles[i].x > display.contentWidth or projectiles[i].y > display.contentHeight then
			local p = projectiles[i]
			table.remove(projectiles, i)
			table.remove(pSpeedsX, i)
			table.remove(pSpeedsY, i)
			p:removeSelf()
			i = i - 1
		end
	end
end

function projectile(x,y,xSpeed,ySpeed)
	local p = display.newRect(x,y,2,10)
	--print(math.atan2(ySpeed,xSpeed))
	p:rotate(math.deg(math.atan2(ySpeed,xSpeed))+90)
	table.insert(projectiles, p)
	table.insert(pSpeedsX, xSpeed)
	table.insert(pSpeedsY, ySpeed)
	return p
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
	if event.isPrimaryButtonDown then
		if system.getTimer() - lastBullet >= 500 then
			lastBullet = system.getTimer()
			local deltaX = event.x - player.x
			local deltaY = event.y - player.y
			local angle = math.atan2(deltaY, deltaX)
			projectile(player.x, player.y, math.cos(angle)*10, math.sin(angle)*10)
		end
	end
end

function collide(a,b)
	
end

for i=1,20,1 do
	local enemy = display.newCircle(math.random()*display.contentWidth,math.random()*display.contentHeight,7.5)
	table.insert(enemies, i, enemy)
	table.insert(eSpeedsX,i,math.random()*5 - 2.5)
	table.insert(eSpeedsY,i,math.random()*5 - 2.5)
end

Runtime:addEventListener("key", keyPressed)
Runtime:addEventListener("mouse", mousePressed)
timer.performWithDelay(1000/40, checkTime, 0)