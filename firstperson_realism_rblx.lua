wait(2) 
local InputService=game:GetService("UserInputService")
local Camera=game.Workspace.CurrentCamera
local Player=game.Players.LocalPlayer
local Character=Player.Character
local Head=Character.Head
local Torso=Character.Torso
local RootPart=Character.HumanoidRootPart
local RootJoint=RootPart.RootJoint
local Neck=Torso.Neck
Camera.FieldOfView=90
Camera.CameraType="Scriptable"
InputService.MouseBehavior=Enum.MouseBehavior.LockCenter



local v3=Vector3.new
local cf=CFrame.new
local components=cf().components
local inverse=cf().inverse
local fromAxisAngle=CFrame.fromAxisAngle
local atan,atan2=math.atan,math.atan2
local acos=math.acos

local function toAxisAngleFromVector(v)
	local z=v.z
	return z*z<0.99999 and v3(v.y,-v.x,0).unit*acos(-z) or v3()
end

local function AxisAngleLookOrientation(c,v,t)
	local c=c-c.p
	local rv=(inverse(c)*v).unit
	local rz=rv.z
	return rz*rz<0.99999 and c*fromAxisAngle(v3(rv.y,-rv.x,0),acos(-rz)*(t or 1)) or c
end

local function AxisAngleLookNew(v,t)
	local rv=v.unit
	local rz=rv.z
	return rz*rz<0.99999 and fromAxisAngle(v3(rv.y,-rv.x,0),acos(-rz)*(t or 1)) or cf()
end

local function AxisAngleLook(c,v,t)
	local rv=(inverse(c)*v).unit
	local rz=rv.z
	return rz*rz<0.99999 and c*fromAxisAngle(v3(rv.y,-rv.x,0),acos(-rz)*(t or 1)) or c
end




local Sensitivity=0.005


local CameraDirection=Vector3.new(0,0,1)

local function EulerAnglesYX(l)
	local x,z=l.x,l.z
	return atan(l.y/(x*x+z*z)^0.5),-atan2(x,-z)
end

local function AnglesXY(l)
	local z=l.z
	return atan2(l.y,-z),-atan2(l.x,-z)
end

local function MouseMoved(Input)
	if Input.UserInputType==Enum.UserInputType.MouseMovement then
		local dx,dy=Input.Delta.x*Sensitivity,Input.Delta.y*Sensitivity
		local m2=dx*dx+dy*dy
		if m2>0 then
			CameraDirection=(AxisAngleLookOrientation(RootPart.CFrame,CameraDirection)*fromAxisAngle(v3(-dy,-dx,0),m2^0.5)).lookVector
		end
		local RootOrientation=RootPart.CFrame-RootPart.Position
		local RelativeDirection=RootOrientation:inverse()*CameraDirection
		local AngX,AngY=AnglesXY(RelativeDirection)
		if AngX<-1.57*11/12 then
			local y,z,c,s=RelativeDirection.y,RelativeDirection.z,math.cos(-1.57*11/12-AngX),-math.sin(-1.57*11/12-AngX)
			z,y=z*c-y*s,z*s+y*c
			CameraDirection=RootOrientation*v3(RelativeDirection.x<0 and -(1-y*y-z*z)^0.5 or (1-y*y-z*z)^0.5,y,z)
		elseif AngX>1.57*11/12 then
			local y,z,c,s=RelativeDirection.y,RelativeDirection.z,math.cos(1.57*11/12-AngX),-math.sin(1.57*11/12-AngX)
			z,y=z*c-y*s,z*s+y*c
			CameraDirection=RootOrientation*v3(RelativeDirection.x<0 and -(1-y*y-z*z)^0.5 or (1-y*y-z*z)^0.5,y,z)
		end
	end
end

local Mouse=Player:GetMouse()

local Zoom=-0.5

Mouse.KeyDown:connect(function(k) 
	if k=="i" then 	
		Zoom=-0.5
	elseif k=="o" then
		Zoom=8
	end
end)

InputService.InputChanged:connect(MouseMoved)

Neck.C1=cf()

local _
local DirectionBound=3.14159/3
local CurrentAngY=0

