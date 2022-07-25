weapons = {}

function weaponsInit()
	local locs = FindLocations("weapon")
	for i=1, #locs do
		local loc = locs[i]
		local t = GetLocationTransform(loc)
		QueryRequire("dynamic large")
		local hit, point, normal, shape = QueryClosestPoint(t.pos, 0.15)
		if hit then
			local weapon = {}
			weapon.type = GetTagValue(loc, "weapon")
			weapon.timeBetweenRounds = tonumber(GetTagValue(loc, "idle"))
			weapon.chargeTime = tonumber(GetTagValue(loc, "charge"))
			weapon.fireCooldown = tonumber(GetTagValue(loc, "cooldown"))
			weapon.shotsPerRound = tonumber(GetTagValue(loc, "count"))
			weapon.spread = tonumber(GetTagValue(loc, "spread"))
			weapon.strength = tonumber(GetTagValue(loc, "strength"))
			weapon.maxDist = tonumber(GetTagValue(loc, "maxdist"))
			if weapon.type == "" then weapon.type = "gun" end
			if not weapon.timeBetweenRounds then weapon.timeBetweenRounds = 1 end
			if not weapon.chargeTime then weapon.chargeTime = 1.2 end
			if not weapon.fireCooldown then weapon.fireCooldown = 0.15 end
			if not weapon.shotsPerRound then weapon.shotsPerRound = 1 end
			if not weapon.spread then weapon.spread = 0.01 end
			if not weapon.strength then weapon.strength = 1.0 end
			if not weapon.maxDist then weapon.maxDist = 100.0 end
			local b = GetShapeBody(shape)
			local bt = GetBodyTransform(b)
			weapon.localTransform = TransformToLocalTransform(bt, t)
			weapon.body = b
			weapon.state = "idle"
			weapon.idleTimer = 0
			weapon.chargeTimer = 0
			weapon.fireTimer = 0
			weapon.fireCount = 0
			weapons[i] = weapon
		end
	end

	lightsaber = FindShape("target1")
	saber = FindJoint("rotate24")
	target1 = FindShape("target1")
	body1 = GetShapeBody(target1)
end

function weaponFire(weapon, pos, dir)
	local perp = getPerpendicular(dir)
	
	-- This is the default bullet spread
	local spread = weapon.spread * rnd(0.0, 1.0)

	-- Add more spread up based on aim, so that the first bullets never (well, rarely) hit player
	local extraSpread = math.min(0.5, 2.0 / robot.distToPlayer)
	spread = spread	+ (1.0-head.aim) * extraSpread

	dir = VecNormalize(VecAdd(dir, VecScale(perp, spread)))

	--Start one voxel ahead to not hit robot itself
	pos = VecAdd(pos, VecScale(dir, 0.1))
	
	if weapon.type == "gun" then
		PlaySound(shootSound, pos, 1.0, false)
		PointLight(pos, 1, 0, 0, 20)
		Shoot(pos, dir, 0, weapon.strength)
	elseif weapon.type == "rocket" then
		PlaySound(rocketSound, pos, 1.0, false)
		Shoot(pos, dir, 1, weapon.strength)
	end
end


function weaponsReset()
	for i=1, #weapons do
		weapons[i].state = "idle"
		weapons[i].idleTimer = weapons[i].timeBetweenRounds
		weapons[i].fire = 0
	end
end


function weaponEmitFire(weapon, t, amount)
	if robot.stunned > 0 then
		return
	end
	local p = TransformToParentPoint(t, Vec(0, 0, -0.1))
	local d = TransformToParentVec(t, Vec(0, 0, -1))

	--[[
	ParticleReset()
	ParticleTile(5)
	ParticleColor(1, 1, 0.5, 1, 0.5, 0.2)
	ParticleRadius(0.1*amount, 0.8*amount)
	ParticleEmissive(6, 0)
	ParticleDrag(0.1)
	ParticleGravity(math.random()*20)
	PointLight(p, 1, 0.8, 0.2, 2*amount)
	PlayLoop(fireLoop, t.pos, amount)
	SpawnParticle(p, VecScale(d, 12), 0.5 * amount)
	]]

	if amount > 0.5 then
		--Spawn fire
		if not spawnFireTimer then
			spawnFireTimer = 0
		end
		if spawnFireTimer > 0 then
			spawnFireTimer = math.max(spawnFireTimer-0.01667, 0)
		else
			rejectAllBodies(robot.allBodies)
			local hit, dist = QueryRaycast(p, d, 3)
			if hit then
				local wp = VecAdd(p, VecScale(d, dist))
				--SpawnFire(wp)
				spawnFireTimer = 1
			end
		end
		
		--Hurt player
		local toPlayer = VecSub(GetPlayerCameraTransform().pos, t.pos)
		local distToPlayer = VecLength(toPlayer)
		local distScale = clamp(1.0 - distToPlayer / 2.0, 0.0, 1.0)
		if distScale > 0 then
			toPlayer = VecNormalize(toPlayer)
			if VecDot(d, toPlayer) > 0.2 or distToPlayer < 0.1 then
				rejectAllBodies(robot.allBodies)
				SetJointMotor(saber, 0)
				local hit = QueryRaycast(p, toPlayer, distToPlayer)
				if not hit or distToPlayer < 0.2 then
					SetPlayerHealth(GetPlayerHealth() - 0.02 * weapon.strength)
					--SetJointMotor(saber, -15)
					SetBodyAngularVelocity(body1, Vec(0, -100, 0))
				end
			end	
		end
	end
