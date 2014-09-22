-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--display.newText("Hello World",100,100,native.systemFont,15)

local player = display.newRect(50,50,20,20)
player.health = 100
local wP,aP,sP,dP = false

local projectiles = {}
local enemies = {}
local obstacles = {}

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
			enemies[i].velX = math.random()*5 - 2.5
			enemies[i].velY = math.random()*5 - 2.5
		end
		if math.random() < 0.0025 then
			local deltaX = player.x - enemies[i].x
			local deltaY = player.y - enemies[i].y
			local angle = math.atan2(deltaY, deltaX)
			projectile("Enemy", enemies[i].x, enemies[i].y, math.cos(angle)*3, math.sin(angle)*3)
		end
		enemies[i]:translate(enemies[i].velX,enemies[i].velY)
		for j = 1,table.getn(enemies),1 do
			if i == j then
			
			else
				if collide(enemies[i],enemies[j]) then
					enemies[i]:translate(-enemies[i].velX,-enemies[i].velY)
					enemies[i].velX = math.random()*5 - 2.5
					enemies[i].velY = math.random()*5 - 2.5
				end
			end
		end
		for j = 1,table.getn(obstacles),1 do
			if collide(enemies[i],obstacles[j]) then
				enemies[i]:translate(-enemies[i].velX,-enemies[i].velY)
				enemies[i].velX = math.random()*5 - 2.5
				enemies[i].velY = math.random()*5 - 2.5
			end
		end
		if enemies[i].x < 0 then
			enemies[i].x = 0
		elseif enemies[i].y < 0 then
			enemies[i].y = 0
		elseif enemies[i].x > display.contentWidth then
			enemies[i].x = display.contextWidth
		elseif enemies[i].y > display.contentHeight then
			enemies[i].y = display.contextHeight
		end
	end
	for i = 1,table.getn(projectiles),1 do
		projectiles[i]:translate(projectiles[i].velX,projectiles[i].velY)
		if projectiles[i].owner == "Player" then
			projectiles[i].velX = projectiles[i].velX*1.07
			projectiles[i].velY = projectiles[i].velY*1.07
			for j = table.getn(enemies),1,-1 do
				if enemies[j] == nil then
				
				else
					if collide(projectiles[i],enemies[j]) then
						local enemy = enemies[j]
						table.remove(enemies, j)
						--j = j - 1
						enemy:removeSelf()
					end
				end
			end
		elseif projectiles[i].owner == "Enemy" then
			if collwaide(projectiles[i],player) and projectiles[i].active then
				projectiles[i].active = false
				player.health = player.health - 1
				print(player.health)
			end
			for j = 1,table.getn(obstacles),1 do
				if collide(projectiles[i],obstacles[j]) then
					--projectiles[i]:translate(-enemies[i].velX,-enemies[i].velY)
					projectiles[i].velX = math.random()*5 - 2.5
					projectiles[i].velY = math.random()*5 - 2.5
				end
			end
		end
	end
	
	for i = table.getn(projectiles),1,-1 do
		if projectiles[i].x < 0 or projectiles[i].y < 0 or projectiles[i].x > display.contentWidth or projectiles[i].y > display.contentHeight then
			local p = projectiles[i]
			table.remove(projectiles, i)
			p:removeSelf()
			--i = i - 1
		end
	end
end

function projectile(owner,x,y,xSpeed,ySpeed)
	local p = display.newRect(x,y,2,10)
	--print(math.atan2(ySpeed,xSpeed))
	p:rotate(math.deg(math.atan2(ySpeed,xSpeed))+90)
	table.insert(projectiles, p)
	p.owner = owner
	p.velX = xSpeed
	p.velY = ySpeed
	p.active = true
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
			projectile("Player", player.x, player.y, math.cos(angle)*10, math.sin(angle)*10)
		end
	end
end

function collide(a,b)
	--Does not account for rotation
	if (a.x + a.width/2 < b.x - b.width/2 or 
		a.y + a.height/2 < b.y - b.height/2 or 
		a.x - a.width/2 > b.x + b.width/2 or 
		a.y - a.height/2 > b.y + b.height/2) then
		return false;
	end
    return true;
end

for i=1,20,1 do
	local enemy = display.newCircle(math.random()*display.contentWidth,math.random()*display.contentHeight,7.5)
	table.insert(enemies, i, enemy)
	enemy.velX = math.random()*5 - 2.5
	enemy.velY = math.random()*5 - 2.5
end

for i=1,40,1 do
	local obstacle = display.newRect(math.random()*display.contentWidth,math.random()*display.contentHeight,20,20)
	while true do
		local blocking = false
		obstacle.x = math.random()*display.contentWidth
		obstacle.y = math.random()*display.contentHeight
		for j=1,table.getn(enemies) do
			if collide(enemies[j],obstacle) then
				blocking = true
			end
		end
		if not blocking then break end
	end
	table.insert(obstacles, i, obstacle)
end

Runtime:addEventListener("key", keyPressed)
Runtime:addEventListener("mouse", mousePressed)
timer.performWithDelay(1000/40, checkTime, 0)