local function CameraUpdate()
	Camera.CameraType="Scriptable"
	local cx,cz=CameraDirection.x,CameraDirection.z
	local rvx,rvz=RootPart.Velocity.x,RootPart.Velocity.z
	if rvx*rvx+rvz*rvz>4 and cx*rvx+cz*rvz<-0.5*(cx*cx+cz*cz)^0.5*(rvx*rvx+rvz*rvz)^0.5 then
		DirectionBound=math.min(DirectionBound*0.9,math.abs(CurrentAngY*0.9))
		DirectionBound=DirectionBound*0.1+3.14159/3*0.9
	end
	local AngX,AngY=EulerAnglesYX((RootPart.CFrame-RootPart.Position):inverse()*CameraDirection) -- Hi this is shadyskyX's Script.
	if AngY>DirectionBound then
		RootPart.CFrame=RootPart.CFrame*CFrame.Angles(0,AngY-DirectionBound,0)
	elseif AngY<-DirectionBound then
		RootPart.CFrame=RootPart.CFrame*CFrame.Angles(0,AngY+DirectionBound,0)
	end
	_,CurrentAngY=EulerAnglesYX((RootPart.CFrame-RootPart.Position):inverse()*CameraDirection)
	local CameraOrientation=AxisAngleLookNew((RootPart.CFrame-RootPart.Position):inverse()*CameraDirection,1)
	Neck.C0=CFrame.new(0,1,0)*CameraOrientation*CFrame.new(0,0.5,0)
	local PreCam=AxisAngleLook(RootPart.CFrame*cf(0,1,0),RootPart.CFrame*v3(0,1,0)+CameraDirection)*CFrame.new(0,0.825,0) -- Hi this is shadyskyX's Script.
	if Zoom==8 then
		local Part,Position=Workspace:findPartOnRay(Ray.new(PreCam.p,PreCam.lookVector*-8),Character)
		Camera.CoordinateFrame=PreCam*CFrame.new(0,0,(Position-PreCam.p).magnitude)
	else
		Camera.CoordinateFrame=PreCam*CFrame.new(0,0,Zoom)
	end
end

game:GetService("RunService").RenderStepped:connect(CameraUpdate)

wait(1)
Character = game.Players.LocalPlayer.Character
Camera = game.Workspace.CurrentCamera
Mouse = game.Players.LocalPlayer:GetMouse()
RArmJoint = Character.Torso:FindFirstChild("Right Shoulder")
LArmJoint = Character.Torso:FindFirstChild("Left Shoulder")
RHipJoint = Character.Torso:FindFirstChild("Right Hip")
LHipJoint = Character.Torso:FindFirstChild("Left Hip")
Tilt = 0
TiltConvergence = 0
Twist = 0
TwistConvergence = 0
Speed = 0.975
SpeedConvergence = 0.975
SD = 0.95
Flat = Vector3.new(1, 0, 1)
CurrentCameraLV = nil
MinVelocity = -100
HasReset = false
Flying = false

function KeyPressed(Key)
	if Key == "d" then
		TwistConvergence = 1
	elseif Key == "a" then
		TwistConvergence = -1 -- Hi this is shadyskyX's Script.
	elseif Key == "w" then
		TiltConvergence = 1
	elseif Key == "s" then
		TiltConvergence = -1
	elseif Key == " " then
		SD = 0.95
		SpeedConvergence = 0.66
	end
print(3)
end

function KeyUnpressed(Key)
	if Key == "d" or Key == "a" then
		TwistConvergence = 0
	elseif Key == "w" or Key == "s" then
		TiltConvergence = 0
	elseif Key == " " then
		SD = 0.975
		SpeedConvergence = 1
	end
print(4)
end

Mouse.KeyDown:connect(KeyPressed)
Mouse.KeyUp:connect(KeyUnpressed)

function ChangeWeld(Weld, C0, C1)
	Weld.C0, Weld.C1 = C0, C1
end

function MakeRay(From, To)
	local Hit, Position = game.Workspace:FindPartOnRay(Ray.new(From, To - From), Character)
	return {Hit = Hit, Position = Position}
end

