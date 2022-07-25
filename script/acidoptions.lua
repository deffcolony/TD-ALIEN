--example for using values in main
--ToolTransform.pos = Vec(Val[ToolRight],Val[ToolUp], Val[ToolBack])

--in game options
--function draw()
--	if ShowOptions then
--		DrawOptions(true)
--	end
--end

--InitialiseOptions
--ShowOptions == false

--if InputPressed("m") then
--	if ShowOptions == false then ShowOptions = true end
--	if ShowOptions == true then ShowOptions = false end
--end

function InitialiseOptions()
	Default= {} --Default values
	Val = {} --Current values
	UiName = {} --Name shown on UiAlign
	TextBox = {} --Helping text for setting
	TextHeight = {} --user gives in rows how long the text is, which is converted to pixels later
	MinVal = {} --Min Slider value
	MaxVal = {} --Max Slider value
	Unit = {} --unit shown in display
	UnitFactor = {} --displayed value only is multiplied by this number, when setting defaults below use all the displayed values (eg 1 voxel min, 1 voxel default) but internally it uses 
	--value without the above factor (eg 0.1 m)
	Rounding = {} --how many decimals to keep
	NonNegative = {} --can't go below 0
	--ConfigDefault defaults to ConfigDefault when starting, then when opening options again, defaults to current value

	local i = 0
	--Initialise each variable
	i = i + 1
		ToolPositionText = i
		Default[i] = "Shooting"
		TextBox[i] = "Options relating to how particles leave the nozzle (speed / accuracy etc)"
		TextHeight[i] = 2
	
	i = i + 1
		ShootingSpeed = i
		UnitFactor[i] = 1
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 12
		UiName[i] = "Shooting Speed"
		TextBox[i] = "How fast the acid particles leave the gun when shooting (ie how far it can spray)"
		TextHeight[i] = 2
		Unit[i] = "m/s" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 12 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 12 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		ParticlesPerUpdate = i
		UnitFactor[i] = 1
		Rounding[i] = 1 / UnitFactor[i]
		ConfigDefault = 2
		UiName[i] = "Shooting Rate"
		TextBox[i] = "How much faster to shoot particles (ie how many particles per update) default is 1 particle per update"
		TextHeight[i] = 2
		Unit[i] = "x" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 9 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 9 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end
		if MinVal[i]<1 then MinVal[i]=1 end
		
		Val[i] = Default[i]

	i = i + 1
		Inaccuracy = i
		UnitFactor[i] = 1
		Rounding[i] = 0.5 / UnitFactor[i]
		ConfigDefault = 4
		UiName[i] = "Inaccuracy"
		TextBox[i] = "Maximum inaccuracy angle in all directions from center. (angle is not perfectly accurate)"
		TextHeight[i] = 2
		Unit[i] = " degrees" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 10 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 10 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		AddPlayerSpeed = i
		Default[i] = true
		UiName[i] = "Add Player Speed"
		TextBox[i] = "Decides whether the movement of the player affects the acid particles"
		TextHeight[i] = 2
		Val[i] = Default[i]
	
	i = i + 1
		ToolPositionText = i
		Default[i] = "Strength"
		TextBox[i] = "How quickly the acid eats through materials. Every x seconds a hole is made in soft, medium and hard materials. (the hard hole also affects the soft material etc)."
		TextHeight[i] = 4

	i = i + 1
		AcidHoleSize = i
		UnitFactor[i] = 10
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 2.5
		UiName[i] = "Hole size"
		TextBox[i] = "How big holes the acid particles make while corroding, measured in radius from center of particle"
		TextHeight[i] = 3
		Unit[i] = " voxel" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 1 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 1 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]


	i = i + 1
		CorrodeSoft = i
		UnitFactor[i] = 1/60
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 60/60
		UiName[i] = "Corrode soft"
		TextBox[i] = "How often to corrode soft materials (total soft corrosion is also affected by the medium and hard values)"
		TextHeight[i] = 3
		Unit[i] = "s" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 2 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 2 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]


	i = i + 1
		CorrodeMedium = i
		UnitFactor[i] = 1/60
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 120/60
		UiName[i] = "Corrode medium"
		TextBox[i] = "How often to corrode medium and soft materials on top of the above setting"
		TextHeight[i] = 2
		Unit[i] = "s" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 3 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 3 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]
	
	i = i + 1
		CorrodeHard = i
		UnitFactor[i] = 1/60
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 240/60
		UiName[i] = "Corrode hard"
		TextBox[i] = "How often to corrode all materials including hard ones"
		TextHeight[i] = 2
		Unit[i] = "s" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 4 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 4 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		CorrodeMediumSwitch = i
		Default[i] = true
		UiName[i] = "Corroding medium"
		TextBox[i] = "If switched off, medium materials are not affected by the acid"
		TextHeight[i] = 2
		Val[i] = Default[i]

	i = i + 1
		CorrodeHardSwitch = i
		Default[i] = true
		UiName[i] = "Corroding hard"
		TextBox[i] = "If switched off, hard materials are not affected by the acid"
		TextHeight[i] = 2
		Val[i] = Default[i]

	i = i + 1
		CorrosionSpeedRandomising = i
		UnitFactor[i] = 100
		Rounding[i] = 1 / UnitFactor[i]
		ConfigDefault = 20
		UiName[i] = "Randomising"
		TextBox[i] = "Each individual acid particle can corrode faster or slower by this % so it does not look very regular"
		TextHeight[i] = 2
		Unit[i] = "%" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 20 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 10 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		ToolPositionText = i
		Default[i] = "Particles"
		TextBox[i] = ""
		TextHeight[i] = 4

	i = i + 1
		ParticleLife = i
		UnitFactor[i] = 1/60
		Rounding[i] = 0.5 / UnitFactor[i]
		ConfigDefault = 10
		UiName[i] = "Particle life"
		TextBox[i] = "How long before particles disappear on their own"
		TextHeight[i] = 1
		Unit[i] = "s" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 10 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 10 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		MaxParticles = i
		UnitFactor[i] = 1
		Rounding[i] = 10 / UnitFactor[i]
		ConfigDefault = 800
		UiName[i] = "Max particles"
		TextBox[i] = "Maximum number of particles that can exist in the game at one time (if more is created the oldest one is destroyed)."
		TextHeight[i] = 3
		Unit[i] = "" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 500 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 500 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		ParticleDefaultRadius = i
		UnitFactor[i] = 20
		Rounding[i] = 0.1 / UnitFactor[i]
		ConfigDefault = 1
		UiName[i] = "Particle size"
		TextBox[i] = "Visual size only (diameter), does not affect physics or corrosion"
		TextHeight[i] = 2
		Unit[i] = " voxels" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 1 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 3 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		ParticleRadiusRandomising = i
		UnitFactor[i] = 100
		Rounding[i] = 1 / UnitFactor[i]
		ConfigDefault = 20
		UiName[i] = "Randomising"
		TextBox[i] = "Each individual acid particle size is randomised by this amount so they don't look too regular. (visual effect only)"
		TextHeight[i] = 3
		Unit[i] = "%" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 20 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 10 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]

	i = i + 1
		ToolPositionText = i
		Default[i] = "Debug"
		TextBox[i] = ""
		TextHeight[i] = 4

	i = i + 1
		TimeScale = i
		UnitFactor[i] = 1
		Rounding[i] = 1 / UnitFactor[i]
		ConfigDefault = 1
		UiName[i] = "SlowMo"
		TextBox[i] = ""
		TextHeight[i] = 1
		Unit[i] = "x" 

		if Val[i] == nil then 
			Default[i] = ConfigDefault / UnitFactor[i]
		else Default[i] = Val[i] end

		MinVal[i] = Round(Default[i] - 0 / UnitFactor[i],Rounding[i])
		MaxVal[i] = Round(Default[i] + 19 / UnitFactor[i],Rounding[i])
		NonNegative[i] = true

		if NonNegative[i] then
			if MinVal[i]<0 then MinVal[i] = 0 end
		end

		Val[i] = Default[i]
	--------------------------------------------------------------------------------------------
	
	for i = 1,#Default,1 do
		--If has saved value then use that otherwise default
		if HasKey("savegame.mod.Val" .. i) then 
			if type(Default[i]) == "number" then
				Val[i] = GetFloat("savegame.mod.Val" .. i)
			elseif type(Default[i]) == "boolean" then
				Val[i] = GetBool("savegame.mod.Val" .. i)
			end
		else
			Val[i] = Default[i]
		end
		
		--for headers UiName is left empty and is taken from the default value (done like this so default is string type there)
		if UiName[i] == nil then
			UiName[i] = Default[i]
		end
		
		--text height to pixel conversion
		if TextHeight[i] ~= nil then
			TextHeight[i] = TextHeight[i]*28 + 14
		end 
	end
