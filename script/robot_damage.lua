--Handling damage. In vanilla this is only knockback from shots and explosions, as there's no voxeldamage on robots
function handleCommand(cmd)
	words = splitString(cmd, " ")
	if #words == 5 then
		if words[1] == "explosion" then
			local strength = tonumber(words[2])
			local x = tonumber(words[3])
			local y = tonumber(words[4])
			local z = tonumber(words[5])
			hitByExplosion(strength, Vec(x,y,z))
			
		end
	end
	if #words == 8 then
		if words[1] == "shot" then
			local strength = tonumber(words[2])
			local x = tonumber(words[3])
			local y = tonumber(words[4])
			local z = tonumber(words[5])
			local dx = tonumber(words[6])
			local dy = tonumber(words[7])
			local dz = tonumber(words[8])
			hitByShot(strength, Vec(x,y,z), Vec(dx,dy,dz))
			
		end
	end
end

function hitByExplosion(strength, pos)
	if not robot.enabled then
		return
	end
	
	--Explosions smaller than 1.0 are ignored (with a bit of room for rounding errors)
	if strength > 0.99 then
		local d = VecDist(pos, robot.bodyCenter)	
		local f = clamp((1.0 - (d-2.0)/6.0), 0.0, 1.0) * strength
		if f > 0.2 then
			robot.stunned = math.max(robot.stunned, f * 1.0)
		end
		
		ExplosionDamage(f)

		--Give robots an extra push if they are not already moving that much
		--Unphysical but more fun
		local maxVel = 7.0
		local strength = 3.0
		local dir = VecNormalize(VecSub(robot.bodyCenter, pos))
		--Tilt direction upwards to make them fly more
		dir[2] = dir[2] + 1.0
		dir = VecNormalize(dir)
		for i=1, #robot.allBodies do
			local b = robot.allBodies[i]
			local v = GetBodyVelocity(b)
			local scale = clamp(1.0-VecLength(v)/maxVel, 0.0, 1.0)
			local velAdd = math.min(maxVel, f*scale*strength)
			if velAdd > 0 then
				v = VecAdd(v, VecScale(dir, velAdd))
				SetBodyVelocity(b, v)
				ExplosionSound()
			end
		end
	end
end


function hitByShot(strength, pos, dir)
	ShotSeenTimer = MaxShotSeenTime
	if not robot.enabled then
		return
	end

	if VecDist(pos, robot.bodyCenter) < 3 then
		local hit, point, n, shape = QueryClosestPoint(pos, 0.1)
		if hit then
			for i=1, #robot.allShapes do
				if robot.allShapes[i] == shape then
					--robot.stunned = robot.stunned + 0.2
					ShotDamage(strength)
					return
				end
			end
		end
	end
end