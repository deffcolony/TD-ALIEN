
sensor = {}
sensor.blocked = 0
sensor.blockedLeft = 0
sensor.blockedRight = 0
sensor.detectFall = 0


function sensorInit()
end


function sensorGetBlocked(dir, maxDist)
	dir = VecNormalize(VecAdd(dir, rndVec(0.3)))
	local origin = TransformToParentPoint(robot.transform, Vec(0, 0.8, 0))
	QueryRequire("physical large")
	rejectAllBodies(robot.allBodies)
	local hit, dist = QueryRaycast(origin, dir, maxDist)
	return 1.0 - dist/maxDist
end

function sensorDetectFall()
	dir = Vec(0, -1, 0)
	local lookAheadDist = 0.6 + clamp(VecLength(GetBodyVelocity(robot.body))/6.0, 0.0, 0.6)
	local origin = TransformToParentPoint(robot.transform, Vec(0, 0.5, -lookAheadDist))
	QueryRequire("physical large")
	rejectAllBodies(robot.allBodies)
	local maxDist = hover.distTarget + 1.0
	local hit, dist = QueryRaycast(origin, dir, maxDist, 0.2)
	return not hit
end

function sensorUpdate(dt)
	local maxDist = config.sensorDist
	local blocked = sensorGetBlocked(TransformToParentVec(robot.transform, Vec(0, 0, -1)), maxDist)
	if sensorDetectFall() then
		sensor.detectFall = 1.0
	else
		sensor.detectFall = 0.0
	end
	sensor.blocked = sensor.blocked * 0.9 + blocked * 0.1

	local blockedLeft = sensorGetBlocked(TransformToParentVec(robot.transform, Vec(-0.5, 0, -1)), maxDist)
	sensor.blockedLeft = sensor.blockedLeft * 0.9 + blockedLeft * 0.1

	local blockedRight = sensorGetBlocked(TransformToParentVec(robot.transform, Vec(0.5, 0, -1)), maxDist)
	sensor.blockedRight = sensor.blockedRight * 0.9 + blockedRight * 0.1
end


------------------------------------------------------------------------


head = {}
head.body = 0
head.eye = 0
head.dir = Vec(0,0,-1)
head.lookOffset = 0
head.lookOffsetTimer = 0
head.canSeePlayer = false
head.lastSeenPos = Vec(0,0,0)
head.timeSinceLastSeen = 999
head.seenTimer = 0
head.alarmTimer = 0
head.alarmTime = 2.0
head.aim = 0	-- 1.0 = perfect aim, 0.0 = will always miss player. This increases when robot sees player based on config.aimTime


function headInit()
	head.body = FindBody("head")
	head.eye = FindLight("eye")
	head.joint = FindJoint("head")
	head.alarmTime = getTagParameter(head.eye, "alarm", 2.0)
end


function headTurnTowards(pos)
	head.dir = VecNormalize(VecSub(pos, GetBodyTransform(head.body).pos))
end