end


function init()
	InitialiseOptions()

	ModMenu = true
end

function draw()
	if ModMenu ~= nil then
		DrawOptions(false)
	end
end

function DrawOptions(FromGame)
	if FromGame then
		UiMakeInteractive()
		UiPush()
			UiColor(0, 0, 0)
			--UiRect(UiWidth(), UiHeight())

			UiColorFilter(0, 0, 0, 0.7)
			UiRect(700, UiHeight())
		UiPop()
	end
	
	--Var init doesn't work if in init when called from game
	----------------------------
	PopupWidth = 500
	PopupHeight = 100
	

	----------------------------
	
	if FromGame then
		UiTranslate(330, 70)
	else
		UiTranslate(UiCenter(), 70)
	end

	
	UiAlign("center middle")

	UiFont("bold.ttf", 48)
	UiText("Acid gun")
	--UiFont("regular.ttf", 26)
	--UiTranslate(0, 40)
	--UiText("Extra info")
	UiTranslate(0, 30)
	UiFont("regular.ttf", 26)

	
	
	if FromGame == false then
		UiText("Press M in game to see this menu.")
		UiTranslate(0, 20)
	end
	
	--UiTranslate(-150, 80)	

	
	UiTranslate(-80, 0)
	UiPush()

	
	--Draw the gasic Ui
	for i = 1,#UiName,1 do
		if type(Default[i]) == "string" then
			UiHeader(UiName[i], TextBox[i])
		elseif type(Default[i]) == "boolean" then
			Val[i] = UITickBox(UiName[i],Val[i],"Val" .. i, TextBox[i])
		elseif type(Default[i]) == "number" then
			Val[i] = UISliderExplain(UiName[i],Val[i],MinVal[i],MaxVal[i],UnitFactor[i],Unit[i],"Val" .. i, Rounding[i], TextBox[i])
		end
		
		
	end
	
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	
	UiTranslate(80, 60)
	UiColor(1, 0, 0)
	if UiTextButton("Close", 80, 40) then
		if FromGame == false then
			Menu()
		else
			ShowOptions = false
			ClearParticles()
		end
	end
	
	UiColor(1, 1, 1)
	--UiTranslate(0, 60)
	UiTranslate(-140, 0)
	if UiTextButton("Reset to default", 170, 40) then
		for i = 1,#Default,1 do
			SaveSetting("savegame.mod.AdjustedVal" .. i, Val[i])
			Val[i] = Default[i]
			
			SaveSetting("savegame.mod.InGameVal" .. i, Val[i])
		end
		RecenterSliders()
	end

	--UiTranslate(0, 60)
	UiTranslate(140+140, 0)
	if UiTextButton("Recenter sliders", 170, 40) then
		RecenterSliders()
	end
	----------------------------------------------------------------------------------------
	--TextBoxes
	

	UiPop()
	--relative position of question box: 
	UiTranslate(15, -10)
	for i = 1,#UiName,1 do
		if type(Default[i]) == "string" then
			UiTranslate(0, 60)
		else
			UiTranslate(0, 40)
		end
		--Debug the rectanbles where you can get popup
		--UiRect(22, 22)
		if TextBox[i] ~=nil then
		if TextBox[i] ~="" then
		if UiIsMouseInRect(22, 22) then
			UiPush()
				UiColor(1, 1, 1)
				UiTranslate(PopupWidth/2+10,TextHeight[i]/2+10)
				UiRect(PopupWidth, TextHeight[i])
				UiColor(0.1, 0.1, 0.1)
				UiRect(PopupWidth-4, TextHeight[i]-4)

				
				UiWordWrap(PopupWidth-30)
				--UiTranslate(-40,35)
				UiColor(1, 1, 1)
				UiText(TextBox[i])
			UiPop()
		end
		end
		end
	end
