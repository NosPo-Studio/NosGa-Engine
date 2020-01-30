local global = ...

TestGO = {}
TestGO.__index = TestGO

function TestGO.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestGO: init")
end

function TestGO.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 6
	args.sizeY = 6
	args.gameObject = {
		--{"Sprite", texture = global.texture.player.right},
		--{"Sprite", texture = global.texture.grass},
		{"CopyArea", x = 0, y = 0, sx = args.sizeX, sy = args.sizeY},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(this, args)
	this = setmetatable(this, TestGO)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.gameObject:addBoxTrigger({
		sx = 6, 
		sy = 3,
		
		lf = function(collider, go, selfCall)
			--global.log(global.currentFrame, this:getName(), this, collider, go, selfCall)
		end
	})
	
	this.gameObject:addSprite({texture = global.texture.player.right})
	
	
	--===== global functions =====--
	this.ctrl_left_key_pressed = function(this)
		if this:getName() == "test1" then
			this:move(-1, 0)
		end
	end
	this.ctrl_right_key_pressed = function(this)
		if this:getName() == "test1" then
			this:move(1, 0)
		end
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
	
	this.update = function(this, dt, ra) --will called on every game tick.
		--global.log("TestGO2: update: ", this:getPos())
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		--global.log("TestGO(" .. tostring(this.ngeAttributes.name) .. "): draw")
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		--[[
		global.log("TestGO: clear")
		
		for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
			for i, c in pairs(ra.toClear) do
				for i, c in pairs(c) do
					global.log(i, c)
				end
			end
		end
		]]
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		global.log("TestGO: activate")
	end
	
	return this
end

return TestGO