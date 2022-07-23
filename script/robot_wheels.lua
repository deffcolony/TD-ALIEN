--When the robot has wheels instead of legs they are managed here
--The pathfinding is also different as it can't step over so many things

wheels = {}
wheels.bodies = {}
wheels.transforms = {}
wheels.radius = {}

function wheelsInit()
	wheels.bodies = FindBodies("wheel")
	for i=1, #wheels.bodies do
		local t = GetBodyTransform(wheels.bodies[i])
		local shape = GetBodyShapes(wheels.bodies[i])[1]
		local sx, sy, sz = GetShapeSize(shape)
		wheels.transforms[i] = TransformToLocalTransform(robot.transform, t)
		wheels.radius[i] = math.max(sx, sz)*0.05
	end
end

function wheelsUpdate(dt)
	for i=1, #wheels.bodies do
		local v = GetBodyVelocityAtPos(robot.body, TransformToParentPoint(robot.transform, wheels.transforms[i].pos))
		local lv = VecDot(robot.axes[FORWARD], v)
		if hover.contact > 0 then
			local shapes = GetBodyShapes(wheels.bodies[i])
			if #shapes > 0 then
				local joints = GetShapeJoints(shapes[1])
				if #joints > 0 then
					local angVel = lv / wheels.radius[i]
					SetJointMotor(joints[1], angVel, 100)
				end
			end
			PlayLoop(rollLoop, robot.transform.pos, clamp(math.abs(lv)*0.5, 0.0, 1.0))
		end
	end
end