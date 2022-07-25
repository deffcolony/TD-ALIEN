--just have to deal with the half thing: due to sideways angle on ground looking for collosion of the center

--maybe stick to moving surfaces?
--move away from close by particles

--[[
#include "acidoptions.lua"
--]]

function initAcid()
    InitialiseOptions()
    ShowOptions = false

    VoxelSize = 0.05 --tools are scaled at 1/2 voxel size
    --(Right Up Back toward player)
	--pitch up (x) turn left (y), roll left z
    ToolEndPointLoc = Vec(0*VoxelSize,25*VoxelSize,-20*VoxelSize) --I know from magica that my tool is 18 long and I assume it's origin corner is toward the player

    Error = Vec(0,0,0)

    HoleCounter = 0

    ConstantPoint = Vec(0,0,0)
    UseConstantTr = false
    shootPoint = Vec(0,0,0)
    ConstantDir = Quat()

    StickText = "Not Sticky"

    --particles
    Current = 1 --position of the particle going to be shot next
    CP = 0
    PartLife = {}
    PartVel = {}
    Pos = {}
    Radius = {}
    ClearParticles()

    CurrentP = 0

    --hole making 
    HoleUpdates1 = {}
    HoleUpdates2 = {}
    HoleUpdates3 = {}
    StartingUpdate1 = {}
    StartingUpdate2 = {}
    StartingUpdate3 = {}
    Counter1 = {}
    Counter2 = {}
    Counter3 = {}


    local SpeedFactor = 1
    for CurrentP = 1, Val[MaxParticles],1 do
        SpeedFactor = 1+Val[CorrosionSpeedRandomising]*(math.random()*2 -1) 
        HoleUpdates1[CurrentP] = math.floor(Val[CorrodeSoft] * SpeedFactor)
        HoleUpdates2[CurrentP] = math.floor(Val[CorrodeMedium] * SpeedFactor)
        HoleUpdates3[CurrentP] = math.floor(Val[CorrodeHard] * SpeedFactor)

        StartingUpdate1[CurrentP] = math.floor(math.random()*HoleUpdates1[CurrentP])
        StartingUpdate2[CurrentP] = math.floor(math.random()*HoleUpdates2[CurrentP])
        StartingUpdate3[CurrentP] = math.floor(math.random()*HoleUpdates3[CurrentP])

        Counter1[CurrentP] = 0
        Counter2[CurrentP] = 0 
        Counter3[CurrentP] = 0 
    end

    FrameTime = 1/60 *2-- *60*10
    GravityVector = Vec(0,-10/60,0)

    SlowMoCount = 0
    TimeStopped = false
    DebugParticles = false

    ShootSound = LoadLoop("MOD/AcidGun/bubbles.ogg")
    BurnSound = LoadLoop("MOD/AcidGun/sizzle.ogg")

    BurnCounter = 0

    FirstParticle = 0
    LastParticle = 0
end

--probably the particles should have special liquid sound
--in the future it should disappear after a while and then stop making holes
function GetAcid(shootPoint,AcidDirQuat)
    local PartSpawnCount = 20

                for p = 1 , PartSpawnCount,1 do
                    if Current > Val[MaxParticles] then 
                        Current = 1
                    end 

                    --Inaccuracy only with sideways but not forward velocity (it is the maximum deviation)
                    local MaxError = Val[ShootingSpeed]/Val[TimeScale] * math.tan( Val[Inaccuracy]*math.pi/180)
                    for i = 1,2,1 do 
                        Error[i] = math.random() * MaxError * 2 - MaxError
                    end

                    local maxv = 0
                    if p < PartSpawnCount/2 then
                        maxv = 2    
                    else
                        if p>PartSpawnCount*0.9 then
                            maxv = 4
                        else
                            maxv = 1 
                        end
                    end
                    AcidVel = Vec(rnd(-maxv,maxv), rnd(-maxv/2,maxv), rnd(-maxv,maxv))
                    -- DebugPrint("Toolend " .. VecStr(ToolEndPoint))
                    -- DebugPrint("Constant " .. VecStr(ConstantPoint))
                    PartVel[Current] = AcidVel
                    Pos[Current] = shootPoint
                    if p>1 then
                        Pos[Current] = VecAdd(Pos[Current],VecScale(PartVel[Current],(p-1)/Val[ParticlesPerUpdate]/60))
                    end

                    PartLife[Current] = Val[ParticleLife]*Val[TimeScale]
                    --randomise the length so that they do not suddenly all disappear at once
                    local ranfactor = 1+0.3*(math.random()*2 -1) 
                    PartLife[Current] = PartLife[Current] * ranfactor


                    Radius[Current] = Val[ParticleDefaultRadius] + Val[ParticleDefaultRadius] *Val[ParticleRadiusRandomising]*(math.random()*2-1)
                    ParticleSetupAcid(PartLife[Current] /Val[ParticleLife])
                    SpawnParticle(Pos[Current],PartVel[Current],FrameTime)

                    Counter1[Current] = StartingUpdate1[Current]
                    Counter2[Current] = StartingUpdate2[Current]
                    Counter3[Current] = StartingUpdate3[Current]

                    Current = Current + 1
                end


    ParticlePhysics()
end

function ParticleSetupAcidForGun(Radius)
	ParticleReset()
	ParticleType("plain")
    ParticleTile(4)
	ParticleColor(0.5, 0.9, 0.5)
	ParticleRadius(Radius)
	ParticleAlpha(1)
    ParticleDrag(0.5)
    ParticleSticky(0.5)
    ParticleCollide(false)
	ParticleGravity(-2)
