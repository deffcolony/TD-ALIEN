
--few functions added to aid testing, nothing too important

--config functions go in config init to change behaviour for testing
function configSlow()
    local SlowingFactor = 10
    config.speed = config.speed/SlowingFactor
    MAX_STEP_TIME = MAX_STEP_TIME * SlowingFactor
    LEG_DIST_FACTOR = LEG_DIST_FACTOR * SlowingFactor
end

--to be called in feet update to see how step fractions work
function DebugFeetState(stepTime)
	local inStep = false
    local DebugMsg = ""

	for i=1, #feet do
		local StepFraction = feet[i].stepAge/feet[i].stepLifeTime
		if feet[i].stepLifeTime > stepTime then
			feet[i].stepLifeTime = stepTime
		end
		if StepFraction < 0.8 then
			inStep = true
		end

        if i ~= 1 then
            DebugMsg = DebugMsg .. "|"
        end
        DebugMsg = DebugMsg .. FormatNo(StepFraction,2)
	end
    DebugPrint(DebugMsg)
end

function FormatNo(flt, decimals)
	if decimals == nil then decimals = 2 end
	if flt  == nil then return "" end
	IsNeg = flt < 0
	OutNo = math.abs(flt)


	OutNo = math.floor(OutNo * 10^decimals)/(10^decimals)
	if OutNo == 0 then IsNeg = false end

	local output = OutNo

	local Sign = " "
	if IsNeg then Sign = "-" end
	output = Sign .. output

	--decimals
	Remainder = OutNo*100 - math.floor(OutNo)*100
	if Remainder ==0 then output = output .. ".0" end
	if Remainder %10 == 0 then output = output .. "0" end

	--space for >10
	if OutNo<10 then output = output .. " " end
	--if OutNo == 0 then output = " 0.00" end


	return output
end

function DrawRayCast(origin, dir, rhit, rdist, maxDist)
	local dist = 0
	if rhit then
		dist = rdist
	else
		dist = maxDist
	end
	local hitpos = VecAdd(origin,VecScale(VecNormalize(dir),dist))

	if rhit then
		DrawLine(origin,hitpos,0,1,0)
	else
		DrawLine(origin,hitpos,1,1,1)
	end
end