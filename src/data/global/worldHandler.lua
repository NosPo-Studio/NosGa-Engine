local global = ...
local wh = {
	game,
	ra,
	biome,
	posY,
	lastStreetPosX = 0,
	lastBackgroundPosX = 0,
	lastBarrierPosX = {},
	lastObjectPosX = {},
	lastCalculatedX = 0,
	lastGapX = 0,
	lastGapY = 0,
	createdStreets = 0,
	createdBarriers = 0,
	createdFuleContainers = 0,
}

--===== local functions =====--
local function print(...)
	if global.conf.debug.whDebug then
		global.debug.log(...)
	end
end

local function initBiomes()
	for i, b in pairs(global.biome) do
		if type(b) == "table" then
			b.maxStreetChance, b.maxBarrierChance, b.maxFuelContainerChance, b.maxBackgroundChance = 0, 0, 0, 0
			for i, o in pairs(b.streets) do
				b.maxStreetChance = b.maxStreetChance + o.chance
			end
			for i, o in pairs(b.backgrounds) do
				b.maxBackgroundChance = b.maxBackgroundChance + o.chance
			end
			for i, o in pairs(b.barriers) do
				b.maxBarrierChance = b.maxBarrierChance + o.chance
			end
			for i, o in pairs(b.fuelContainers) do
				b.maxFuelContainerChance = b.maxFuelContainerChance + o.chance
			end
		end
	end
end

local function pickObject(maxChance, objects)
	local rng = math.random(maxChance)
	local objectCount = 0
	local go = {}
	
	for i, o in pairs(objects) do
		objectCount = objectCount + o.chance
		if objectCount >= rng then
			return o
		end
	end
end

local function checkBlockedLines(line, gap, posX, lines)
	local lx = 0
	for l, x in pairs(lines) do
		if l ~= line then
			lx = x
		end
	end
	if lx + gap <= posX then
		return true
	else
		return false
	end
end

local function placeStreet(toX)
	while wh.lastStreetPosX < toX do
		print("[WH]: Adding street: X: " .. tostring(wh.lastStreetPosX))
		local street = pickObject(wh.biome.maxStreetChance, wh.biome.streets)
		local go = wh.ra:addGO(street.name, {
			posX = wh.lastStreetPosX, 
			posY = wh.posY, 
			layer = 2,
			name = "Street_" .. tostring(wh.createdStreets),
		})
		
		if go ~= nil then
			wh.lastStreetPosX = wh.lastStreetPosX + go.ngeAttributes.sizeX
			wh.createdStreets = wh.createdStreets +1
			go.isIngameObject = true
		else
			global.warn("[WH]: Could not create Street: " .. tostring(street.name))
		end
	end
end

local function placeBackground(toX)
	while wh.lastBackgroundPosX < toX do
		print("[WH]: Adding background: X: " .. tostring(wh.lastBackgroundPosX))
		local background = pickObject(wh.biome.maxBackgroundChance, wh.biome.backgrounds)
		local go = wh.ra:addGO(background.name, {
			posX = wh.lastBackgroundPosX, 
			posY = wh.posY,
			layer = 2,
			name = "Background_" .. tostring(wh.createdStreets),
		})
		
		if go ~= nil then
			go:move(0, go.ngeAttributes.sizeY)
			wh.lastBackgroundPosX = wh.lastBackgroundPosX + go.ngeAttributes.sizeX
			wh.createdStreets = wh.createdStreets +1
			go.isIngameObject = true
		else
			global.warn("[WH]: Could not create Background: " .. tostring(background.name))
		end
	end
end