while true do
	wait()
	Twist = (Twist * 31 + TwistConvergence) / 32
	Tilt = (Tilt * 31 + TiltConvergence) / 32
	Speed = (Speed * 15 + SpeedConvergence) / 16
	if Character.Torso.Velocity.y < MinVelocity and not Character.Humanoid.Sit then
		Character.Animate.Disabled = true
		VMag = math.sqrt(Character.Torso.Velocity.magnitude / 48)
		DMag = ((Character.Torso.CFrame * CFrame.Angles(1.57, 0, 0)).lookVector - Character.Torso.Velocity.unit).magnitude
		MinVelocity = -50
		HasReset = false
		Character.Humanoid.PlatformStand = true
		Raise = math.max(math.min(Character.Torso.Velocity.y / 800 - (DMag * VMag / 4), 1), -1)
		ChangeWeld(RArmJoint,
			CFrame.new(1.5, 0.5, 0) * CFrame.Angles(Raise, (math.random() * 0.2 - 0.1) * Raise, 2.355 / Speed - 1.57 - Twist / 1.5),
			CFrame.new(0, 0.5, 0))
		ChangeWeld(LArmJoint, 
			CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(Raise, (math.random() * 0.2 - 0.1) * Raise, -2.355 / Speed + 1.57 - Twist / 1.5),
			CFrame.new(0, 0.5, 0))
		ChangeWeld(RHipJoint,
			CFrame.new(0.5, -1, 0) * CFrame.Angles(Raise, (math.random() * 0.2 - 0.1) * Raise, 1.046 / Speed - 0.698 - Twist / 1.5),
			CFrame.new(0, 1, 0))
		ChangeWeld(LHipJoint,
			CFrame.new(-0.5, -1, 0) * CFrame.Angles(Raise, (math.random() * 0.2 - 0.1) * Raise, -1.046 / Speed + 0.698 - Twist / 1.5),
			CFrame.new(0, 1, 0))
		CurrentCameraLV = (game.Workspace.CurrentCamera.CoordinateFrame.lookVector * Flat).unit
		Character.Torso.CFrame = CFrame.new(Character.Torso.Position, Character.Torso.Position + ((Character.Torso.CFrame * CFrame.Angles(1.57, 0, 0)).lookVector * Flat * 15 + CurrentCameraLV)/16) * CFrame.Angles(-Tilt - 1.57, Twist, 0)
		Character.Torso.Velocity = Character.Torso.Velocity*SD + CurrentCameraLV*Tilt*5 + Vector3.new(-CurrentCameraLV.z, 0, CurrentCameraLV.x)*Twist*5
		Character.Torso.RotVelocity = Vector3.new(0, 0, 0)
	elseif not HasReset then
		Character.Animate.Disabled = false -- Hi this is shadyskyX's Script.
		MinVelocity = -100
		Character.Humanoid.PlatformStand = false
		RArmJoint.C0 = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0)
		RArmJoint.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0)
		LArmJoint.C0 = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(0, -math.pi/2, 0)
		LArmJoint.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(0, -math.pi/2, 0)
		RHipJoint.C0 = CFrame.new(0.5, -1, 0) * CFrame.Angles(0, math.pi/2, 0)
		RHipJoint.C1 = CFrame.new(0, 1, 0) * CFrame.Angles(0, math.pi/2, 0)
		LHipJoint.C0 = CFrame.new(-0.5, -1, 0) * CFrame.Angles(0, -math.pi/2, 0)
		LHipJoint.C1 = CFrame.new(0, 1, 0) * CFrame.Angles(0, -math.pi/2, 0)
		HasReset = true
		end

local mouse = game.Players.LocalPlayer:GetMouse()
local running = false

function getTool()	
	for _, kid in ipairs(script.Parent:GetChildren()) do
		if kid.className == "Tool" then return kid end
	end
	return nil
end


mouse.KeyDown:connect(function (key) 
	key = string.lower(key)
	if string.byte(key) == 48 then
		running = true
		local keyConnection = mouse.KeyUp:connect(function (key)
			if string.byte(key) == 48 then
				running = false
			end
		end)
		for i = 1,5 do
			game.Workspace.CurrentCamera.FieldOfView = (70+(i*2))
			wait()
		end
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 24
		repeat wait () until running == false
		keyConnection:disconnect()
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
		for i = 1,5 do
			game.Workspace.CurrentCamera.FieldOfView = (80-(i*2))
			wait()
		end
	end
end)

local ShadySkyX = script.Parent
local Player = game.Players.LocalPlayer
local Avatar = Player.Character
local Mouse = Player:GetMouse()


local Hold = nil


local Humanoid = Avatar:WaitForChild("Humanoid")
local Torso = Avatar:WaitForChild("Torso")
local RH = Torso:WaitForChild("Right Hip")
local LH = Torso:WaitForChild("Left Hip")

local RL = Avatar:WaitForChild("Right Leg")
local LL = Avatar:WaitForChild("Left Leg")

local RJ = Avatar:WaitForChild("HumanoidRootPart"):WaitForChild("RootJoint")