end

--##slider types need to be adjusted here
function RecenterSliders(SliderRange)
	
	for i = 1,#Default,1 do
		if MinVal[i] ~= nil then
			local range = (MaxVal[i]-MinVal[i])/2
			MinVal[i] = Round(Val[i] - range ,Rounding[i])
			MaxVal[i] = Round(Val[i] + range,Rounding[i])
			if NonNegative[i] then
				if MinVal[i]<0 then MinVal[i] = 0 end
			end
		end
	end
end

function SaveSetting(SettingName, Value)
	if type(Value) == "number" then
		SetFloat("savegame.mod." .. SettingName, Value)
   	elseif type(Value) == "boolean" then
		SetBool("savegame.mod." .. SettingName,Value)
   	end
end

function GetSetting(SettingName, OldValue)
	if type(OldValue) == "number" then
		return GetFloat("savegame.mod." .. SettingName)
   	elseif type(OldValue) == "boolean" then
		return GetBool("savegame.mod." .. SettingName)
   	end
end

function SpecialCalculationsOnValueChange(i)
	--didn't work
	--[[
	if i == TimeScale then
		if LastScale == nil then LastScale = Default[TimeScale] end
		for CP = 1, Val[MaxParticles],1 do
			PartVel[CP] =VecScale(PartVel[CP] ,1/ Val[i] * LastScale)
			LastScale =  Val[i]
		end
	end
	]]--