end

function ParticleSetupAcid(LifeFrac)
    local mn = 0.1
    local mx = 2
    ParticleReset()
    ParticleType("smoke")
    ParticleTile(1)
    ParticleColor(0.6, 0.7, 0.1)
    --ParticleRadius(0.06, 0.2)
    ParticleRadius(mn + (mx-mn)*LifeFrac)
    ParticleStretch(4)
    ParticleAlpha(1-LifeFrac/2)
    --ParticleAlpha(1, 0)
    ParticleDrag(0)
    ParticleCollide(0)
    ParticleGravity(-8)
    ParticleSticky(0.0, 0.5)
end

function ParticlePhysics()
    BurnCounter = 0
    local FrameVec = Vec(0,0,0)
    local max = 0
    for CP = 1, Val[MaxParticles],1 do
        if PartLife[CP] > 0 then
            if FirstParticle == 0 then FirstParticle = CP end
            LastParticle = CP

            FrameVec = VecScale(PartVel[CP],1/60)
            local NewDist = VecLength(FrameVec)

            
            --bounce on hit
            --if ShouldBounce then
            for i = 1,#robot.allShapes,1 do
                QueryRejectShape(robot.allShapes[i])
            end
            local hit, dist = QueryRaycast(Pos[CP], PartVel[CP], NewDist)
            local Bounced = false
            if hit then
                --when reaching a wall from further than 1 voxel away, slow down to get to exactly before the wall next frame, so it can bounce
                --and does not get inside the wall
                if dist>0.01 then 
                    NewDist = dist*0.95
                    FrameVec = VecScale(VecNormalize(PartVel[CP]),NewDist)
                    PartVel[CP] = VecScale(FrameVec,60)
                else --bouncing: reduce speed and go in random direction, only adding downward extra velocity if not bouncing
                    
                    NewDist = NewDist *0.1

                    for i = 1,4,1 do
                        local NewVec = rndVec(1)
                        for i = 1,#robot.allShapes,1 do
                            QueryRejectShape(robot.allShapes[i])
                        end
                        hit, dist = QueryRaycast(Pos[CP], NewVec, NewDist)
                        if hit == false then
                            FrameVec = VecScale(NewVec,NewDist)
                            PartVel[CP] = VecScale(FrameVec,60)
                            Bounced = true
                            break
                        end
                    end
                    if Bounced == false then
                        PartVel[CP] = Vec(0,0,0)
                        FrameVec = Vec(0,0,0)
                    end
                end
            end
            --end

            if hit or NewDist<0.01 then
                BurnCounter = BurnCounter + 1
            end

            if TimeStopped == false then 
                Pos[CP] = VecAdd(Pos[CP],FrameVec)
            end

            ParticleSetupAcid(Radius[CP])
            SpawnParticle(Pos[CP],PartVel[CP],FrameTime)

            if TimeStopped == false then  
                if ShowOptions == false then CorrodeHole(CP) end

                PartLife[CP] = PartLife[CP]-1
                if Bounced == false then --if just bounced don't change direction with gravity
                    if hit == false then --if did not bounce, only apply gravity if it did not hit anything otherwise now vel is going to 0
                        PartVel[CP] = VecAdd(PartVel[CP],VecScale(GravityVector,1/Val[TimeScale]^2))
                    end

                end
            end
        end
    end

    --DebugCross(Pos[FirstParticle])
    --DebugCross(Pos[LastParticle])
    --DebugPrint(1*math.log(BurnCounter/MaxParticles/3+1))
    
    --PlayLoop(BurnSound,Pos[FirstParticle],0.5*math.log(BurnCounter/MaxParticles/3+1))
    --PlayLoop(BurnSound,Pos[LastParticle],0.5*math.log(BurnCounter/MaxParticles/3+1))
end

function CorrodeHole(CP)
    local Hole1 = false
    local Hole2 = false
    local Hole3 = false

    Counter1[CP] = Counter1[CP] - 1
    Counter2[CP] = Counter2[CP] - 1
    Counter3[CP] = Counter3[CP] - 1
    if Counter1[CP] < 1 then
        Counter1[CP] = HoleUpdates1[CP]
        Hole1 = true
    end
    if Counter2[CP] < 1 then
        if Val[CorrodeMediumSwitch] then
        Counter2[CP] = HoleUpdates2[CP]
        Hole2 = true
        end
    end
    if Counter3[CP] < 1 then
        if Val[CorrodeHardSwitch] then
        Counter3[CP] = HoleUpdates3[CP]
        Hole3 = true
        end
    end

    if Hole1 then
        MakeHole(Pos[CP],Val[AcidHoleSize],0,0,true)
    end
    if Hole2 then
        MakeHole(Pos[CP],Val[AcidHoleSize],Val[AcidHoleSize],0,true)
    end
    if Hole3 then
        MakeHole(Pos[CP],Val[AcidHoleSize],Val[AcidHoleSize],Val[AcidHoleSize],true)
    end
end

function ClearParticles()
    for CP = 1, Val[MaxParticles],1 do
        PartLife[CP] = 0
        PartVel[CP] = Vec(0,0,0)
        Pos[CP] = Vec(0,0,0)
    end
end

function tick()

end

function draw()
	if ShowOptions then
		--DrawOptions(true)
	end
end

function rndVec(length)
    local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
    return VecScale(v, length)    
end