function CreateWeld(Part, CF)
	local w = Instance.new("Weld")
	w.Name = "LegWeld"
	w.Parent = Torso
	w.Part0 = Torso
	w.Part1 = Part
	w.C1 = CF
end

function StandUp()
	Humanoid.CameraOffset = Vector3.new(0, 0, 0)

	RH.Part1 = RL


	LH.Part1 = LL


	for i, s in pairs(Torso:GetChildren()) do
		if (s.Name == "LegWeld") and (s.ClassName == "Weld") then
			s:Destroy()
		end
	end

	
	RJ.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
	RJ.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
end


Mouse.KeyDown:connect(function(Key)
	if (Hold ~= nil) then return end
	if (string.upper(Key) ~= "X") and (string.lower(Key) ~= " ") then return end
	Hold = true

	if (Torso:FindFirstChild("LegWeld") == nil) and (string.lower(Key) ~= " ") then
	
		RH.Part1 = nil
		CreateWeld(RL, CFrame.new(-0.4, 1.25, 0.5) * CFrame.fromEulerAnglesXYZ(math.rad(90),-0.25,0))

	
		LH.Part1 = nil
		CreateWeld(LL, CFrame.new(0.4, 1.25, 0.5) * CFrame.fromEulerAnglesXYZ(math.rad(90),0.25,0))
		
		
		RJ.C0 = CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, 0)
		RJ.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		
	
		Humanoid.CameraOffset = Vector3.new(0, -2, 0)
		Humanoid.WalkSpeed = 4
		
	else
		StandUp()

	
		Humanoid.CameraOffset = Vector3.new(0, 0, 0)
		Humanoid.WalkSpeed = 16
		
	end

	wait(0.5)

	Hold = nil
end)

Humanoid.Changed:connect(function()
	if (Humanoid.WalkSpeed > 8) and (Hold == nil) then StandUp() end
end)

local ShadySkyX = script.Parent
local Player = game.Players.LocalPlayer
local Avatar = Player.Character
local Mouse = Player:GetMouse()


local Hold = nil


local Humanoid = Avatar:WaitForChild("Humanoid")
local Torso = Avatar:WaitForChild("Torso")
local RH = Torso:WaitForChild("Right Hip")
local LH = Torso:WaitForChild("Left Hip")

local RL = Avatar:WaitForChild("Right Leg")
local LL = Avatar:WaitForChild("Left Leg")

local RJ = Avatar:WaitForChild("HumanoidRootPart"):WaitForChild("RootJoint")

--[ Functions ]--
function CreateWeld(Part, CF)
	local w = Instance.new("Weld")
	w.Name = "LegWeld"
	w.Parent = Torso
	w.Part0 = Torso
	w.Part1 = Part
	w.C1 = CF
end

function StandUp()
	Humanoid.CameraOffset = Vector3.new(0, 0, 0)
	
	RH.Part1 = RL

	
	LH.Part1 = LL


	for i, s in pairs(Torso:GetChildren()) do
		if (s.Name == "LegWeld") and (s.ClassName == "Weld") then
			s:Destroy()
		end
	end

	
	RJ.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
	RJ.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
end


Mouse.KeyDown:connect(function(Key)
	if (Hold ~= nil) then return end
	if (string.upper(Key) ~= "C") and (string.lower(Key) ~= " ") then return end
	Hold = true

	if (Torso:FindFirstChild("LegWeld") == nil) and (string.lower(Key) ~= " ") then
		
		RH.Part1 = nil
		CreateWeld(RL, CFrame.new(-0.5, 0.75, 1))

		
		LH.Part1 = nil
		CreateWeld(LL, CFrame.new(0.5, 0.495, 1.25) * CFrame.Angles(math.rad(90), 0, 0))
		
	
		RJ.C0 = CFrame.new(0, -1.25, 0) * CFrame.Angles(0, 0, 0)
		RJ.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
		
		
		Humanoid.CameraOffset = Vector3.new(0, -1.25, 0)
		Humanoid.WalkSpeed = 8
		
	else
		StandUp()

		
		Humanoid.CameraOffset = Vector3.new(0, 0, 0)
		Humanoid.WalkSpeed = 16
		
	end

	wait(0.5)

	Hold = nil
end)


Humanoid.Changed:connect(function()
	if (Humanoid.WalkSpeed > 8) and (Hold == nil) then StandUp() end
end)


end