local function placeBarrier(fromX, toX)
	local posX = fromX
	
	while posX < toX do
		for i, lbp in pairs(wh.lastObjectPosX) do
			if 
				lbp < posX and 
				math.random(wh.biome.barrierChance) == wh.biome.barrierChance and
				checkBlockedLines(i, wh.biome.barrierGaps, posX, wh.lastBarrierPosX)
			then
				print("[WH]: Adding barrier: X: " .. tostring(posX) .. " Y: " .. tostring(wh.posY + (i -1) * wh.game.streetWidth))
				local barrier = pickObject(wh.biome.maxBarrierChance, wh.biome.barriers)
				local object = wh.ra:addGO(barrier.name, {
					posX = posX,
					posY = wh.posY + (i -1) * wh.game.streetWidth, 
					layer = 3,
					defaultParticleContainer = wh.game.pcDefaultParticleContainer,
					name = "Barrier_" .. tostring(wh.createdBarriers),
				})
				
				if object ~= nil then
					local sx, sy = object:getSize()
					
					wh.lastObjectPosX[i] = posX + object.ngeAttributes.sizeX
					wh.lastBarrierPosX[i] = posX + object.ngeAttributes.sizeX
					wh.createdBarriers = wh.createdBarriers +1
					object:move(0, -(wh.game.streetWidth - sy - 3) / 2)
					object.isIngameObject = true
				else
					global.warn("[WH]: Could not create Barrier: " .. tostring(barrier.name))
				end
			end
		end
		posX = posX +1
	end
end

local function placeFuelContainer(fromX, toX)
	local posX = fromX
	
	while posX < toX do
		for i, lbp in pairs(wh.lastObjectPosX) do
			if 
				lbp < posX and 
				math.random(wh.biome.fuelContainerChance) == wh.biome.fuelContainerChance 
			then
				print("[WH]: Adding fuelContainer: X: " .. tostring(posX) .. " Y: " .. tostring(wh.posY + (i -1) * wh.game.streetWidth))
				local fuelContainer = pickObject(wh.biome.maxFuelContainerChance, wh.biome.fuelContainers)
				local object = wh.ra:addGO(fuelContainer.name, {
					posX = posX,
					posY = wh.posY + (i -1) * wh.game.streetWidth, 
					layer = 3,
					defaultParticleContainer = wh.game.pcDefaultParticleContainer,
					name = "FuelContainer_" .. tostring(wh.createdFuleContainers),
				})
				
				if object ~= nil then
					local sx, sy = object:getSize()
					
					wh.lastObjectPosX[i] = posX + object.ngeAttributes.sizeX
					wh.createdFuleContainers = wh.createdFuleContainers +1
					
					object:move(0, -(wh.game.streetWidth - sy - 3) / 2)
					object.isIngameObject = true
				else
					global.warn("[WH]: Could not create FuleContainer: " .. tostring(fuelContainer.name))
				end
			end
		end
		posX = posX +1
	end
end

local function generateWorld(fromX, toX)	
	toX = toX +3
	placeStreet(toX)
	--placeBackground(toX)
	--placeBarrier(fromX, toX)
	placeFuelContainer(fromX, toX)
	
	wh.lastCalculatedX = toX
end

--===== global functions =====--
function wh.start(game, y, biome)
	initBiomes()
	
	wh.game = game
	wh.ra = game.raMain
	wh.posY = y
	wh.biome = global.biome[biome]
	local fromX, toX = wh.ra:getFOV()
	
	for i = 1, game.lines do
		wh.lastBarrierPosX[i] = 0
		wh.lastObjectPosX[i] = wh.game.goPlayer:getSize() + wh.biome.barrierGaps
	end
	
	generateWorld(fromX +20, toX)
end

function wh.update()
	local fromX, toX = wh.ra:getFOV()
	generateWorld(wh.lastCalculatedX, toX)
end

function wh.reset()
	wh.lastStreetPosX = 0
	wh.lastBackgroundPosX = 0
	wh.lastBarrierPosX = {}
	wh.lastObjectPosX = {}
	wh.lastCalculatedX = 0
	wh.lastGapX = 0
	wh.lastGapY = 0
	wh.createdStreets = 0
	wh.createdBarriers = 0
	wh.createdFuleContainers = 0
end

function wh.stop()
	
end

return wh