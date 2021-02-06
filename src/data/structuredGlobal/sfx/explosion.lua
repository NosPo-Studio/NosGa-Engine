local global = ...

local function getForce(force, angle)
	local radians = -math.rad(angle)
	return math.cos(radians) * force, math.sin(radians) * force
end

return function(pc, x, y, particle, particleAmount, force, args)
	particleAmount = particleAmount * global.ut.parseArgs(global.conf.particles, 1)
	local angleSteps = 360 / particleAmount
	for c = 1, particleAmount do
		local fx, fy = getForce(force, angleSteps * c)
		local p = pc:addParticle(particle, x, y, args)
		p.gameObject:addForce(fx, fy)
	end
end