end


function weaponsUpdate(dt)
	for i=1, #weapons do
		local weapon = weapons[i]
		local bt = GetBodyTransform(weapon.body)
		local t = TransformToParentTransform(bt, weapon.localTransform)
		local fwd = TransformToParentVec(t, Vec(0, 0, -1))
		t.pos = VecAdd(t.pos, VecScale(fwd, 0.15))
		local playerPos = VecCopy(robot.playerPos)
		local toPlayer = VecSub(playerPos, t.pos)
		local distToPlayer = VecLength(toPlayer)
		toPlayer = VecNormalize(toPlayer)
		local clearShot = false
		
		if weapon.type == "fire" then
			if not weapon.fire then
				weapon.fire = 0
			end
			if head.canSeePlayer and robot.distToPlayer < 8.0 then
				weapon.fire = math.min(weapon.fire + 0.1, 1.0)
			else
				weapon.fire = math.max(weapon.fire - dt*0.5, 0.0)
			end
			if weapon.fire > 0 then
				weaponEmitFire(weapon, t, weapon.fire)
			else
				weaponEmitFire(weapon, t, math.max(weapon.fire, 0.1))
			end
		else
			--Need to point towards player and have clear line of sight to have clear shot
			local towardsPlayer = VecDot(fwd, toPlayer)
			local gotAim = towardsPlayer > 0.9
			if distToPlayer < 1.0 and towardsPlayer > 0.0 then
				gotAim = true
			end
			if head.canSeePlayer and gotAim and robot.distToPlayer < weapon.maxDist then
				QueryRequire("physical large")
				rejectAllBodies(robot.allBodies)
				local hit = QueryRaycast(t.pos, fwd, distToPlayer, 0, true)
				if not hit then
					clearShot =  true
				end
			end

			--Handle states
			if weapon.state == "idle" then
				weapon.idleTimer = weapon.idleTimer - dt
				if weapon.idleTimer <= 0 and clearShot then
					weapon.state = "charge"
					weapon.fireDir = fwd
					weapon.chargeTimer = weapon.chargeTime
				end
			elseif weapon.state == "charge" or weapon.state == "chargesilent" then
				weapon.chargeTimer = weapon.chargeTimer - dt
				if weapon.state ~= "chargesilent" then
					--PlayLoop(chargeLoop, t.pos)
				end
				if weapon.chargeTimer <= 0 then
					weapon.state = "fire"
					weapon.fireTimer = 0
					weapon.fireCount = weapon.shotsPerRound
				end
			elseif weapon.state == "fire" then	
				weapon.fireTimer = weapon.fireTimer - dt
				if towardsPlayer > 0.3 or distToPlayer < 1.0 then
					if weapon.fireTimer <= 0 then
						weaponFire(weapon, t.pos, fwd)
						weapon.fireCount = weapon.fireCount - 1
						if weapon.fireCount <= 0 then
							if clearShot then
								weapon.state = "chargesilent"
								weapon.chargeTimer = weapon.chargeTime
							else
								weapon.state = "idle"
								weapon.idleTimer = weapon.timeBetweenRounds
							end
						else
							weapon.fireTimer = weapon.fireCooldown
						end
					end			
				else
					--We are no longer pointing towards player, abort round
					weapon.state = "idle"
					weapon.idleTimer = weapon.timeBetweenRounds
				end
			end
		end
	end
end	


aims = {}

function aimsInit()
	local bodies = FindBodies("aim")
	for i=1, #bodies do
		local aim = {}
		aim.body = bodies[i]
		aims[i] = aim
	end
end


function aimsUpdate(dt)
	for i=1, #aims do
		local aim = aims[i]
		local playerPos = VecCopy(robot.playerPos)
		local toPlayer = VecNormalize(VecSub(playerPos, GetBodyTransform(aim.body).pos))
		local fwd = TransformToParentVec(GetBodyTransform(robot.body), Vec(0, 0, -1))
		if (head.canSeePlayer and VecDot(fwd, toPlayer) > 0.5) or robot.distToPlayer < 4.0 then
			--Should aim
			local v = 2
			local f = 20
			local wt = GetBodyTransform(aim.body)
			local toPlayerOrientation = QuatLookAt(wt.pos, playerPos)
			ConstrainOrientation(aim.body, robot.body, wt.rot, toPlayerOrientation, v, f)
		else
			--Should not aim
			local rd = TransformToParentVec(GetBodyTransform(robot.body), Vec(0, 0, -1))
			local wd = TransformToParentVec(GetBodyTransform(aim.body), Vec(0, 0, -1))
			local angle = clamp(math.acos(VecDot(rd, wd)), 0, 1)
			local v = 2
			local f = math.abs(angle) * 10 + 3
			ConstrainOrientation(robot.body, aim.body, GetBodyTransform(robot.body).rot, GetBodyTransform(aim.body).rot, v, f)
		end
	end
end	
	