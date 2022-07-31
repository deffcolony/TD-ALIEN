--once the AI decided where to go, the navigation functions below decide how to get there
--while avoiding obstacles and choosing a short path
--GetPathState() this is a built in funciton outside the robot that decides what nodes to take to get to the target
------------------------------------------------------------------------

navigation = {}
navigation.state = "done"
navigation.path = {}			-- Actual positions to get to in order to reach the final point
navigation.target = Vec()
navigation.hasNewTarget = false
navigation.resultRetrieved = true
navigation.deviation = 0		-- Distance to path (looks like it's not actually used)
navigation.blocked = 0			-- Measuring if something stops the robot from navigating along the path and it got stuck
navigation.unblockTimer = 0		-- Timer that ticks up when blocked. If reaching limit, unblock kicks in and timer resets
navigation.unblock = 0			-- If more than zero, navigation is in unblock mode (reverse direction)
navigation.vertical = 0			-- related to the angle (up / down) between the navigation points. Should slow down when verticality changes
navigation.thinkTime = 0		-- How long GetPathState() has been computing looking for a good path
navigation.timeout = 1			-- Give up and do the next thing if GetPathState() cannot find a good path within this time
navigation.lastQueryTime = 0
navigation.timeSinceProgress = 0-- Related to giving up on a path if no progress for 5 seconds. (i believe progress is measured in getting to a new node)

function navigationInit()
	if #wheels.bodies > 0 then
		navigation.pathType = "low"
	else
		navigation.pathType = "standard"
	end
end

--Prune path backwards so robot doesn't need to go backwards
--ie if the path would loop back on itself, cut off the beginning and only keep the part after the looping back
function navigationPrunePath()
	if #navigation.path > 0 then
		for i=#navigation.path, 1, -1 do
			local p = navigation.path[i]
			local dv = VecSub(p, robot.basetransform.pos)
			local d = VecLength(dv)
			if d < PATH_NODE_TOLERANCE then
				--Keep everything after this node and throw out the rest
				local newPath = {}
				for j=i, #navigation.path do
					newPath[#newPath+1] = navigation.path[j]
				end
				navigation.path = newPath
				return
			end
		end
	end
end

function navigationClear()
	AbortPath()
	navigation.state = "done"
	navigation.path = {}
	navigation.hasNewTarget = false
	navigation.resultRetrieved = true
	navigation.deviation = 0
	navigation.blocked = 0
	navigation.unblock = 0
	navigation.vertical = 0
	navigation.target = Vec(0, -100, 0)
	navigation.thinkTime = 0
	navigation.lastQueryTime = 0
	navigation.unblockTimer = 0
	navigation.timeSinceProgress = 0
end

function navigationSetTarget(pos, timeout)
	pos = truncateToGround(pos)
	if VecDist(navigation.target, pos) > 2.0 then
		navigation.target = VecCopy(pos)
		navigation.hasNewTarget = true
		navigation.state = "move"
	end
	navigation.timeout = timeout
	navigation.timeSinceProgress = 0
end

function navigationUpdate(dt)
	if GetPathState() == "busy" then
		navigation.timeSinceProgress = 0
		navigation.thinkTime = navigation.thinkTime + dt
		if navigation.thinkTime > navigation.timeout then
			AbortPath()
		end
	end

	if GetPathState() ~= "busy" then
		if GetPathState() == "done" or GetPathState() == "fail" then
			if not navigation.resultRetrieved then
				if GetPathLength() > 0.5 then
					for l=0.2, GetPathLength(), 0.2 do
						navigation.path[#navigation.path+1] = GetPathPoint(l)
					end
				end			
				navigation.lastQueryTime = navigation.thinkTime
				navigation.resultRetrieved = true
				navigation.state = "move"
				navigationPrunePath()
			end
		end
		navigation.thinkTime = 0
	end

	if navigation.thinkTime == 0 and navigation.hasNewTarget then
		local startPos
		
		if #navigation.path > 0 and VecDist(navigation.path[1], robot.navigationCenter) < 2.0 then
			--Keep a little bit of the old path and use last point of that as start position
			--Use previous query's time as an estimate for the next
			local distToKeep = VecLength(GetBodyVelocity(robot.body))*navigation.lastQueryTime
			local nodesToKeep = math.clamp(math.ceil(distToKeep / 0.2), 1, 15)			
			local newPath = {}
			for i=1, math.min(nodesToKeep, #navigation.path) do
				newPath[i] = navigation.path[i]
			end
			navigation.path = newPath
			startPos = navigation.path[#navigation.path]
		else
			startPos = truncateToGround(robot.basetransform.pos)
			navigation.path = {}
		end

		local targetRadius = 0.2
		if GetPlayerVehicle()~=0 then
			targetRadius = 4.0
		end
	
		local target = navigation.target
		if robot.limitTrigger ~= 0 then
			target = GetTriggerClosestPoint(robot.limitTrigger, target)
			target = truncateToGround(target)
		end

		QueryRequire("physical large")
		rejectAllBodies(robot.allBodies)
		QueryPath(startPos, target, 100, targetRadius, navigation.pathType)

		navigation.timeSinceProgress = 0
		navigation.hasNewTarget = false
		navigation.resultRetrieved = false
		navigation.state = "move"
	end
		
	navigationMove(dt)
	
	if GetPathState() ~= "busy" and #navigation.path == 0 and not navigation.hasNewTarget then
		if GetPathState() == "done" or GetPathState() == "idle" then
			navigation.state = "done"
		else
			navigation.state = "fail"
		end
	end
end


function navigationMove(dt)
	if #navigation.path > 0 then
		if navigation.resultRetrieved then
			--If we have a finished path and didn't progress along it for five seconds, recompute
			--Should probably only do this for a limited time until giving up
			navigation.timeSinceProgress = navigation.timeSinceProgress + dt
			if navigation.timeSinceProgress > 5.0 then
				navigation.hasNewTarget = true
				navigation.path = {}
			end
		end
		if navigation.unblock > 0 then
			robot.speed = -2
			navigation.unblock = navigation.unblock - dt
		else
			local target = navigation.path[1]
			local dv = VecSub(target, robot.navigationCenter)
			local distToFirstPathPoint = VecLength(dv)
			dv[2] = 0
			local d = VecLength(dv)
			if distToFirstPathPoint < 2.5 then
				if d < PATH_NODE_TOLERANCE then
					if #navigation.path > 1 then
						--Measure verticality which should decrease speed
						local diff = VecSub(navigation.path[2], navigation.path[1])
						navigation.vertical = diff[2] / (VecLength(diff)+0.001)
						--Remove the first one
						local newPath = {}
						for i=2, #navigation.path do
							newPath[#newPath+1] = navigation.path[i]
						end
						navigation.path = newPath
						navigation.timeSinceProgress = 0
					else
						--We're done
						navigation.path = {}
						robot.speed = 0
						
						return
					end
				else
					--Walk towards first point on path
					robot.dir = VecCopy(VecNormalize(VecSub(target, robot.transform.pos)))
					
					local dirDiff = VecFacingDifference(robot.axes[FORWARD], robot.dir, robot.axes[RIGHT],Vec(0,1,0))
					local speedScale = math.max(0.25, 1-2*math.abs(dirDiff))
 					
					speedScale = speedScale * clamp(1.0 - navigation.vertical, 0.3, 1.0)
					robot.speed = config.speed * speedScale
				end
			else
				--Went off path, scrap everything and recompute
				navigation.hasNewTarget = true
				navigation.path = {}
			end

			--Check if stuck
			if robot.blocked > 0.2 then
				navigation.blocked = navigation.blocked + dt
				if navigation.blocked > 0.2 then
					robot.breakAllTimer = 0.1
					navigation.blocked = 0.0
				end
				navigation.unblockTimer = navigation.unblockTimer + dt
				if navigation.unblockTimer > 2.0 and navigation.unblock <= 0.0 then
					navigation.unblock = 1.0
					navigation.unblockTimer = 0
				end
			else
				navigation.blocked = 0
				navigation.unblockTimer = 0
			end
		end
	end
end

function getClosestPatrolIndex()
	local bestIndex = 1
	local bestDistance = 999
	for i=1, #patrolLocations do
		local pt = GetLocationTransform(patrolLocations[i]).pos
		local d = VecLength(VecSub(pt, robot.transform.pos))
		if d < bestDistance then
			bestDistance = d
			bestIndex = i
		end
	end
	return bestIndex
end

function getDistantPatrolIndex(currentPos)
	local bestIndex = 1
	local bestDistance = 0
	for i=1, #patrolLocations do
		local pt = GetLocationTransform(patrolLocations[i]).pos
		local d = VecLength(VecSub(pt, currentPos))
		if d > bestDistance then
			bestDistance = d
			bestIndex = i
		end
	end
	return bestIndex
end

function getNextPatrolIndex(current)
	local i = current + 1
	if i > #patrolLocations then
		i = 1	
	end
	return i
end

function markPatrolLocationAsActive(index)
	for i=1, #patrolLocations do
		if i==index then
			SetTag(patrolLocations[i], "active")
		else
			RemoveTag(patrolLocations[i], "active")
		end
	end
end

function truncateToGround(pos)
	rejectAllBodies(robot.allBodies)
	QueryRejectVehicle(GetPlayerVehicle())
	hit, dist = QueryRaycast(pos, Vec(0, -1, 0), 5, 0.2)
	if hit then
		pos = VecAdd(pos, Vec(0, -dist, 0))
	end
	return pos
end

function getRandomPosInTrigger(trigger)
	local mi, ma = GetTriggerBounds(trigger)
	local minDist = math.max(ma[1]-mi[1], ma[3]-mi[3])*0.25
	minDist = math.min(minDist, 5.0)

	for i=1, 100 do
		local probe = Vec()
		for j=1, 3 do
			probe[j] = mi[j] + (ma[j]-mi[j])*rnd(0,1)
		end
		if IsPointInTrigger(trigger, probe) then
			return probe
		end
	end
	return VecLerp(mi, ma, 0.5)
end