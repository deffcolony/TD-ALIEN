--Functions from the vanilla robot that should be part of common.lua 
--(genral fucntions for helping with vector math / tags etc)

#include "script/common.lua"


function VecDist(a, b)
	return VecLength(VecSub(a, b))
end


function getTagParameter(entity, name, default)
	local v = tonumber(GetTagValue(entity, name))
	if v then
		return v
	else
		return default
	end
end

function getTagParameter2(entity, name, default)
	local s = splitString(GetTagValue(entity, name), ",")
	if #s == 1 then
		local v = tonumber(s[1])
		if v then
			return v, v
		else
			return default, default
		end
	elseif #s == 2 then
		local v1 = tonumber(s[1])
		local v2 = tonumber(s[2])
		if v1 and v2 then
			return v1, v2
		else
			return default, default
		end
	else
		return default, default
	end
end


function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function rnd(mi, ma)
	local v = math.random(0,1000) / 1000
	return mi + (ma-mi)*v
end

function rejectAllBodies(bodies)
	for i=1, #bodies do
		QueryRejectBody(bodies[i])
	end
end


function getPerpendicular(dir)
	local perp = VecNormalize(Vec(rnd(-1, 1), rnd(-1, 1), rnd(-1, 1)))
	perp = VecNormalize(VecSub(perp, VecScale(dir, VecDot(dir, perp))))
	return perp
end


--Taking 2 normalised imput vectors it checks if the 2D part ([1] and [3]) are facing away from each other
--facing away means being more than 90degrees difference between them
--it's a fast approximation that is accurate to 4.2 degrees (meaning between 85-95 degrees, it can get the facing wrong)
--only for worldspace yaw
--only works for normalised vectors (takes away from the efficiency gains if you need to normalize)
--I'm not sure if approximating here instead of using an exact solution speeds up the program by much.
--However exact solutions are for mathematicians, and I'm trained as an engineer. So I approximate.
function VectorFacingAwayApproximation5(VecA, VecB)
    local SameQuadrant = {}
    SameQuadrant[1] = (VecA[1]>0) == (VecB[1]>0)
    SameQuadrant[2] = (VecA[3]>0) == (VecB[3]>0)
    
	if SameQuadrant[1] and SameQuadrant[2] then
        return false
    end

    if SameQuadrant[1] == false and SameQuadrant[2] == false then
        return true
    end
    
    local SameDiff =0
    local OtherDiff =0
    
    if SameQuadrant[1] then
        SameDiff = math.abs(VecA[1] - VecB[1])
        OtherDiff = math.abs(VecA[3] - VecB[3])
	else
        OtherDiff = math.abs(VecA[3] - VecB[3])
        SameDiff = math.abs(VecA[1] - VecB[1])
    end
    
	--DebugPrint(VecStr(VecA) .. " " .. VecStr(VecB) .. " " .. SameDiff .. " " .. OtherDiff)

    return OtherDiff + SameDiff * 0.39 > 1.463
    --0, 1.23 works within 15 deg
    --0.39, 1.463 within 4.5 deg
end

--Returns the turning difference between 2 vectors along the turning axis
--It is 0 when they are facing same way, -0.5 when desired is exactly to right, +-1 when exactly behind
--Thus the result is going from 0 to +-1 is the angle facing away from the ideal direction, turning axis is the axis of rotation around which the angle is checked
function VecFacingDifference(CurrentVec,DesiredVec,CurrentRight,TurningAxis)
	--I'm not sure why the calculation is done like this
	--The vanilla version only checks up to d, for parallelity, thus facing away and same way look the same

	--cross product returns a vector perpendicular to both, based on interaction between the different dimensions
	local c = VecCross(CurrentVec,DesiredVec)
	--this goes from 0- +-1, -1 if target is to right, and keeps going back down to 0 as it moves to back
	--dot product is usually how "parallel" 2 unit vectors are
	local d = VecDot(c, TurningAxis) 
	local Result = 0

	--do the same calculation for the current right vector, this helps deciding if desired is at the back (on the right of the right vector)
	c = VecCross(CurrentRight,DesiredVec)
	local d2 = VecDot(c, TurningAxis) 

	--this part makes sure that the vectors facing away from each other are treated appropriately
	if d2>0 then
		Result = d
	else
		if d<0 then
			Result = -2 - d
		else
			Result = 2 - d
		end
	end

	Result = Result /2 --scale result to between -1 to 1
	return Result
end

--sets y axis of a vector to 0, effectively keeping the 2D projection on the x/z plane (used for locations)
function Vec2D(InputVector)
	return Vec(InputVector[1],0,InputVector[3])
end