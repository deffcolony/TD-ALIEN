--From vanilla robot script the core functions such as init and update etc, setting up bodies

------------------------------------------------------------------------------------
-- ROBOT SCRIPT
------------------------------------------------------------------------------------
--[[

The robot script should be parent of all bodies that make up the robot. 
Configure the robot with the type parameter that can be combinations of the following words:
investigate: investigate sounds in the environment
chase: chase player when seen, this is the most common configuration
nooutline: no outline when close and hidden
alarm: trigger alarm when player is seen and lit by light for 2.0 seconds 
stun: electrocute player when close or grabbed
avoid: avoid player (should not be combined chase, requires patrol locations)
aggressive: always know where player is (even through walls)

The following robot parts are supported:

body (type body: required)
This is the main part of the robot and should be the hevaiest part

head (type body: required)
The head should be jointed to the body (hinge joint with or without limits). 
heardist=<value> - Maximum hearing distance in meters, default 100

eye (type light: required)
Represents robot vision. The direction of light source determines what the robot can see. Can be placed on head or body
viewdist=<value> - View distance in meters. Default 25.
viewfov=<value> - View field of view in degrees. Default 150.

aim (type body: optional)
This part will be directed towards the player when seen and is usually equipped with weapons. Should be jointed to body or head with ball joint. There can be multiple aims.

wheel (type body: optional, should be static with no collisions)
If present wheels will rotate along with the motion of the robot. There can be multiple wheels.

leg (type body: optional)
Legs should be jointed between body and feet. All legs will have collisions disabled when walking and enabled in rag doll mode. There can be multiple legs.

foot (type body: optional)
Foot bodies are animated with respect to the body when walking. They only collide with the environment in rag doll mode.
tag force - Movement force scale, default is 1. Can also be two values to separate linear and angular, for example: 2,0.5

weapon (type location: optional)
Usually placed on aim head or body. There are several types of weapons:
weapon=fire - Emit fire when player is close and seen
weapon=gun - Regular shot
weapon=rocket - Fire rockets
strength=<value> - The scaling factor which controls how much damage it makes (default is 1.0)
The following tags are used to control the weapon behavior (only affect gun and rocket):
idle=<seconds> - Idle time in between rounds
charge=<seconds> - Charge time before firing
cooldown=<seconds> - Cooldown between each shot in a round
count=<number> - Number of shots in a round
spread=<fraction> - How much each shot may deviates from optimal direction (for instance: 0.05 to deviate up to 5%)
maxdist=<meters> - How far away target can be to trigger shot. Default is 100

patrol (type location: optional)
If present the robot will patrol these locations. Make sure to place near walkable ground. Targets are visited in the same order they appear in scene explorer. Avoid type robots MUST have patrol targets.

roam (type trigger: optional)
If there are no patrol locations, the robot will roam randomly within this trigger.

limit (type trigger: optional)
If present the robot will try stay within this trigger volume. If robot ends up outside trigger, it will automatically navigate back inside.

investigate (type trigger: optional)
If present and the robot has type investigate it will only react to sounds within this trigger.

activate (type trigger: optional)
If present, robot will start inactive and become activated when player enters trigger
]]
------------------------------------------------------------------------------------

--[[
#include "robot_common.lua"
#include "robot_damage.lua"
#include "robot_feet.lua"
#include "robot_hover.lua"
#include "robot_navigate.lua"
#include "robot_senses.lua"
#include "robot_weapons.lua"
#include "robot_wheels.lua"
#include "robot_AI.lua"
#include "robot_testing.lua"
#include "robot_health.lua"
#include "acid.lua"
]]

pType = GetStringParam("type", "")
pSpeed = GetFloatParam("speed", 9.9)
pTurnSpeed = GetFloatParam("turnspeed", pSpeed)

config = {}
config.hasVision = false
config.viewDistance = 150
config.viewFov = 150
config.canHearPlayer = false
config.canSeePlayer = false
config.patrol = false
config.sensorDist = 5.0
config.speed = pSpeed
config.turnSpeed = pTurnSpeed
config.huntPlayer = false
config.huntSpeedScale = 1.6
config.avoidPlayer = false
config.triggerAlarmWhenSeen = false
config.visibilityTimer = 0.3 --Time player must be seen to be identified as enemy (ideal condition)
config.lostVisibilityTimer = 5.0 --Time player is seen after losing visibility
config.outline = 13
config.aimTime = 5.0
config.maxSoundDist = 500.0
config.aggressive = false
config.stepSound = "m"
config.practice = false

PATH_NODE_TOLERANCE = 0.8