end

function UiHeader(TextB, PopupText)
	local Result = 0
	UiTranslate(0, 60)
	UiPush()
		UiFont("bold.ttf", 26)
		TextWithPopup(TextB, PopupText~="")
	UiPop()	
	return Result
end

function UITickBox(TextB,CurrentVal,SaveName, PopupText)
	local Result = 0
	UiTranslate(0, 40)
	UiPush()
		TextWithPopup(TextB, PopupText~="")
		
		
		--
		UiTranslate(40, 0)
		
		Result = CurrentVal
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		if UiTextButton(" ", 25, 25) then
			Result = not(CurrentVal)
			SetBool("savegame.mod."..SaveName, Result)
		end
		
		
		UiPush()
			--UiColor(0.7, 0.6, 0.1)
			UiFont("bold.ttf", 26)
			UiColor(0.2, 0.6, 1)
			if Result then UiText("X") end
		UiPop()
		

		
	UiPop()	
	return Result
end

function TextWithPopup(Text, HasPopup)
	--text
	UiAlign("right")
	UiText(Text)
		
	UiTranslate(23, 0)

		--question mark
	if HasPopup then
		UiPush()
		UiTranslate(0,-17)
		UiColor(0.3, 0.3, 0.3)
		UiRect(20, 20)

		UiPop()
		
		UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 26)
		UiTextButton("?")
		UiPop()
	end
end


function UISliderExplain(TextB,CurrentVal,MinV,MaxV,UnitFactor,Unit,SaveName, RNo,PopupText)
	local Result = 0
	UiTranslate(0, 40)
	UiPush()
		TextWithPopup(TextB, PopupText~="")

		UiTranslate(250+15, 0)

		Result = optionsSlider(CurrentVal, MinV, MaxV, RNo)
		UiTranslate(40, 0)
		UiAlign("left")
		UiColor(0.7, 0.6, 0.1)
		UiText(Result*UnitFactor..Unit)
		SetFloat("savegame.mod."..SaveName, Result)
	UiPop()	
	return Result
end



function optionsSlider(val, min, max, RoundingNo)
	UiColor(0.2, 0.6, 1)
	UiPush()
		UiTranslate(0, -8)

		val = (val-min) / (max-min)
		local w = 250
		UiRect(w, 3)
		UiAlign("center middle")
		UiTranslate(-w, 1)
		val = UiSlider("ui/common/dot.png", "x", val*w, 0, w) / w

		val = Round((val*(max-min)+min), RoundingNo)
		if val < min then val = min end
		if val > max then val = max end

	UiPop()
	return val
end

function Round(number, RoundingNo)
	RoundingNo = 1/RoundingNo
	local lowerRound = 0
	local highherRound = 0
	
	lowerRound = math.floor(number * RoundingNo) / RoundingNo
	highherRound = math.ceil(number * RoundingNo) / RoundingNo
	
	floorerror =  math.abs(number - lowerRound)							
	ceilingerror =  math.abs(number - highherRound)
	
								
	if floorerror < ceilingerror then							
		return lowerRound						
	else							
		return highherRound						
	end		
end
