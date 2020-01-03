local global = ...

TestGO = {}
TestGO.__index = TestGO

function TestGO.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestGO: init")
end

function TestGO.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 25
	args.sizeY = 24
	args.gameObject = {
		{"Sprite", texture = global.texture.benchmarkTexture},
		--{"ClearArea", x = 0, y = 0, sx = args.sizeX, sy = args.sizeY},
		{"CopyArea", x = 0, y = 0, sx = args.sizeX, sy = args.sizeY},
		{"RigidBody", g = 0, stiffness = 1},
	}
	
	--[[
	for i = 0, args.length *25, 25 do
		args.sizeX = i
		table.insert(args.gameObject, {"Sprite", texture = global.texture.benchmarkTexture, posX = i})
	end
	]]
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, TestGO)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.speed = 10
	
	--===== global/custom functions =====--
	this.ctrl_left_key_pressed = function(this)
		this:addForce(-this.speed, 0, this.speed)
		--this:move(-this.speed, 0)
	end
	this.ctrl_right_key_pressed = function(this)
		this:addForce(this.speed, 0, this.speed)
		--this:move(this.speed, 0)
	end
	this.ctrl_up_key_pressed = function(this)
		this:addForce(0, -this.speed, this.speed)
		--this:move(0, this.speed)
	end
	this.ctrl_down_key_pressed = function(this)
		this:addForce(0, this.speed, this.speed)
		--this:move(0, -this.speed)
	end
	
	this.test = function()
		global.log("GG")
	end
	
	--===== default functions =====--
	this.spawn = function(this) --will called if gameObject become spawned.
		--global.log("TestGO: spawned")
	end
	
	this.despawn = function(this) --will called if gameObject become despawned (not implemented yet).
		global.log("TestGO: despawned")
	end
	
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		global.log("TestGO: start")
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		global.log("TestGO: stop")
	end
	
	this.update = function(this) --will called on every game tick.
		--global.log(this:getPos())
		--global.log("TestGO: update")
		
		--global.log(this.ngeAttributes.name)
		--global.log(this.ngeAttributes.lastCalculatedFrame)
	end
	
	this.draw = function(this, realArea, renderArea) --will called every time the gameObject will drawed.
		--global.log("TestGO(" .. tostring(this.ngeAttributes.name) .. "): draw: " .. tostring(renderArea.name) .. " | " .. tostring(renderArea.realArea))
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		--global.log("TestGO: clear")
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		global.log("TestGO: activate")
	end
	
	return this
end

return TestGO