function headUpdate(dt)
	local t = GetBodyTransform(head.body)
	local fwd = TransformToParentVec(t, Vec(0, 0, -1))

	--Check if head can see player
	local et = GetLightTransform(head.eye)
	local pp = VecCopy(robot.playerPos)
	local toPlayer = VecSub(pp, et.pos)
	local distToPlayer = VecLength(toPlayer)
	toPlayer = VecNormalize(toPlayer)

	--Determine player visibility
	local playerVisible = false
	if config.hasVision and config.canSeePlayer then
		if distToPlayer < config.viewDistance then	--Within view distance
			local limit = math.cos(config.viewFov * 0.5 * math.pi / 180)
			if VecDot(toPlayer, fwd) > limit then --In view frustum
				rejectAllBodies(robot.allBodies)
				QueryRejectVehicle(GetPlayerVehicle())
				if not QueryRaycast(et.pos, toPlayer, distToPlayer, 0, true) then --Not blocked
					playerVisible = true
				end
			end
		end
	end

	if config.aggressive then
		playerVisible = true
	end
	
	--If player is visible it takes some time before registered as seen
	--If player goes out of sight, head can still see for some time second (approximation of motion estimation)
	if playerVisible then
		local distanceScale = clamp(1.0 - distToPlayer/config.viewDistance, 0.5, 1.0)
		local angleScale = clamp(VecDot(toPlayer, fwd), 0.5, 1.0)
		local delta = (dt * distanceScale * angleScale) / (config.visibilityTimer / 0.5)
		head.seenTimer = math.min(1.0, head.seenTimer + delta)
	else
		head.seenTimer = math.max(0.0, head.seenTimer - dt / config.lostVisibilityTimer)
	end
	head.canSeePlayer = (head.seenTimer > 0.5)
	
	if head.canSeePlayer then
		head.lastSeenPos = pp
		head.timeSinceLastSeen = 0
	else
		head.timeSinceLastSeen = head.timeSinceLastSeen + dt
	end

	if playerVisible and head.canSeePlayer then
		head.aim = math.min(1.0, head.aim + dt / config.aimTime)
	else
		head.aim = math.max(0.0, head.aim - dt / config.aimTime)
	end
	
	if config.triggerAlarmWhenSeen then
		local red = false
		if GetBool("level.alarm") then
			red = math.mod(GetTime(), 0.5) > 0.25
		else
			if playerVisible and IsPointAffectedByLight(head.eye, pp) then
				red = true
				head.alarmTimer = head.alarmTimer + dt
				--PlayLoop(chargeLoop, robot.transform.pos)
				if head.alarmTimer > head.alarmTime and playerVisible then
					SetString("hud.notification", "Detected by robot. Alarm triggered.")
					SetBool("level.alarm", true)
				end
			else
				head.alarmTimer = math.max(0.0, head.alarmTimer - dt)
			end
		end
		if red then
			SetLightColor(head.eye, 1, 0, 0)
		else
			SetLightColor(head.eye, 1, 1, 1)
		end
	end
	
	--Rotate head to head.dir
	local fwd = TransformToParentVec(t, Vec(0, 0, -1))
	if playerVisible then
		headTurnTowards(pp)
	end
	head.dir = VecNormalize(head.dir)
	--end
	local c = VecCross(fwd, head.dir)
	local d = VecDot(c, robot.axes[UP])
	local angVel = clamp(d*10, -3, 3)
	local f = 100
	mi, ma = GetJointLimits(head.joint)
	local ang = GetJointMovement(head.joint)
	if ang < mi+1 and angVel < 0 then
		angVel = 0
	end
	if ang > ma-1 and angVel > 0 then
		angVel = 0
	end
	
	ConstrainAngularVelocity(head.body, robot.body, robot.axes[UP], angVel, -f , f)

	local vol = clamp(math.abs(angVel)*0.3, 0.0, 1.0)
	if vol > 0 then
		--PlayLoop(headLoop, robot.transform.pos, vol)
	end
end


------------------------------------------------------------------------

hearing = {}
hearing.lastSoundPos = Vec(10, -100, 10)
hearing.lastSoundVolume = 0
hearing.timeSinceLastSound = 0
hearing.hasNewSound = false

function hearingInit()
end

function hearingUpdate(dt)
	hearing.timeSinceLastSound = hearing.timeSinceLastSound + dt
	if config.canHearPlayer then
		local vol, pos = GetLastSound()
		local dist = VecDist(robot.transform.pos, pos)
		if vol > 0.1 and dist > 4.0 and dist < config.maxSoundDist then
			local valid = true
			--If there is an investigation trigger, the robot is in it and the sound is not, ignore sound
			if robot.investigateTrigger ~= 0 and IsPointInTrigger(robot.investigateTrigger, robot.bodyCenter) and not IsPointInTrigger(robot.investigateTrigger, pos) then
				valid = false
			end
			--React if time has passed since last sound or if it's substantially stronger
			if valid and (hearing.timeSinceLastSound > 2.0 or vol > hearing.lastSoundVolume*2.0) then
				local attenuation = 5.0 / math.max(5.0, dist)
				attenuation = attenuation * attenuation
				local heardVolume = vol * attenuation
				if heardVolume > 0.05 then
					hearing.lastSoundVolume = vol
					hearing.lastSoundPos = pos
					hearing.timeSinceLastSound = 0
					hearing.hasNewSound = true
				end
			end
		end
	end
end

function hearingConsumeSound()
	hearing.hasNewSound = false
end


function canBeSeenByPlayer()
	for i=1, #robot.allShapes do
		if IsShapeVisible(robot.allShapes[i], config.outline, true) then
			return true
		end
	end
	return false
end

