--Goals / Design decisions
--The robot is very stable, predictable and reliable
--Animation is erring on the sipmle side to remain bug free, while there's much focus on AI / behaviour
--almost impossible to get stuck
--moves a bit like a tank: only forward, backward and turning
--can't tell if a target is to the back or to the front, but mostly it works out anyway as it turns too fast for this to cause an isse
--it starts turning slow when almost facing target, but the same happens when target is exactly behind at 180 degrees
--Most of the functions are made to be very general, easily reusable
--For example most forces are based on the torso mass, so it is autmatically scaled for smaller or larger bodies
--A large number gameplay behaviours to include 
--(eg multiple weapon types, legs, wheels, investigate, hearing, blocking sensor, unblocking sensor, knockback from weapons, sounds, water damage)
--Can be pushed / pulled / picked up by sufficient force
--Some features are deemed non-essential, thus not implemented
--Cannot be damaged
--Has no arms
--only 2 part legs
--Kocking over is not really a viable strategy
--Secondary animation (eg torso moving up and down with steps)
--There's only one type of stepping at different speeds and step distances, but there's no running (can't rally have both legs in the air)

--How goals are achieved
--Stable:
--Forces are applied at torso center to make it stable
--The robot cannot fall over due to losing balance from a sideways force, only from having no ground beneath (unless extreme, over 90 degrees)
--No matter how fast the robot is pushed / pulled, the legs can always keep up
--The robot is hovering compared to the shape it is standing on, so it can travel on a vehicle for example
--There is no jiggliness due to transferring forces from foot to lower leg to uppwer leg to body
--very hard to fully knock over
--The time to get up is based on the time since in the air, not from the time spent on the ground
--The torso is being animated by "hovering" on whatever it is standing on
--The feet movement will be added later
--Each type of function is separated, for example hoverFloat only affects
--the vertical position, hoverUpright only affects the leaning

--Balancing function template
--There is a finite force applied to reach a finite (angular) velocity to get closer to the desired positon / angle
--d: the amount of difference of the current position from the ideal position
--v: ideal velocity to move toward the ideal position
--f: max allowed force to to move toward ideal
--Both v and f go down when very close to ideal, to avoid overshooting or jittering around
--there is a maximum limit on how fast it can move toward ideal, and in some cases there is a minimum limit too
--There is a padding distance where f and v gradually go up to the maximum. 
--Too high and it is still slow to react even at a big distance
--too low and it will jump around / overshoot

--Changes from Vanilla
--Current speed checks whether it's moving forward or backward, fixes the bug where it could barely stop when pushed backward by a large force

--This function finds the robot axes to determine which way it is facing
--the axes are right, up, back. (as back is the default, each other functions convert this to forward)
RIGHT = 1
UP = 2
FORWARD = 3
function robotSetAxes()
	robot.transform = TransformCopy(GetBodyTransform(robot.body))
	robot.basetransform = TransformCopy(robot.transform)
	robot.basetransform.pos = VecAdd(robot.basetransform.pos,Vec(0,-UpwardOffset,0))

	robot.axes[RIGHT] = TransformToParentVec(robot.basetransform , Vec(1, 0, 0))
	robot.axes[UP] = TransformToParentVec(robot.basetransform , Vec(0, 1, 0))
	robot.axes[FORWARD] = TransformToParentVec(robot.basetransform , Vec(0, 0, -1))
end

function robotTurnTowards(pos)
	robot.dir = VecNormalize(VecSub(pos, robot.basetransform .pos))
end

function robotSetDirAngle(angle)
	robot.dir[1] = math.cos(angle)
	robot.dir[3] = math.sin(angle)
end

function robotGetDirAngle()
	return math.atan2(robot.dir[3], robot.dir[1])
end

hover = {}
--The body the robot is standing on, and is moving compared to this body
--It has to be a large body to be applicable, tiny debris doesn't count as something to stand on
hover.hitBody = 0
--This is like a footing factor. When falling hover.contact is 0, and it can't walk / hover / turn etc
--When a bit far from the ground it goes down gradually, reducing effectiveness of various movement related things (move, hover, turn etc)
hover.contact = 0.0
--Target distance between feet and the transform of the main body (how high it will stand)
--if set to 0 defaults based on the position of feet
hover.distTarget = 1.1
--When the robot is falling / has no ground, footing is not lost immediately, it is lost gradually within this padding distance
--Distance padding is the distance where hover.contact is gradually lost whnen moving further away from the ground
hover.distPadding = 0.3
--If the robot is falling / flying, this measures the time since its foot was last on the ground
--once a long enough time passed without contact, it will try to get up
hover.timeSinceContact = 0.0


function hoverInit()
	local f = FindBodies("foot")
	if #f > 0 then
		hover.distTarget = 0
		for i=1, #f do
			local ft = GetBodyTransform(f[i])
			local fp = TransformToLocalPoint(robot.transform, ft.pos)
			hover.distTarget = math.max(hover.distTarget, -fp[2])
		end
	else
		QueryRequire("physical large")
		rejectAllBodies(robot.allBodies)
		local maxDist = 1.0
		
		local hit, dist = QueryRaycast(robot.transform.pos, VecScale(robot.axes[UP], -1), maxDist)
		if hit then
			hover.distTarget = dist
			hover.distPadding = math.min(0.3, dist*0.5)
		end
	end

end

--0.2 in vanilla, makes sure that the max possible force that can act on the torso never goes to 0, as long as feet touch the ground
--not sure what it affects at different values
ConstantLiftForceFraction = 0.2
--MaxHoverOffset is a buffer area for the upward standing force. While this close or closer to ideal standing height, both max velocity and force go down for standing
--0.2 in vanilla
MaxHoverOffset = 0.2
MaxUpwardVelocity = 2 --how fast max can go up to reach standing height during normal walking. 2 in vanilla
--for standing, ie upward force, not to fall on the ground
function hoverFloat()
	if hover.contact > 0 then --only if there's something to stand on
		--0.2 here is a buffer area for the upward standing force. 
		--While this close or closer to ideal standing height, both max velocity and force go down for standing, not to overshoot within this range
		--UpwardOffset for moving up and down with steps
		local d = clamp(hover.distTarget - hover.currentDist, -0.2, 0.2)
		--10 here is related to the max upward velocity: how fast max can go up to reach standing height during normal walking. 
		--at v= d*2, max velocity is 2 m/s in vanilla
		local v = MaxUpwardVelocity* d / MaxHoverOffset

		local f = hover.contact * math.max(0, d*robot.mass/MaxHoverOffset) + robot.mass*ConstantLiftForceFraction
		--hover float force only affects velocity in the worldspace upward direction
		ConstrainVelocity(robot.body, hover.hitBody, robot.bodyCenter, Vec(0,1,0), v, 0 , f)
	end
end

--Keeps the robot always balanced, so the top is facing upright, even when falling
UPRIGHT_STRENGTH = 1.0	--Spring strength
UPRIGHT_MAX = 0.3		--Max spring force: at 0.3 it can barely recover from a large angle difference (before weakening)
UPRIGHT_BASE = 0.1		--Fraction of max spring force to always apply (less springy): At low values it may take longer to reach equilibrium, at high value it's stable
SPEED_FACTOR = 10   	--affects how fast max angular velocity goes up with angle from upright
MAX_ANGVEL_UPRIGHT = 3  --max velocity swinging back when far away
function hoverUpright()
	local up = VecCross(robot.axes[UP], VecAdd(Vec(0,1,0))) --VecAdd is used sometime effectively to create a copy of the variable rather than a reference
	axes = {}
	axes[RIGHT] = Vec(1,0,0)
	axes[UP] = Vec(0,1,0)
	axes[FORWARD] = Vec(0,0,-1)
	for a = 1, 3, 2 do
		local d = VecDot(up, axes[a])
		--factor of d affects how fast max angular velocity goes up with distance
		--2: max velocity swinging back when far away
		local v = math.clamp(d * SPEED_FACTOR, -MAX_ANGVEL_UPRIGHT, MAX_ANGVEL_UPRIGHT)
		local f = math.clamp(math.abs(d)*UPRIGHT_STRENGTH, -UPRIGHT_MAX, UPRIGHT_MAX)
		f = f + UPRIGHT_MAX * UPRIGHT_BASE
		f = f * robot.mass
		f = f * hover.contact^3
		--f = 10000
		ConstrainAngularVelocity(robot.body, hover.hitBody, axes[a], v, -f , f)
	end
end

--almost same as hoverUpright, with the difference that this is not dependent on hover.contact
--Once spent 3 seconds with no ground underneath, (in robot space) it will get up: change leaning to be upright
--Designed to stop being stuck by falling on the head (thus having no floor at legs)
--As a side effect it will also balance being tossed through the air for too long
--As a side effect every few seconds it leans upward when hanging by the leg
function hoverGetUp()
	local up = VecCross(robot.axes[UP], VecAdd(Vec(0,1,0)))
	axes = {}
	axes[1] = Vec(1,0,0)
	axes[2] = Vec(0,1,0)
	axes[3] = Vec(0,0,-1)
	for a = 1, 3, 2 do
		local d = VecDot(up, axes[a])
		local v = math.clamp(d * SPEED_FACTOR, -MAX_ANGVEL_UPRIGHT, MAX_ANGVEL_UPRIGHT)
		local f = math.clamp(math.abs(d)*UPRIGHT_STRENGTH, -UPRIGHT_MAX, UPRIGHT_MAX)
		f = f + UPRIGHT_MAX * UPRIGHT_BASE
		f = f * robot.mass
		ConstrainAngularVelocity(robot.body, hover.hitBody, axes[a], v, -f , f)
	end
end

--Yaw: turning left and right to follow target
TURNING_DISTANCE_FACTOR = 0.1 --close to target it turns slow, this number relates to how far of an angle the target needs to be to reach the max turning rate
TURNING_MAX_ACCELERATION = 0.2 --Related to maximum acceleration for turning, (adding this velocity each frame to reach the ideal velocity, 0.2 from vanilla
function hoverTurn()
	local d = VecFacingDifference(robot.axes[FORWARD], robot.dir, robot.axes[RIGHT],Vec(0,1,0))
	FaceDiff = d --facing difference used later
	--existing angular velocity
	local curr = VecDot(robot.axes[UP], GetBodyAngularVelocity(robot.body))

	local angVel = clamp(d/TURNING_DISTANCE_FACTOR, -config.turnSpeed * robot.speedScale, config.turnSpeed * robot.speedScale)

	angVel = curr + clamp(angVel - curr, -TURNING_MAX_ACCELERATION*robot.speedScale, TURNING_MAX_ACCELERATION*robot.speedScale)

	local f = robot.mass*0.5 * hover.contact
	ConstrainAngularVelocity(robot.body, hover.hitBody, robot.axes[UP], angVel, -f , f)
end

--sideways movement
--The point chosen here (robot.bodyCenter) on which forces apply, is the point that generally remains fixed and stable
--as it is the center of mass, the robot is very stable 
MovementAccelerationForceFactor = 0.2 --related to the max force for sideways acceleration
MovementAccelerationSpeedFactor = 0.05 --related to max desired speed change for sideways acceleration
function hoverMove()
	--robot.speed: Basic core speed eg how fast the robot wants to move now
	--robot.speed is already has speedscale inside: 
	--speedScale (not shown here), makes it move forward slower when also turning, so it can turn in almost in place (small turning radius)
	--robot.speedScale: a factor (1 by default) for the current activity, eg moving 60% faster when chasing, compared to patrolling
	local MovementLoc = robot.bodyCenter --This is a fixed point around which it pivots, center of mass in vanilla for mblaance
	local desiredSpeed = robot.speed * robot.speedScale --desired speed, negative backward
	local fwd = robot.axes[FORWARD]
	fwd[2] = 0
	fwd = VecNormalize(fwd)
	local side = VecCross(Vec(0,1,0), fwd)
	--Current speed along the forward direction. Does not differentiate forward / backward
	local CurrVelocity = GetBodyVelocityAtPos(robot.body, MovementLoc)
	local currSpeed = VecDot(fwd, CurrVelocity) 
	--Check if the current is in the backward direction and make it negative, to fix the bug where it can barely stop when pushed backward at high speeds
	if 	VectorFacingAwayApproximation5(fwd, VecNormalize(CurrVelocity)) then
		currSpeed = -1* currSpeed
	end
	local speed = currSpeed + clamp(desiredSpeed - currSpeed, -MovementAccelerationSpeedFactor*robot.speedScale, MovementAccelerationSpeedFactor*robot.speedScale)
	
	local f = robot.mass*MovementAccelerationForceFactor * hover.contact

	ConstrainVelocity(robot.body, hover.hitBody, MovementLoc, fwd, speed, -f , f) --reach desired speed forward / backward
	ConstrainVelocity(robot.body, hover.hitBody, MovementLoc, robot.axes[RIGHT], 0, -f , f) --Stop sideways movement
end

--This code is 
--1: determining current standing height
--2: limiting angular velocity
--3: calling all the prior functions

--The standing height is the average of 5 points, each is a raycast from the robot torso,
--downward in local space (eg if the torso is at an angle, then raycast is at an angle)
--the 5 points are: center of mass, forward, backward, left, right, each of them is BALANCE_RADIUS from the center
--this height will be used to determine hover.contact, which determines the effectiveness of hover (how fast and hard it can move)
BALANCE_RADIUS = 0.4
HOVER_CAST_RADIUS = 0.1 --radius of raycast, I assume to avoid small 2x2 voxel holes counting as no ground
function hoverUpdate(dt)
	local dir = VecScale(robot.axes[UP], -1)

	--Shoot rays from four locations downwards
	local hit = false
	local dist = 0
	local normal = Vec(0,0,0)
	local shape = 0
	local samples = {}
	samples[#samples+1] = Vec(-BALANCE_RADIUS,0,0)
	samples[#samples+1] = Vec(BALANCE_RADIUS,0,0)
	samples[#samples+1] = Vec(0,0,BALANCE_RADIUS)
	samples[#samples+1] = Vec(0,0,-BALANCE_RADIUS)
	
	local maxDist = hover.distTarget + hover.distPadding
	for i=1, #samples do
		QueryRequire("physical large")
		rejectAllBodies(robot.allBodies)
		local origin = VecAdd(robot.basetransform.pos , samples[i])
		local rhit, rdist, rnormal, rshape = QueryRaycast(origin, dir, maxDist, HOVER_CAST_RADIUS)
		
		if rhit then
			hit = true
			dist = dist + rdist + HOVER_CAST_RADIUS
			if rdist == 0 then
				--Raycast origin in geometry, normal unsafe. Assume upright
				rnormal = Vec(0,1,0)
			end
			if shape == 0 then
				shape = rshape
			else
				local b = GetShapeBody(rshape)
				local bb = GetShapeBody(shape)
				--Prefer new hit if it's static or has more mass than old one
				if not IsBodyDynamic(b) or (IsBodyDynamic(bb) and GetBodyMass(b) > GetBodyMass(bb)) then
					shape = rshape
				end
			end
			normal = VecAdd(normal, rnormal)
		else
			dist = dist + maxDist
		end
	end
	
	--Use average of rays to determine contact and height
	if hit then
		--deterimned height from 5 points. robot body transform and 4 points around in robot space, pointing down in robot local space
		dist = dist / #samples
		
		normal = VecNormalize(normal)
		hover.hitBody = GetShapeBody(shape)
		if IsBodyDynamic(hover.hitBody) and GetBodyMass(hover.hitBody) < 300 then
			--Hack alert! Treat small bodies as static to avoid sliding and glitching around on debris
			hover.hitBody = 0
		end
		hover.currentDist = dist
		--contact goes down when too far from ground
		hover.contact = clamp(1.0 - (dist - hover.distTarget) / hover.distPadding, 0.0, 1.0)
		--contact goes down when the ground is at a high angle (assumes that the robot is upright)
		local d = 1-normal[2]
		hover.contact = hover.contact * math.max(0, 1-d)
	else
		hover.hitBody = 0
		hover.currentDist = maxDist
		hover.contact = 0
	end

	--Limit body angular velocity magnitude to 10 rad/s at max contact (not sure why)
	if hover.contact > 0 then
		local maxAngVel = 10.0 / hover.contact
		local angVel = GetBodyAngularVelocity(robot.body)
		local angVelLength = VecLength(angVel)
		if angVelLength > maxAngVel then
			SetBodyAngularVelocity(robot.body, VecScale(maxAngVel / angVelLength))
		end
	end
	
	if hover.contact > 0 then
		hover.timeSinceContact = 0
	else
		hover.timeSinceContact = hover.timeSinceContact + dt
	end

	hoverFloat()
	hoverUpright()
	hoverTurn()
	hoverMove()
end

