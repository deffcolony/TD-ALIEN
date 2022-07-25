--Health system based on the combine soldier mod


function HealthInit()
    config.maxHealth = 400.0

    robot.health = 100.0
    robot.headDamageScale = 3.0
    robot.torsoDamageScale = 1.4
    robot.torso = 0
    robot.head = 0
    robot.rightHand = 0
    robot.leftHand = 0
    robot.rightFoot = 0
    robot.leftFoot = 0

    robot.torso = FindBody("uppertorso")
	robot.head = FindBody("head")
	robot.rightHand = FindBody("righthand")
	robot.leftHand = FindBody("lefthand")
	robot.rightFoot = FindBody("rightfoot")
	robot.leftFoot = FindBody("leftfoot")
	
	robot.health = config.maxHealth
end

function HealthUpdate(dt)
    if robot.health <= 0.0 then
    	for i = 1, #robot.allShapes do
    		SetShapeEmissiveScale(robot.allShapes[i], 0)
    		Delete(lightsaber)
    	end
    	SetTag(robot.body, "disabled")
    	robot.enabled = false
    	PlaySound(fdeath, robot.bodyCenter, 0.3, false)
    	PlaySound(pain, robot.bodyCenter, 3.0, false)
    	--PlaySound(pain2, robot.bodyCenter, 10.0, false)
    end
end

function ExplosionDamage(f)
    local damage = f * 20.0
    robot.health = robot.health - f * 20.0
end

function ExplosionSound()
    PlaySound(pain, robot.bodyCenter, 0.5, false)
end


function ShotDamage(strength)
--Take damage
    local damage = strength * 20.0
    if GetShapeBody(shape) == robot.torso then
        damage = damage * robot.torsoDamageScale
    elseif GetShapeBody(shape) == head.body then
        damage = damage * robot.headDamageScale
    end

    GetAcid(GetBodyTransform(robot.body).pos,Vec(0,1,0))

    robot.health = robot.health - damage
    robot.stunned = robot.stunned + 0.12
    playVoice(pain, robot.bodyCenter, 0.3, false)

    --
    ParticleReset()
    ParticleType("smoke")
    ParticleTile(1)
    ParticleColor(0.6, 0.7, 0.1)
    ParticleRadius(0.06, 0.2)
    ParticleStretch(4)
    ParticleAlpha(1, 0)
    ParticleDrag(0)
    ParticleCollide(0)
    ParticleGravity(-8)
    ParticleSticky(0.0, 0.5)

    for i=1,150 do 					
        SpawnParticle(robot.bodyCenter, Vec(rnd(-5,5), rnd(-3,5), rnd(-5,5)), 4)
    end
    
    ParticleReset()
    ParticleType("smoke")
    ParticleTile(1)
    ParticleColor(0.6, 0.7, 0.1)
    ParticleRadius(0.4, 15)
    ParticleStretch(0)
    ParticleAlpha(1, 0)
    ParticleDrag(1)
    ParticleCollide(0)
    ParticleGravity(-5)

    for i=1,3 do 					
           SpawnParticle(robot.bodyCenter, Vec(rnd(-5,5), rnd(-3,5), rnd(-5,5)), 0.7)
    end			

    
end

--[[
if IsShapeBroken(target) then
    for i=1, #robot.allShapes do
if robot.allShapes[i] == shape then
robot.stunned = robot.stunned + 1000
return
end
end
end
]]