function configInit()
	local eye = FindLight("eye")
	local head = FindBody("head")
	config.patrol = FindLocation("patrol") ~= 0
	config.hasVision = eye ~= 0
	config.viewDistance = getTagParameter(eye, "viewdist", config.viewDistance)
	config.viewFov = getTagParameter(eye, "viewfov", config.viewFov)
	config.maxSoundDist = getTagParameter(head, "heardist", config.maxSoundDist)
	if hasWord(pType, "investigate") then
		config.canHearPlayer = true
		config.canSeePlayer = true
	end
	if hasWord(pType, "chase") then
		config.canHearPlayer = true
		config.canSeePlayer = true
		config.huntPlayer = true
	end
	if hasWord(pType, "avoid") and config.patrol then
		config.avoidPlayer = true
		config.canSeePlayer = true
	end
	if hasWord(pType, "alarm") then
		config.triggerAlarmWhenSeen = true
	end
	if hasWord(pType, "nooutline") then
		config.outline = 0
	end
	if hasWord(pType, "aggressive") then
		config.aggressive = true
	end
	if hasWord(pType, "practice") then
		config.canSeePlayer = true
		config.practice = true
	end
	local body = FindBody("body")
	if HasTag(body, "stepsound") then
		config.stepSound = GetTagValue(body, "stepsound")
	end
end


robot = {}
robot.body = 0
robot.transform = Transform() --actual transform of the robot after secondary animation is applied
robot.basetransform = Transform() --ideal base transform of the robot, where it would be without applying secondary animation (simpler for various calculations)
robot.axes = {}
robot.bodyCenter = Vec()
robot.navigationCenter = Vec()
robot.dir = Vec(0, 0, -1)
robot.speed = 0
robot.blocked = 0
robot.mass = 0
robot.allBodies = {}
robot.allShapes = {}
robot.allJoints = {}
robot.initialBodyTransforms = {}
robot.enabled = true
robot.deleted = false
robot.speedScale = 1
robot.breakAll = false
robot.breakAllTimer = 0
robot.distToPlayer = 100
robot.dirToPlayer = 0
robot.roamTrigger = 0
robot.limitTrigger = 0
robot.investigateTrigger = 0
robot.activateTrigger = 0
robot.stunned = 0
robot.outlineAlpha = 0
robot.canSensePlayer = false
robot.playerPos = Vec()


function robotInit()

	HealthInit()

	robot.body = FindBody("body")
	robot.allBodies = FindBodies()
	robot.allShapes = FindShapes()
	robot.allJoints = FindJoints()
	robot.roamTrigger = FindTrigger("roam")
	robot.limitTrigger = FindTrigger("limit")
	robot.investigateTrigger = FindTrigger("investigate")
	robot.activateTrigger = FindTrigger("activate")
	if robot.activateTrigger ~= 0 then
		SetTag(robot.body, "inactive")
	end
	for i=1, #robot.allBodies do
		robot.initialBodyTransforms[i] = GetBodyTransform(robot.allBodies[i])
	end

	UpwardOffset = 0 --for moving up and down while walking
	robotSetAxes()
end

