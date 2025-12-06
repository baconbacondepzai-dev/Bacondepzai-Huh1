-- ====================================================
-- BACONDEPZAICITYL2 - DELTA AIM + FOV + ESP + HITBOX VFINAL
-- Features:
--  - AutoKill NPC (range +/-)
--  - Player Hitbox (real) (size +/-) -> when ON sets CanCollide=false, CastShadow=false for hitbox parts
--  - AIMLOCK + Aimbot auto-target (switching) + FOV circle (radius +/-)
--  - Animlock (keeps camera orientation locked to target)
--  - ESP: Name + Health + Distance + 3D Box (Highlight)
--  - NoClip + InfJump
--  - Speed +/- 
--  - Teleport/Bring/To/Fling via dropdown player menu (no auto-scaling of player)
--  - UI: rainbow border, rounded corners, toggle image (rbxassetid://116213736389368)
--  - PVP script loader button
--  - Many + / - controls
-- ====================================================

repeat task.wait() until game:IsLoaded()

-- ====== Global Settings ======
getgenv().KillNPC = false
getgenv().KillRange = 600

getgenv().HitboxPlayer = false
getgenv().HitboxSize = 6

getgenv().Aimlock = false
getgenv().AimbotAuto = true
getgenv().FOVRadius = 200 -- pixels
getgenv().FOVVisible = true
getgenv().Animlock = false

getgenv().ESP = false
getgenv().ShowHP = false
getgenv().ShowName = true
getgenv().ShowDistance = true

getgenv().Speed = 16
getgenv().NoClip = false
getgenv().InfJump = false

-- ====== Services ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====== Cleanup old UI ======
pcall(function() game.CoreGui:FindFirstChild("BACONDEPZAICITYL2"):Destroy() end)

-- ====== UI BUILD ======
local GUI = Instance.new("ScreenGui")
GUI.Name = "BACONDEPZAICITYL2"
GUI.Parent = game.CoreGui
GUI.ResetOnSpawn = false

local Main = Instance.new("Frame", GUI)
Main.Name = "Main"
Main.Size = UDim2.new(0, 360, 0, 540)
Main.Position = UDim2.new(0.28, 0, 0.16, 0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0,16)

-- Rainbow border
local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
task.spawn(function()
	while task.wait(0.02) do
		for i=0,1,0.01 do
			stroke.Color = Color3.fromHSV(i,1,1)
			task.wait(0.02)
		end
	end
end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "BACONDEPZAICITYL2 - DELTA ULTIMATE"
Title.TextColor3 = Color3.fromRGB(0,255,200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Toggle image/button (rounded)
local ToggleImg = Instance.new("ImageButton", GUI)
ToggleImg.Name = "ToggleImg"
ToggleImg.Size = UDim2.new(0,56,0,56)
ToggleImg.Position = UDim2.new(0.02,0,0.28,0)
ToggleImg.Image = "rbxassetid://116213736389368"
local tcorner = Instance.new("UICorner", ToggleImg)
tcorner.CornerRadius = UDim.new(0,12)
local tstroke = Instance.new("UIStroke", ToggleImg)
tstroke.Thickness = 2
task.spawn(function()
	while task.wait(0.02) do
		for i=0,1,0.01 do tstroke.Color = Color3.fromHSV(i,1,1); task.wait(0.02) end
	end
end)
ToggleImg.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ===== Page system (3 pages) =====
local Pages = {}
for i=1,3 do
	local p = Instance.new("Frame", Main)
	p.Size = UDim2.new(1,0,1,0)
	p.Position = UDim2.new(0,0,0,0)
	p.BackgroundTransparency = 1
	p.Visible = (i==1)
	Pages[i] = p
end

local pageBtn = Instance.new("TextButton", Main)
pageBtn.Size = UDim2.new(0,140,0,36)
pageBtn.Position = UDim2.new(0.34,0,0.89,0) -- raised a bit
pageBtn.Text = "TRANG 2"
pageBtn.Font = Enum.Font.GothamBold
pageBtn.TextSize = 14
local pageCorner = Instance.new("UICorner", pageBtn)
pageCorner.CornerRadius = UDim.new(0,12)

local curPage = 1
pageBtn.MouseButton1Click:Connect(function()
	Pages[curPage].Visible = false
	curPage = curPage + 1
	if curPage > #Pages then curPage = 1 end
	Pages[curPage].Visible = true
	pageBtn.Text = "TRANG "..(curPage % (#Pages) + 1)
end)

-- helper to create rounded button
local function makeButton(parent, ypos, text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,300,0,36)
	b.Position = UDim2.new(0.03,0,ypos,0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(160,0,0)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

local function setStateButton(btn, on)
	btn.BackgroundColor3 = on and Color3.fromRGB(0,170,0) or Color3.fromRGB(160,0,0)
end

-- ===== Page 1: Combat & Hitbox & AutoKill =====
local autoKillBtn = makeButton(Pages[1],0.12,"AUTO KILL: OFF")
local rangeLabel = Instance.new("TextLabel", Pages[1])
rangeLabel.Size = UDim2.new(0,300,0,24)
rangeLabel.Position = UDim2.new(0.03,0,0.205,0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "KILL RANGE: "..getgenv().KillRange
rangeLabel.TextColor3 = Color3.fromRGB(255,255,255)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 13

local rangePlus = makeButton(Pages[1],0.26,"RANGE +")
local rangeMinus = makeButton(Pages[1],0.34,"RANGE -")

local hitboxBtn = makeButton(Pages[1],0.44,"HITBOX PLAYER: OFF")
local hitboxLabel = Instance.new("TextLabel", Pages[1])
hitboxLabel.Size = UDim2.new(0,300,0,24)
hitboxLabel.Position = UDim2.new(0.03,0,0.52,0)
hitboxLabel.BackgroundTransparency = 1
hitboxLabel.Text = "HITBOX SIZE: "..getgenv().HitboxSize
hitboxLabel.TextColor3 = Color3.fromRGB(255,255,255)
hitboxLabel.Font = Enum.Font.Gotham
hitboxLabel.TextSize = 13

local hitboxPlus = makeButton(Pages[1],0.58,"HITBOX +")
local hitboxMinus = makeButton(Pages[1],0.66,"HITBOX -")

autoKillBtn.MouseButton1Click:Connect(function()
	getgenv().KillNPC = not getgenv().KillNPC
	autoKillBtn.Text = getgenv().KillNPC and "AUTO KILL: ON" or "AUTO KILL: OFF"
	setStateButton(autoKillBtn,getgenv().KillNPC)
end)
rangePlus.MouseButton1Click:Connect(function() getgenv().KillRange += 50; rangeLabel.Text = "KILL RANGE: "..getgenv().KillRange end)
rangeMinus.MouseButton1Click:Connect(function() getgenv().KillRange = math.max(50,getgenv().KillRange - 50); rangeLabel.Text = "KILL RANGE: "..getgenv().KillRange end)

hitboxBtn.MouseButton1Click:Connect(function()
	getgenv().HitboxPlayer = not getgenv().HitboxPlayer
	hitboxBtn.Text = getgenv().HitboxPlayer and "HITBOX PLAYER: ON" or "HITBOX PLAYER: OFF"
	setStateButton(hitboxBtn,getgenv().HitboxPlayer)
	hitboxLabel.Text = "HITBOX SIZE: "..getgenv().HitboxSize
end)
hitboxPlus.MouseButton1Click:Connect(function() getgenv().HitboxSize += 1; hitboxLabel.Text = "HITBOX SIZE: "..getgenv().HitboxSize end)
hitboxMinus.MouseButton1Click:Connect(function() getgenv().HitboxSize = math.max(2,getgenv().HitboxSize - 1); hitboxLabel.Text = "HITBOX SIZE: "..getgenv().HitboxSize end)

-- ===== Page 2: Movement + Aim/ESP =====
local speedLabel = Instance.new("TextLabel", Pages[2])
speedLabel.Size = UDim2.new(0,300,0,24)
speedLabel.Position = UDim2.new(0.03,0,0.08,0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: "..getgenv().Speed
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.Font = Enum.Font.Gotham

local speedUp = makeButton(Pages[2],0.14,"SPEED +")
local speedDown = makeButton(Pages[2],0.22,"SPEED -")

local flyBtn = makeButton(Pages[2],0.32,"FLY: OFF")
local noclipBtn = makeButton(Pages[2],0.4,"NOCLIP: OFF")
local infJumpBtn = makeButton(Pages[2],0.48,"INFJUMP: OFF")

local aimBtn = makeButton(Pages[2],0.58,"AIMLOCK: OFF")
local animlockBtn = makeButton(Pages[2],0.66,"ANIMLOCK: OFF")
local fovLabel = Instance.new("TextLabel", Pages[2])
fovLabel.Size = UDim2.new(0,300,0,24)
fovLabel.Position = UDim2.new(0.03,0,0.74,0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV RADIUS: "..getgenv().FOVRadius
fovLabel.TextColor3 = Color3.fromRGB(255,255,255)
fovLabel.Font = Enum.Font.Gotham

local fovPlus = makeButton(Pages[2],0.8,"FOV +")
local fovMinus = makeButton(Pages[2],0.88,"FOV -")

speedUp.MouseButton1Click:Connect(function() getgenv().Speed += 2; speedLabel.Text = "SPEED: "..getgenv().Speed end)
speedDown.MouseButton1Click:Connect(function() getgenv().Speed = math.max(6,getgenv().Speed - 2); speedLabel.Text = "SPEED: "..getgenv().Speed end)

flyBtn.MouseButton1Click:Connect(function() getgenv().Fly = not getgenv().Fly; flyBtn.Text = getgenv().Fly and "FLY: ON" or "FLY: OFF"; setStateButton(flyBtn,getgenv().Fly) end)
noclipBtn.MouseButton1Click:Connect(function() getgenv().NoClip = not getgenv().NoClip; noclipBtn.Text = getgenv().NoClip and "NOCLIP: ON" or "NOCLIP: OFF"; setStateButton(noclipBtn,getgenv().NoClip) end)
infJumpBtn.MouseButton1Click:Connect(function() getgenv().InfJump = not getgenv().InfJump; infJumpBtn.Text = getgenv().InfJump and "INFJUMP: ON" or "INFJUMP: OFF"; setStateButton(infJumpBtn,getgenv().InfJump) end)

aimBtn.MouseButton1Click:Connect(function() getgenv().Aimlock = not getgenv().Aimlock; aimBtn.Text = getgenv().Aimlock and "AIMLOCK: ON" or "AIMLOCK: OFF"; setStateButton(aimBtn,getgenv().Aimlock) end)
animlockBtn.MouseButton1Click:Connect(function() getgenv().Animlock = not getgenv().Animlock; animlockBtn.Text = getgenv().Animlock and "ANIMLOCK: ON" or "ANIMLOCK: OFF"; setStateButton(animlockBtn,getgenv().Animlock) end)
fovPlus.MouseButton1Click:Connect(function() getgenv().FOVRadius += 20; fovLabel.Text = "FOV RADIUS: "..getgenv().FOVRadius end)
fovMinus.MouseButton1Click:Connect(function() getgenv().FOVRadius = math.max(50,getgenv().FOVRadius - 20); fovLabel.Text = "FOV RADIUS: "..getgenv().FOVRadius end)

-- ===== Page 3: Players dropdown, Teleport, Bring, To, Fling, ESP toggles, PVP loader =====
local dropdownBtn = makeButton(Pages[3],0.06,"CHỌN PLAYER")
local listFrame = Instance.new("ScrollingFrame", Pages[3])
listFrame.Size = UDim2.new(0,300,0,220)
listFrame.Position = UDim2.new(0.03,0,0.18,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,8)
listFrame.CanvasSize = UDim2.new(0,0)

local uiList = Instance.new("UIListLayout", listFrame)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local selectedPlayer = nil
local function refreshList()
	for i,v in pairs(listFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	local count = 0
	for _,p in pairs(Players:GetPlayers()) do
		count = count + 1
		local b = Instance.new("TextButton", listFrame)
		b.Size = UDim2.new(1, -4, 0, 30)
		b.Position = UDim2.new(0,2,0, (count-1)*34)
		b.Text = p.Name
		b.BackgroundColor3 = Color3.fromRGB(70,70,70)
		b.TextColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
		b.MouseButton1Click:Connect(function() selectedPlayer = p; dropdownBtn.Text = "CHỌN: "..p.Name end)
		b.LayoutOrder = count
	end
	listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, count*34))
end
refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(function() refreshList(); if selectedPlayer and not selectedPlayer.Parent then selectedPlayer = nil; dropdownBtn.Text = "CHỌN PLAYER" end end)

local tpBtn = makeButton(Pages[3],0.42,"TELEPORT TO")
local bringBtn = makeButton(Pages[3],0.5,"BRING")
local toBtn = makeButton(Pages[3],0.58,"TO (NEAR)")
local flingBtn = makeButton(Pages[3],0.66,"FLING")
local espToggleBtn = makeButton(Pages[3],0.74,"ESP: OFF")
local showHpBtn = makeButton(Pages[3],0.82,"SHOW HP: OFF")
local pvpLoaderBtn = makeButton(Pages[3],0.9,"BẬT PVP SCRIPT")

dropdownBtn.MouseButton1Click:Connect(function()
	listFrame.Visible = not listFrame.Visible
end)

tpBtn.MouseButton1Click:Connect(function()
	if selectedPlayer and selectedPlayer.Character and lp.Character then
		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then lp.Character.HumanoidRootPart.CFrame = root.CFrame end
	end
end)

bringBtn.MouseButton1Click:Connect(function()
	if selectedPlayer and selectedPlayer.Character and lp.Character then
		local proot = lp.Character:FindFirstChild("HumanoidRootPart")
		local troot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if proot and troot then
			troot.CFrame = proot.CFrame
		end
	end
end)

toBtn.MouseButton1Click:Connect(function()
	if selectedPlayer and selectedPlayer.Character and lp.Character then
		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then lp.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0,0,-3) end
	end
end)

flingBtn.MouseButton1Click:Connect(function()
	if selectedPlayer and selectedPlayer.Character and lp.Character then
		-- fling by moving near quickly and applying BodyVelocity to target
		local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = (targetRoot.Position - lp.Character.HumanoidRootPart.Position).unit * 200
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bv.Parent = lp.Character.HumanoidRootPart
			task.delay(0.15, function() pcall(function() bv:Destroy() end) end)
		end
	end
end)

espToggleBtn.MouseButton1Click:Connect(function()
	getgenv().ESP = not getgenv().ESP
	espToggleBtn.Text = getgenv().ESP and "ESP: ON" or "ESP: OFF"
	setStateButton(espToggleBtn,getgenv().ESP)
end)

showHpBtn.MouseButton1Click:Connect(function()
	getgenv().ShowHP = not getgenv().ShowHP
	showHpBtn.Text = getgenv().ShowHP and "SHOW HP: ON" or "SHOW HP: OFF"
	setStateButton(showHpBtn,getgenv().ShowHP)
end)

pvpLoaderBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/levinh888/Script-ver4/main/script%20outpvp.lua"))()
	end)
end)

-- ===== Drawing FOV Circle (uses Drawing if available) =====
local DrawingAvailable = pcall(function() return Drawing.new end)
local fovCircle = nil
if DrawingAvailable then
	fovCircle = Drawing.new("Circle")
	fovCircle.Color = Color3.fromRGB(255,255,255)
	fovCircle.Thickness = 2
	fovCircle.Transparency = 0.7
	fovCircle.Visible = getgenv().FOVVisible
end

-- ===== Utility: get closest player inside FOV radius (screen-space) =====
local function isValidTarget(plr)
	if not plr.Character or not plr.Character.Parent then return false end
	if plr == lp then return false end
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	local head = plr.Character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return false end
	return true
end

local function getScreenPointFromWorld(pos)
	local succ, screenPos = pcall(function() return Camera:WorldToViewportPoint(pos) end)
	if not succ then return nil end
	return Vector3.new(screenPos.X, screenPos.Y, screenPos.Z)
end

local function getClosestInFOV()
	local best, bestDist, bestPlr = nil, math.huge, nil
	for _,plr in pairs(Players:GetPlayers()) do
		if isValidTarget(plr) then
			local head = plr.Character:FindFirstChild("Head")
			local screen = getScreenPointFromWorld(head.Position)
			if screen and screen.Z > 0 then
				local dx = (screen.X - Camera.ViewportSize.X/2)
				local dy = (screen.Y - Camera.ViewportSize.Y/2)
				local dist = math.sqrt(dx*dx + dy*dy)
				if dist <= getgenv().FOVRadius and dist < bestDist then
					bestDist = dist
					bestPlr = plr
				end
			end
		end
	end
	return bestPlr, bestDist
end

-- ===== ESP management =====
local espStore = {}
local function createESPFor(plr)
	if not plr.Character then return end
	if espStore[plr] then return end

	-- Highlight box 3D
	local h = Instance.new("Highlight")
	h.Name = "DeltaESPHighlight"
	h.Parent = plr.Character
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = Color3.fromRGB(255,0,0)

	-- Billboard for text
	local head = plr.Character:FindFirstChild("Head")
	if head then
		local bg = Instance.new("BillboardGui", plr.Character)
		bg.Name = "DeltaESPBill"
		bg.Adornee = head
		bg.Size = UDim2.new(4,0,2,0)
		bg.AlwaysOnTop = true

		local label = Instance.new("TextLabel", bg)
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255,255,255)
		label.TextScaled = true
		label.Text = plr.Name

		espStore[plr] = {highlight = h, bill = bg, label = label}
	end
end

local function removeESPFor(plr)
	local s = espStore[plr]
	if s then
		pcall(function() if s.highlight then s.highlight:Destroy() end end)
		pcall(function() if s.bill then s.bill:Destroy() end end)
		espStore[plr] = nil
	end
end

-- update ESP text each frame
RunService.RenderStepped:Connect(function()
	-- draw FOV circle
	if DrawingAvailable and fovCircle then
		local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
		fovCircle.Radius = getgenv().FOVRadius
		fovCircle.Position = center
		fovCircle.Visible = getgenv().FOVVisible and getgenv().Aimlock
		fovCircle.Color = Color3.fromHSV((tick()%5)/5,1,1)
	end

	-- update ESP display
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character then
			if getgenv().ESP then
				if not espStore[plr] then createESPFor(plr) end
				local s = espStore[plr]
				if s and s.label and plr.Character:FindFirstChildOfClass("Humanoid") then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local head = plr.Character:FindFirstChild("Head")
					local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and head) and math.floor((head.Position - lp.Character.HumanoidRootPart.Position).Magnitude) or 0
					local text = ""
					if getgenv().ShowName then text = text..plr.Name end
					if getgenv().ShowHP and hum then text = text.." | "..math.floor(hum.Health) end
					if getgenv().ShowDistance and dist then text = text.." | "..dist.."m" end
					s.label.Text = text
				end
			else
				if espStore[plr] then removeESPFor(plr) end
			end
		else
			if espStore[plr] then removeESPFor(plr) end
		end
	end
end)

-- ===== Hitbox behaviour: when ON, make target players' HRP sized, CanCollide=false, CastShadow=false =====
local function applyHitboxToAll()
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			pcall(function()
				hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
				hrp.CanCollide = false
				hrp.CastShadow = false
				hrp.Transparency = 0.6
			end)
		end
	end
end

local function restoreHitboxToAll()
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			pcall(function()
				hrp.Size = Vector3.new(2,2,1)
				hrp.CanCollide = true
				hrp.CastShadow = true
				hrp.Transparency = 0
			end)
		end
	end
end

-- ===== Auto-target & Aimlock loop =====
local currentTarget = nil
local aimbotSwitchTick = 0
task.spawn(function()
	while task.wait(0.02) do
		-- Auto-select target in FOV if AimbotAuto true
		if getgenv().AimbotAuto and getgenv().Aimlock then
			aimbotSwitchTick = aimbotSwitchTick + 0.02
			if aimbotSwitchTick >= 0.45 then -- switch target every 0.45s
				aimbotSwitchTick = 0
				local candidate = getClosestInFOV()
				currentTarget = candidate
			end
		end

		-- Aimlock action
		if getgenv().Aimlock and currentTarget and isValidTarget(currentTarget) then
			local head = currentTarget.Character:FindFirstChild("Head")
			if head and Camera and Camera.CFrame then
				if getgenv().Animlock then
					-- keep camera facing the target head (Animlock = more persistent orientation)
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
				else
					-- aim assist: smoothly rotate camera towards target head
					local camPos = Camera.CFrame.Position
					local dir = (head.Position - camPos).unit
					local targetCFrame = CFrame.new(camPos, camPos + dir)
					Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.35)
				end
			end
		end

		-- Hitbox apply/restore
		if getgenv().HitboxPlayer then
			applyHitboxToAll()
		else
			restoreHitboxToAll()
		end
	end
end)

-- ===== NoClip / InfJump / Speed / Fly =====
-- Fly implementation uses BodyVelocity and PlatformStand toggle for stability
local flyBV = nil
local flyActive = false
local function startFly()
	if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
	if flyActive then return end
	flyActive = true
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
	flyBV.Velocity = Vector3.new(0,0,0)
	flyBV.Parent = lp.Character.HumanoidRootPart
end
local function stopFly()
	if flyBV then pcall(function() flyBV:Destroy() end) end
	flyBV = nil
	flyActive = false
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	-- toggle cam-aim off on right click? (user can use UI)
end)

RunService.Stepped:Connect(function()
	-- Speed
	if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
		pcall(function() lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = getgenv().Speed end)
	end
	-- NoClip
	if getgenv().NoClip and lp.Character then
		for _,part in pairs(lp.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
	-- Fly
	if getgenv().Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
		if not flyActive then startFly() end
		-- basic control: move towards camera look direction when pressing keys
		local mv = Vector3.new(0,0,0)
		if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + (Camera.CFrame.LookVector) end
		if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - (Camera.CFrame.LookVector) end
		if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - (Camera.CFrame.RightVector) end
		if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + (Camera.CFrame.RightVector) end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
		if flyBV then flyBV.Velocity = mv.unit * (getgenv().Speed + 20) end
	else
		if flyActive then stopFly() end
	end
end)

UIS.JumpRequest:Connect(function()
	if getgenv().InfJump then
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ===== AutoKill NPC loop (same reliable method) =====
task.spawn(function()
	while task.wait(0.14) do
		if getgenv().KillNPC and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = lp.Character.HumanoidRootPart
			for _,v in pairs(Workspace:GetChildren()) do
				if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) then
					local hum = v:FindFirstChildOfClass("Humanoid")
					local root = v:FindFirstChild("HumanoidRootPart")
					if hum and root and hum.Health > 0 and (root.Position - hrp.Position).Magnitude <= getgenv().KillRange then
						pcall(function() hum.Health = 0; v:BreakJoints() end)
					end
				end
			end
		end
	end
end)

-- ===== Utility: restore things on unload/exit =====
local function cleanupAll()
	-- restore hitboxes
	restoreHitboxToAll()
	-- remove ESP highlight objects
	for p,s in pairs(espStore) do
		removeESPFor(p)
	end
	-- remove drawing
	if DrawingAvailable and fovCircle then pcall(function() fovCircle:Remove() end) end
end

-- ensure cleanup on disable/unload
game:BindToClose(function()
	cleanupAll()
end)

-- ===== Final quick status =====
print("✅ BACONDEPZAICITYL2 - DELTA ULTIMATE LOADED")
