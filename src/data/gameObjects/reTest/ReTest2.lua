local global = ...

ReTest = {}
ReTest.__index = ReTest

function ReTest.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("ReTest: init")
end

function ReTest.new(args)
	args = args or {}
	args.sizeX = 10
	args.sizeY = 5
	args.components = {
		--{"Sprite", texture = "grass"},
		{"Sprite", texture = "ttest"},
	}
	args.useAnimation = true
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, ReTest)
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this, t)
		--global.log(global.ut.tostring(global.texture.ttest, false))
	end	
	
	this.update = function(this, dt, ra) --will called on every game tick.
		--this:rerender()
		
		--this:move(1, 0)
	end
	
	return this
end

return ReTest