--This file is for the core AI of the robot, how it decides what to do next
--There is a hiearchy of actions: 
--1 stack is the overarching goal (eg patrol, investigate)
--2 state controls the current sub action to achive the goal (eg move to a position at a certain speed)
--3 all other non-AI functions make the steps possible (eg deciding how to navigate to a position, how to animate the robot etc)

------------------------------------------------------------------------

--The stack holds the current goal of the AI at the highest level., for example it has an option to "patrol"
--But does not decide exactly where to go to patrol.
--When something is added to the stack, it is going to be done first, then returning to the existing list
--Pushing adds a new goal at the top of the stack, popping removes the top (moving on to the next)
--there's only a single goal at a time, whenfinished it moves onto the next

--possible options in vanilla are below
--none
--patrol
--roam
--navigate: technically more like a state, not the highest level
--search
--unblock
--investigate
--huntlost
--hunt
--avoid
--getup

stack = {}
stack.list = {}

function stackTop()
	return stack.list[#stack.list]
end

function stackPush(id)
	local index = #stack.list+1
	stack.list[index] = {}
	stack.list[index].id = id
	stack.list[index].totalTime = 0
	stack.list[index].activeTime = 0
	return stack.list[index]
end

function stackPop(id)
	if id then
		while stackHas(id) do
			stackPop()
		end
	else
		if #stack.list > 1 then
			stack.list[#stack.list] = nil
		end
	end
end

function stackHas(s)
	return stackGet(s) ~= nil
end

function stackGet(id)
	for i=1,#stack.list do
		if stack.list[i].id == id then
			return stack.list[i]
		end
	end
	return nil
end

function stackClear(s)
	stack.list = {}
	stackPush("none")
end

function stackInit()
	stackClear()
end

function stackUpdate(dt)
	if #stack.list > 0 then
		for i=1, #stack.list do
			stack.list[i].totalTime = stack.list[i].totalTime + dt
		end

		--Tick total time
		stack.list[#stack.list].activeTime = stack.list[#stack.list].activeTime + dt
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#############################################################################################################################################################################

--The next level of abstraction will be the state variables. 
--They would decide things like whether to move, where to move and at what speed

--state.id the current goal coming straight from the stack


function ManageState(dt)
    local state = stackTop()
	
	if state.id == "none" then
		if config.patrol then
			stackPush("patrol")
		else
			stackPush("roam")
		end
	end

	if state.id == "roam" then
		if not state.nextAction then
			state.nextAction = "move"
		elseif state.nextAction == "move" then
			local randomPos
			if robot.roamTrigger ~= 0 then
				randomPos = getRandomPosInTrigger(robot.roamTrigger)
				randomPos = truncateToGround(randomPos)
			else
				local rndAng = rnd(0, 2*math.pi)
				randomPos = VecAdd(robot.basetransform.pos, Vec(math.cos(rndAng)*6.0, 0, math.sin(rndAng)*6.0))
			end
			local s = stackPush("navigate")
			s.timeout = 1
			s.pos = randomPos
			state.nextAction = "search"
		elseif state.nextAction == "search" then
			stackPush("search")
			state.nextAction = "move"
		end
	end

	
	if state.id == "patrol" then
		if not state.nextAction then
			state.index = getClosestPatrolIndex()
			state.nextAction = "move"
		elseif state.nextAction == "move" then
			markPatrolLocationAsActive(state.index)
			local nav = stackPush("navigate")
			nav.pos = GetLocationTransform(patrolLocations[state.index]).pos
			state.nextAction = "search"
		elseif state.nextAction == "search" then
			stackPush("search")
			state.index = getNextPatrolIndex(state.index)
			state.nextAction = "move"
		end
	end

	
	if state.id == "search" then
		if state.activeTime > 2.5 then
			if not state.turn then
				robotSetDirAngle(robotGetDirAngle() + math.random(2, 4))
				state.turn = true
			end
			if state.activeTime > 6.0 then
				stackPop()
			end
		end
		if state.activeTime < 1.5 or state.activeTime > 3 and state.activeTime < 4.5 then
			head.dir = TransformToParentVec(robot.transform, Vec(-5, 0, -1))
		else
			head.dir = TransformToParentVec(robot.transform, Vec(5, 0, -1))
		end
	end

	
	if state.id == "investigate" then
		if not state.nextAction then
			local pos = state.pos
			robotTurnTowards(state.pos)
			headTurnTowards(state.pos)
			local nav = stackPush("navigate")
			nav.pos = state.pos
			nav.timeout = 5.0
			state.nextAction = "search"
		elseif state.nextAction == "search" then
			stackPush("search")
			state.nextAction = "done"
		elseif state.nextAction == "done" then
			PlaySound(idleSound, robot.bodyCenter, 0.3, false)
			stackPop()
		end	
	end
	
	if state.id == "move" then
		robotTurnTowards(state.pos)
		robot.speed = config.speed
		head.dir = VecCopy(robot.dir)
		local d = VecLength(VecSub(state.pos, robot.transform.pos))
		if d < 2 then
			robot.speed = 0
			stackPop()
		else
			if robot.blocked > 0.5 then
				stackPush("unblock")
			end
		end
	end
	
	if state.id == "unblock" then
		if not state.dir then
			if math.random(0, 10) < 5 then
				state.dir = TransformToParentVec(robot.transform, Vec(-1, 0, -1))
			else
				state.dir = TransformToParentVec(robot.transform, Vec(1, 0, -1))
			end
			state.dir = VecNormalize(state.dir)
		else
			robot.dir = state.dir
			robot.speed = -math.min(config.speed, 2.0)
			if state.activeTime > 1 then
				stackPop()
			end
		end
	end

	--Hunt player
	if state.id == "hunt" then
		if not state.init then
			navigationClear()
			state.init = true
			state.headAngle = 0
			state.headAngleTimer = 0
		end
		if robot.distToPlayer < 4.0 then
			robot.dir = VecCopy(robot.dirToPlayer)
			head.dir = VecCopy(robot.dirToPlayer)
			robot.speed = 0
			navigationClear()
		else
			navigationSetTarget(head.lastSeenPos, 1.0 + clamp(head.timeSinceLastSeen, 0.0, 4.0))
			robot.speedScale = config.huntSpeedScale
			navigationUpdate(dt)
			if head.canSeePlayer then
				head.dir = VecCopy(robot.dirToPlayer)
				state.headAngle = 0
				state.headAngleTimer = 0
			else
				state.headAngleTimer = state.headAngleTimer + dt
				if state.headAngleTimer > 1.0 then
					if state.headAngle > 0.0 then
						state.headAngle = rnd(-1.0, -0.5)
					elseif state.headAngle < 0 then
						state.headAngle = rnd(0.5, 1.0)
					else
						state.headAngle = rnd(-1.0, 1.0)
					end
					state.headAngleTimer = 0
				end
				head.dir = QuatRotateVec(QuatEuler(0, state.headAngle, 0), robot.dir)
			end
		end
		if navigation.state ~= "move" and head.timeSinceLastSeen < 2 then
			--Turn towards player if not moving
			robot.dir = VecCopy(robot.dirToPlayer)
		end
		if navigation.state ~= "move" and head.timeSinceLastSeen > 2 and state.activeTime > 3.0 and VecLength(GetBodyVelocity(robot.body)) < 1 then
			if VecDist(head.lastSeenPos, robot.bodyCenter) > 3.0 then
				stackClear()
				local s = stackPush("investigate")
				s.pos = VecCopy(head.lastSeenPos)		
			else
				stackClear()
				stackPush("huntlost")
			end
		end
	end

	if state.id == "huntlost" then
		if not state.timer then
			state.timer = 6
			state.turnTimer = 1
		end
		state.timer = state.timer - dt
		head.dir = VecCopy(robot.dir)
		if state.timer < 0 then
			PlaySound(idleSound, robot.bodyCenter, 0.3, false)
			stackPop()
		else
			state.turnTimer = state.turnTimer - dt
			if state.turnTimer < 0 then
				robotSetDirAngle(robotGetDirAngle() + math.random(2, 4))
				state.turnTimer = rnd(0.5, 1.5)
			end
		end
	end
	
	--Avoid player
	if state.id == "avoid" then
		if not state.init then
			navigationClear()
			state.init = true
			state.headAngle = 0
			state.headAngleTimer = 0
		end
		
		local distantPatrolIndex = getDistantPatrolIndex(GetPlayerTransform().pos)
		local avoidTarget = GetLocationTransform(patrolLocations[distantPatrolIndex]).pos
		navigationSetTarget(avoidTarget, 1.0)
		robot.speedScale = config.huntSpeedScale
		navigationUpdate(dt)
		if head.canSeePlayer then
			head.dir = VecNormalize(VecSub(head.lastSeenPos, robot.transform.pos))
			state.headAngle = 0
			state.headAngleTimer = 0
		else
			state.headAngleTimer = state.headAngleTimer + dt
			if state.headAngleTimer > 1.0 then
				if state.headAngle > 0.0 then
					state.headAngle = rnd(-1.0, -0.5)
				elseif state.headAngle < 0 then
					state.headAngle = rnd(0.5, 1.0)
				else
					state.headAngle = rnd(-1.0, 1.0)
				end
				state.headAngleTimer = 0
			end
			head.dir = QuatRotateVec(QuatEuler(0, state.headAngle, 0), robot.dir)
		end
		
		if navigation.state ~= "move" and head.timeSinceLastSeen > 2 and state.activeTime > 3.0 then
			stackClear()
		end
	end
	
	--Get up
	if state.id == "getup" then
		if not state.time then 
			state.time = 0 
		end
		--try to get up for a few seconds after the start of the getup state
		--only try to get from the time of reaching the ground, not when flying / hanging in the air
		if hover.falling == false then 
			state.time = state.time + dt
		end
		DebugWatch("time", state.time)
		hover.timeSinceContact = 0
		if state.time > 2.0 then
			stackPop()
		else
			if hover.falling == false then
				hoverGetUp()
			end
		end
	end

	if state.id == "navigate" then
		if not state.initialized then
			if not state.timeout then state.timeout = 30 end
			navigationClear()
			navigationSetTarget(state.pos, state.timeout)
			state.initialized = true
		else
			head.dir = VecCopy(robot.dir)
			navigationUpdate(dt)
			if navigation.state == "done" or navigation.state == "fail" then
				stackPop()
			end
		end
	end

	--React to sound
	if not stackHas("hunt") then
		if hearing.hasNewSound and hearing.timeSinceLastSound < 1.0 then
			stackClear()
			--PlaySound(alertSound, robot.bodyCenter, 1.0, false)
			local s = stackPush("investigate")
			s.pos = hearing.lastSoundPos	
			hearingConsumeSound()
		end
	end
	
	--Seen player
	if config.huntPlayer and not stackHas("hunt") then
		if config.canSeePlayer and head.canSeePlayer or robot.canSensePlayer then
			stackClear()
			PlaySound(huntSound, robot.bodyCenter, 0.8, false)
			stackPush("hunt")
		end
	end
	
	--Seen player
	if config.avoidPlayer and not stackHas("avoid") then
		if config.canSeePlayer and head.canSeePlayer or robot.distToPlayer < 2.0 then
			stackClear()
			stackPush("avoid")
		end
	end
	
	--Get up
	if hover.timeSinceContact > 3.0 and not stackHas("getup") then
		stackPush("getup")
	end
	
	if IsShapeBroken(GetLightShape(head.eye)) then
		config.hasVision = false
		config.canSeePlayer = false
	end
	
	--debugState()
end

function debugState()
	local state = stackTop()
	DebugWatch("state", state.id)
	DebugWatch("activeTime", state.activeTime)
	DebugWatch("totalTime", state.totalTime)
	DebugWatch("navigation.state", navigation.state)
	DebugWatch("#navigation.path", #navigation.path)
	DebugWatch("navigation.hasNewTarget", navigation.hasNewTarget)
	DebugWatch("robot.blocked", robot.blocked)
	DebugWatch("robot.speed", robot.speed)
	DebugWatch("navigation.blocked", navigation.blocked)
	DebugWatch("navigation.unblock", navigation.unblock)
	DebugWatch("navigation.unblockTimer", navigation.unblockTimer)
	DebugWatch("navigation.thinkTime", navigation.thinkTime)
	DebugWatch("GetPathState()", GetPathState())
end