function robotUpdate(dt)
	robotSetAxes()

	if config.practice then
		local pp = GetPlayerCameraTransform().pos
		local pt = FindTrigger("practicearea")
		if pt ~= 0 and IsPointInTrigger(pt, pp) then
			robot.playerPos = VecCopy(pp)
			if not stackHas("navigate") then
				robotTurnTowards(robot.playerPos)
			end
		else
			local overrideTarget = FindBody("practicetarget", true)
			if overrideTarget ~= 0 then
				robot.playerPos = GetBodyTransform(overrideTarget).pos
				if not stackHas("navigate") then
					robotTurnTowards(robot.playerPos)
				end
			else
				robot.playerPos = Vec(0, -100, 0)
			end
		end
	else
		robot.playerPos = GetPlayerCameraTransform().pos
	end
	
	local vel = GetBodyVelocity(robot.body)
	local fwdSpeed = VecDot(vel, robot.dir)
	local blocked = 0
	if robot.speed > 0 and fwdSpeed > -0.1 then
		--blocked if actual speed is much slower than desired speed (had hard limit on blocked speed before making it not work at low desired speeds)
		blocked = 1.0 - clamp(fwdSpeed/robot.speed*7, 0.0, 1.0)
	end
	robot.blocked = robot.blocked * 0.95 + blocked * 0.05

	--Always blocked if fall is detected
	if sensor.detectFall > 0 then
		robot.blocked = 1.0
	end

	--Evaluate mass every frame since robots can break
	robot.mass = 0
	local bodies = FindBodies()
	for i=1, #bodies do
		robot.mass = robot.mass + GetBodyMass(bodies[i])
	end
	
	robot.bodyCenter = TransformToParentPoint(robot.transform, GetBodyCenterOfMass(robot.body))
	robot.navigationCenter = TransformToParentPoint(robot.basetransform, Vec(0, -hover.distTarget, 0))

	--Handle break all
	robot.breakAllTimer = math.max(0.0, robot.breakAllTimer - dt)
	if not robot.breakAll and robot.breakAllTimer > 0.0 then
		for i=1, #robot.allShapes do
			SetTag(robot.allShapes[i], "breakall")
		end
		robot.breakAll = true
	end
	if robot.breakAll and robot.breakAllTimer <= 0.0 then
		for i=1, #robot.allShapes do
			RemoveTag(robot.allShapes[i], "breakall")
		end
		robot.breakAll = false
	end
	
	--Distance and direction to player
	local pp = VecAdd(GetPlayerTransform().pos, Vec(0, 1, 0))
	local d = VecSub(pp, robot.bodyCenter)
	robot.distToPlayer = VecLength(d)
	robot.dirToPlayer = VecScale(d, 1.0/robot.distToPlayer)
	
	--Sense player if player is close and there is nothing in between
	robot.canSensePlayer = false
	if robot.distToPlayer < 3.0 then
		rejectAllBodies(robot.allBodies)
		if not QueryRaycast(robot.bodyCenter, robot.dirToPlayer, robot.distToPlayer) then
			robot.canSensePlayer = true
		end
	end

	--Robot body sounds
	if robot.enabled and hover.contact > 0 then
		local vol
		vol = clamp(VecLength(GetBodyVelocity(robot.body)) * 0.4, 0.0, 1.0)
		if vol > 0 then
			--PlayLoop(walkLoop, robot.transform.pos, vol)
		end

		vol = clamp(VecLength(GetBodyAngularVelocity(robot.body)) * 0.4, 0.0, 1.0)
		if vol > 0 then
			--PlayLoop(turnLoop, robot.transform.pos, vol)
		end
	end
end


function init()
	configInit()
	robotInit()
	hoverInit()
	headInit()
	sensorInit()
	wheelsInit()
	feetInit()
	aimsInit()
	weaponsInit()
	navigationInit()
	hearingInit()
	stackInit()
	initAcid()

	patrolLocations = FindLocations("patrol")
	shootSound = LoadSound("tools/gun0.ogg", 8.0)
	rocketSound = LoadSound("tools/launcher0.ogg", 7.0)
	local nomDist = 7.0
	if config.stepSound == "s" then nomDist = 5.0 end
	if config.stepSound == "l" then nomDist = 9.0 end
	stepSound = LoadSound("robot/step-" .. config.stepSound .. "0.ogg", nomDist)
	headLoop = LoadLoop("MOD/main/snd/villager/woman.ogg", 7.0)
	turnLoop = LoadLoop("MOD/main/snd/villager/m3.ogg", 7.0)
	walkLoop = LoadLoop("robot/walk-loop.ogg", 7.0)
	rollLoop = LoadSound("MOD/main/snd/villager/midle2.ogg")
	chargeLoop = LoadLoop("robot/charge-loop.ogg", 8.0)
	alertSound = LoadSound("MOD/main/snd/villager/m1.ogg", 9.0)
	huntSound = LoadSound("MOD/main/snd/hunt0.ogg", 15.0)
	idleSound = LoadSound("MOD/main/snd/villager/midle0.ogg")
	fireLoop = LoadLoop("tools/blowtorch-loop.ogg")
	disableSound = LoadSound("robot/disable0.ogg")

	crush = LoadSound("MOD/main/snd/bite1.ogg", 9.0)
	crush2 = LoadSound("MOD/main/snd/bite.ogg", 9.0)
	insound = LoadSound("MOD/main/snd/in01.ogg", 9.0)
	swing = LoadSound("MOD/main/snd/swng07.ogg", 9.0)
    fdeath = LoadSound("MOD/main/snd/ldeath0.ogg", 9.0)
    pain = LoadSound("MOD/main/snd/pain0.ogg", 9.0)
	pain2 = LoadSound("MOD/main/snd/fluid.ogg", 9.0)
end


function update(dt)
	if robot.deleted then 
		return
	else 
		if not IsHandleValid(robot.body) then
			for i=1, #robot.allBodies do
				Delete(robot.allBodies[i])
			end
			for i=1, #robot.allJoints do
				Delete(robot.allJoints[i])
			end
			robot.deleted = true
		end
	end

	if IsBodyDynamic(robot.body)==false then return end --pause calculations if another mod freezes time

	if robot.activateTrigger ~= 0 then 
		if IsPointInTrigger(robot.activateTrigger, GetPlayerCameraTransform().pos) then
			RemoveTag(robot.body, "inactive")
			robot.activateTrigger = 0
		end
	end
	
	if HasTag(robot.body, "inactive") then
		robot.inactive = true
		return
	else
		if robot.inactive then
			robot.inactive = false
			--Reset robot pose
			local sleep = HasTag(robot.body, "sleeping")
			for i=1, #robot.allBodies do
				SetBodyTransform(robot.allBodies[i], robot.initialBodyTransforms[i])
				SetBodyVelocity(robot.allBodies[i], Vec(0,0,0))
				SetBodyAngularVelocity(robot.allBodies[i], Vec(0,0,0))
				if sleep then
					--If robot is sleeping make sure to not wake it up
					SetBodyActive(robot.allBodies[i], false)
				end
			end
		end
	end

	if HasTag(robot.body, "sleeping") then
		if IsBodyActive(robot.body) then
			wakeUp = true
		end
		local vol, pos = GetLastSound()
		if vol > 0.2 then
			if robot.investigateTrigger == 0 or IsPointInTrigger(robot.investigateTrigger, pos) then
				wakeUp = true
			end
		end	
		if wakeUp then
			RemoveTag(robot.body, "sleeping")
		end
		return
	end

	robotUpdate(dt)
	wheelsUpdate(dt)

	if not robot.enabled then
		return
	end

	if IsPointInWater(robot.bodyCenter) then
		--PlaySound(disableSound, robot.bodyCenter, 1.0, false)
		for i=1, #robot.allShapes do
			SetShapeEmissiveScale(robot.allShapes[i], 0)
		end
		SetTag(robot.body, "disabled")
		robot.enabled = false
	end
	
	robot.stunned = clamp(robot.stunned - dt, 0.0, 1000.0)
	if robot.stunned > 0 then
		head.seenTimer = 0
		weaponsReset()
		return
	end
	
	hoverUpdate(dt)
	feetUpdate(dt)
	HealthUpdate(dt)
	headUpdate(dt)
	sensorUpdate(dt)
	aimsUpdate(dt)
	weaponsUpdate(dt)
	hearingUpdate(dt)
	stackUpdate(dt)
	robot.speedScale = 1
	robot.speed = 0

	ManageState(dt)
	ParticlePhysics()
end

function tick(dt)
	if not robot.enabled then
		return
	end
	
	if HasTag(robot.body, "turnhostile") then
		RemoveTag(robot.body, "turnhostile")
		config.canHearPlayer = true
		config.canSeePlayer = true
		config.huntPlayer = true
		config.aggressive = true
		config.practice = false
	end
	
	--Outline
	local dist = VecDist(robot.bodyCenter, GetPlayerCameraTransform().pos)
	if dist < config.outline then
		local a = clamp((config.outline - dist) / 5.0, 0.0, 1.0)
		if canBeSeenByPlayer() then
			a = 0
		end
		robot.outlineAlpha = robot.outlineAlpha + clamp(a - robot.outlineAlpha, -0.1, 0.1)
		for i=1, #robot.allBodies do
			DrawBodyOutline(robot.allBodies[i], 1, 1, 1, robot.outlineAlpha*0.5)
		end
	end
	
	if IsBodyDynamic(robot.body)==false then return end --pause calculations if another mod freezes time

	--Remove planks and wires after some time
	local tags = {"plank", "wire"}
	local removeTimeOut = 10
	for i=1, #robot.allShapes do
		local shape = robot.allShapes[i]
		local joints = GetShapeJoints(shape)
		for j=1, #joints do
			local joint = joints[j]
			for t=1, #tags do
				local tag = tags[t]
				if HasTag(joint, tag) then
					local t = tonumber(GetTagValue(joint, tag)) or 0
					t = t + dt
					if t > removeTimeOut then
						if GetJointType(joint) == "rope" then
							DetachJointFromShape(joint, shape)
						else
							Delete(joint)
						end
						break
					else
						SetTag(joint, tag, t)
					end
				end
			end
		end
	end

	if GetPlayerHealth() <= 0 then
		if not playing then
			PlaySound(crush, robot.bodyCenter, 10, false)
			PlaySound(crush2, robot.bodyCenter, 10, false)
			--PlaySound(swing)
			playing = true
		end
	elseif GetPlayerHealth() >= 0 then
		if playing then
			playing = false
		end
	end
end

