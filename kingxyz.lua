--=========================
-- 🔥 Lib Load Screen Reaper Hub 7
--=========================
local Load = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Libwtf/refs/heads/main/libload2.lua"))() 
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Advanced/refs/heads/main/gui/InterfaceManager.lua"))()

--=========================
-- 🔥 SERVICES
--=========================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local lighting = Lighting
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")	
local DefaultZoom = LocalPlayer.CameraMaxZoomDistance
local LogService = game:GetService("LogService")
local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer
local Camera = workspace.CurrentCamera
local lp = LocalPlayer

-- WINDOW
local Window = Fluent:CreateWindow({
Title = "REAPER HUB",
SubTitle = "Universal",
TabWidth = 160,
Size = UDim2.fromOffset(520, 360),
Theme = "ExtremeReaper",
MinimizeKey = Enum.KeyCode.RightControl
})

local icon = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2sxqz/Libwtf/refs/heads/main/Icon.lua"))()

--=========================
-- 🔥Tab
--=========================
local Tabs = {
Status = Window:AddTab({ Title = "Status", Icon = "signal-high" }),
Credit = Window:AddTab({ Title = "Credit", Icon = "code" }),
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Player = Window:AddTab({ Title = "Player", Icon = "user" }),
ESP = Window:AddTab({ Title = "ESP", Icon = "box" }),
Teleport = Window:AddTab({ Title = "Teleport", Icon = "menu" }),
Server = Window:AddTab({ Title = "Server", Icon = "server" }),
Misc = Window:AddTab({ Title = "Misc", Icon = "copy" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--=========================
-- 🔥 STATE
--=========================
local State = {
    WS = false,
    JP = false,
    INFJ = false,
    NC = false,
    ESP_Box = false, 
    ESP_Line = false,
	MemClean = false
}

local WSValue = 16
local JPValue = 50

local DefaultWS = 16
local DefaultJP = 50

local initialized = false

--=========================
-- 🔥 NOCLIP LOGIC
--=========================
local NoclipConnection
local function SetNoclip(state)
    State.NC = state
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        -- คืนค่า CanCollide ให้ตัวละคร (Optional: ปกติ Roblox จะคืนค่าให้เองเมื่อหยุดเซ็ต false)
    end
end


--=========================
-- 🔥 CHARACTER HOOK
--=========================
local function HookChar(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)

    -- 🔥 FIX: ล็อก default แค่ครั้งเดียว (กันค่าค้าง/เพี้ยนตอน respawn)
    if not initialized then
        DefaultWS = hum.WalkSpeed
        DefaultJP = hum.UseJumpPower and hum.JumpPower or 50
        initialized = true
    end
end

if LP.Character then HookChar(LP.Character) end
LP.CharacterAdded:Connect(HookChar)

--=========================
-- 🔥 GET HUM
--=========================
local function GetHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

--=========================
-- 🔥 MOVEMENT
--=========================
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

       -- WalkSpeed (ทำงานเฉพาะตอนเปิด)
    if State.WS then
        hum.WalkSpeed = WSValue
    end

    -- JumpPower (ทำงานเฉพาะตอนเปิด)
    if State.JP then
        hum.UseJumpPower = true
        hum.JumpPower = JPValue
    end
end)


--=========================
-- 🔥 INFINITE JUMP
--=========================
UIS.JumpRequest:Connect(function()
    if State.INFJ then
        local hum = GetHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--=========================
-- 🔥 ESP SYSTEM (OPTIMIZED FINAL)
--=========================
local ESPObjects = {}
local Cache = {}

local BoxColor = Color3.fromRGB(255,255,255)
local LineColor = Color3.fromRGB(255,255,255)

local ESPConnection

--=========================
-- 🔥 CREATE ESP
--=========================
local function CreateESP()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false

    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = 1

    return {box = box, line = line}
end

--=========================
-- 🔥 CLEAR ESP (NO LEAK)
--=========================
local function ClearESP()
    for plr,v in pairs(ESPObjects) do
        if v.box then v.box:Remove() end
        if v.line then v.line:Remove() end
        ESPObjects[plr] = nil
    end
    Cache = {}
end

--=========================
-- 🔥 CHARACTER CACHE
--=========================
local function SetupCharacter(plr, char)
    task.spawn(function()
        -- รอชิ้นส่วนสำคัญ 10 วินาที (กันพวกโหลดช้าแล้ว ESP ไม่ขึ้น)
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        local head = char:WaitForChild("Head", 10)
        local hum = char:WaitForChild("Humanoid", 10)

        if hrp and head and hum then
            -- บันทึกลงตะกร้า Cache
            Cache[plr] = { 
                hrp = hrp, 
                head = head, 
                hum = hum 
            }
            
            -- ถ้าตัวละครตาย ให้เคลียร์ Cache ทันทีเพื่อให้ ESP หายไป
            hum.Died:Connect(function() 
                Cache[plr] = nil 
            end)
        end
    end)
end


  
--=========================
-- 🔥 ESP LOGIC CONNECTOR
--=========================
local function InitESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            -- 1. สร้าง Object Drawing รอไว้
            if not ESPObjects[plr] then ESPObjects[plr] = CreateESP() end
            -- 2. สั่งให้เริ่มเก็บข้อมูลตัวละคร (ถ้าตัวละครโหลดแล้ว)
            if plr.Character then SetupCharacter(plr, plr.Character) end
            -- 3. ดักจับตอนเกิดใหม่
            plr.CharacterAdded:Connect(function(char) SetupCharacter(plr, char) end)
        end
    end
end

-- ดักจับผู้เล่นใหม่ที่เพิ่งเข้าเซิร์ฟเวอร์
Players.PlayerAdded:Connect(function(plr)
    if plr == LP then return end
    if not ESPObjects[plr] then ESPObjects[plr] = CreateESP() end
    plr.CharacterAdded:Connect(function(char) SetupCharacter(plr, char) end)
end)

-- ลบข้อมูลทิ้งเมื่อผู้เล่นออกจากเกม (กัน Memory Leak)
Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        if ESPObjects[plr].box then ESPObjects[plr].box:Remove() end
        if ESPObjects[plr].line then ESPObjects[plr].line:Remove() end
        ESPObjects[plr] = nil
    end
    Cache[plr] = nil
end)




--=========================
-- 🔥 START LOOP (ANTI DUPLICATE)
--=========================
local function StartESP()
    if ESPConnection then
        ESPConnection:Disconnect()
    end

    ESPConnection = RunService.RenderStepped:Connect(function()
        -- 1. เช็คว่าถ้าปิดทั้งคู่ ให้ซ่อน Object ทั้งหมดแล้วหยุดทำงานเฟรมนี้
        if not State.ESP_Box and not State.ESP_Line then 
            for _, obj in pairs(ESPObjects) do
                obj.box.Visible = false
                obj.line.Visible = false
            end
            return 
        end

        local camSize = Camera.ViewportSize

        for plr, obj in pairs(ESPObjects) do
            local data = Cache[plr]
            if not data or not data.hrp or not data.head then
                obj.box.Visible = false
                obj.line.Visible = false
                continue
            end

            local rootPos, onScreen = Camera:WorldToViewportPoint(data.hrp.Position)

            if onScreen then
                local headPos = Camera:WorldToViewportPoint(data.head.Position)
                local height = math.abs(headPos.Y - rootPos.Y) * 2
                local width = height / 1.5

                -- 🔥 แยกเปิด-ปิด BOX
                if State.ESP_Box then
                    obj.box.Size = Vector2.new(width, height)
                    obj.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    obj.box.Color = BoxColor
                    obj.box.Visible = true
                else
                    obj.box.Visible = false
                end

                -- 🔥 แยกเปิด-ปิด LINE
                if State.ESP_Line then
                    obj.line.From = Vector2.new(camSize.X/2, camSize.Y)
                    obj.line.To = Vector2.new(rootPos.X, rootPos.Y)
                    obj.line.Color = LineColor
                    obj.line.Visible = true
                else
                    obj.line.Visible = false
                end
            else
                -- ถ้าไม่อยู่บนหน้าจอ ให้ซ่อน
                obj.box.Visible = false
                obj.line.Visible = false
            end
        end
    end)
end




--=========================
-- 🔥 ENABLE ESP
--=========================
InitESP()
StartESP()

--=========================
-- 🔥 UI
--=========================
Tabs.Player:AddInput("WSV", {
Title = "Speed Value",
Default = "16",
Callback = function(v)
WSValue = tonumber(v) or 16
end
})

Tabs.Player:AddToggle("WS", {
    Title = "WalkSpeed",
    Default = false,
    Callback = function(v) 
        State.WS = v 
        if not v then 
            local hum = GetHum()
            if hum then 
                --  เปลี่ยนจาก 16 เป็น DefaultWS (ค่าที่เราดูดไว้ตอนรันสคริปต์)
                hum.WalkSpeed = DefaultWS 
            end 
        end
    end
})

Tabs.Player:AddInput("JPV", {
Title = "Jump Value",
Default = "50",
Callback = function(v)
JPValue = tonumber(v) or 50
end
})

Tabs.Player:AddToggle("JP", {
    Title = "JumpPower",
    Default = false,
    Callback = function(v) 
        State.JP = v 
        if not v then 
            local hum = GetHum()
            if hum then 
                --  เปลี่ยนจาก 50 เป็น DefaultJP
                hum.JumpPower = DefaultJP
                hum.UseJumpPower = false
            end 
        end
    end
})

--=========================
-- 🔥 GRAVITY SYSTEM (SAFE & CLEAN)
--=========================
local DefaultGravity = workspace.Gravity -- 1. แค่จดจำค่าเดิมของเกมไว้ (ไม่สั่งเปลี่ยน)
local TargetGravityValue = 196.2

-- 2. Slider สำหรับเลือกค่า (เลื่อนได้อิสระ แต่ค่าในเกมจะยังไม่เปลี่ยน)
Tabs.Player:AddSlider("GravitySlider", {
    Title = "Gravity Level",
    Description = "",
    Default = 196.2,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value)
        TargetGravityValue = Value
        -- ถ้าเปิด Toggle อยู่ ให้เปลี่ยนแรงโน้มถ่วงทันทีตามมือที่เลื่อน
        if _G.GravityEnabled then
            workspace.Gravity = Value
        end
    end
})

-- 3. Toggle: สวิตช์หลัก (จุดนี้จุดเดียวที่จะสั่งเปลี่ยนค่าในเกม)
Tabs.Player:AddToggle("GravityToggle", {
    Title = "Enable Gravity",
    Default = false,
    Callback = function(Value)
        _G.GravityEnabled = Value
        
        if Value then
            -- เมื่อเปิด: สั่งเปลี่ยนแรงโน้มถ่วงเป็นค่าที่เราเลือกไว้ใน Slider
            workspace.Gravity = TargetGravityValue
        else
            -- เมื่อปิด: คืนค่าเดิมของเกมทันที (ค่าที่จดไว้ตอนรันสคริปต์)
            workspace.Gravity = DefaultGravity
        end
    end
})


-- Fly Mode 🔥
-- === ตัวแปรระบบบิน ===
local flying = false
local speed = 60
local bv, bg

-- === ฟังก์ชันหยุดบิน ===
local function stopFlying()
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

-- === ฟังก์ชันเริ่มบิน ===
local function startFlying()
    local char = LocalPlayer.Character
    -- รอให้ชิ้นส่วนตัวละครโหลดครบก่อนเริ่มบิน (กันบัคตอนเกิดใหม่)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    
    if not root or not hum then return end
    
    -- ล้างของเก่าก่อนสร้างใหม่ (กันซ้อน)
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9e4
    bg.Parent = root
    
    hum.PlatformStand = true
    
    -- ลูปการเคลื่อนที่
    task.spawn(function()
        while flying and char == LocalPlayer.Character do
            RunService.RenderStepped:Wait()
            local cam = workspace.CurrentCamera
            
            local moveInput = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls():GetMoveVector()
            local direction = (cam.CFrame.LookVector * -moveInput.Z) + (cam.CFrame.RightVector * moveInput.X)
            
            if direction.Magnitude > 0 then
                bv.Velocity = direction * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = cam.CFrame
        end
    end)
end

-- === ระบบทำงานต่ออัตโนมัติเมื่อเกิดใหม่ ===
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if flying then
        -- รอแป๊บนึงให้ระบบฟิสิกส์ของตัวละครใหม่พร้อม
        task.wait(0.5) 
        if flying then startFlying() end
    end
end)

-- === เพิ่มเข้า Fluent UI (Tabs.Player) ===
Tabs.Player:AddToggle("FlyToggle", {
    Title = "Fly Mode", 
    Default = false,
    Callback = function(Value)
        flying = Value
        if flying then
            startFlying()
        else
            stopFlying()
        end
    end
})

Tabs.Player:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "ปรับความเร็วการบิน",
    Default = 60,
    Min = 10,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        speed = Value
    end
})


Tabs.Player:AddToggle("INFJ", {
Title = "Infinite Jump",
Default = false,
Callback = function(v) State.INFJ = v 
	end
})

Tabs.Player:AddToggle("NC", { -- เปลี่ยน ID เป็น NC
    Title = "Noclip",
    Description = "",
    Default = false,
    Callback = function(Value)
        SetNoclip(Value) -- ส่งค่าไปให้ฟังก์ชันจัดการต่อ
    end
})


-- มึงอย่ามาล้อเล่นกับเดอะหมุน
--================ SPIN PLAYER FIX =================--
local spinning = false
local spinSpeed = 20
local spinConnection

-- ดึง HRP แบบชัวร์

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- เริ่มหมุน (ใช้ dt กันเฟรมเรท)
local function startSpin()
    if spinConnection then
        spinConnection:Disconnect()
    end

    spinConnection = RunService.RenderStepped:Connect(function(dt)
        local hrp = getHRP()
        if not hrp then return end

        -- ใช้ dt ทำให้ลื่นขึ้น
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed * dt * 60), 0)
    end)
end

-- หยุด
local function stopSpin()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
end

-- รีตัวไม่พัง
LocalPlayer.CharacterAdded:Connect(function()
    if spinning then
        task.wait(1)
        startSpin()
    end
end)

-- Toggle
Tabs.Player:AddToggle("SpinPlayer", {
    Title = "Spin Player",
    Default = false,
    Callback = function(v)
        spinning = v

        if v then
            startSpin()
        else
            stopSpin()
        end
    end
})

-- Slider
Tabs.Player:AddSlider("SpinSpeed", {
    Title = "Spin Speed",
    Min = 1,
    Max = 1000,
    Default = 1,
	Rounding = 0,
    Callback = function(v)
        spinSpeed = v
    end
})

-- ESP Chams🔥
local ChamsCache = {} -- ตะกร้าเก็บ Highlight เพื่อลดภาระการหา (Optimization)

-- [[ 1. LOGIC: ระบบ Chams ที่ปรับจูนมาเพื่อความลื่น (วางไว้ด้านบน) ]]
RunService.Heartbeat:Connect(function()
    if not _G.ChamsEnabled then 
        -- ถ้าปิดอยู่ และในตะกร้ายังมีของ ให้เคลียร์ทิ้งทีเดียว
        if next(ChamsCache) ~= nil then
            for char, hl in pairs(ChamsCache) do
                if hl then hl:Destroy() end
            end
            ChamsCache = {} -- ล้างตะกร้า
        end
        return 
    end

    local rainbowColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = ChamsCache[char] -- ดึงจากตะกร้า (เร็วที่สุด)

            if not highlight then
                -- ถ้าหาในตะกร้าไม่เจอ ให้ไปดูในตัวละคร (เผื่อคนเพิ่งเกิด)
                highlight = char:FindFirstChild("FullChams")
                
                if not highlight then
                    -- สร้างใหม่และตั้งค่าพื้นฐาน (ทำแค่ครั้งเดียว!)
                    highlight = Instance.new("Highlight")
                    highlight.Name = "FullChams"
                    highlight.Parent = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                end
                -- เก็บเข้าตะกร้าไว้ใช้ในเฟรมถัดไป
                ChamsCache[char] = highlight
            end
            
            -- บรรทัดเดียวที่รันทุกเฟรม: เปลี่ยนสี (เบามาก)
            highlight.FillColor = rainbowColor
        end
    end
end)

Tabs.ESP:AddToggle("ChamsToggle", {
    Title = "ESP Chams (Rainbow)",
    Default = false,
    Callback = function(v)
        _G.ChamsEnabled = v
    end
})


--ESP
-- Toggle สำหรับ Box
Tabs.ESP:AddToggle("ESP_Box_Toggle", {
    Title = "ESP Box",
    Default = false,
    Callback = function(v)
        State.ESP_Box = v
        if v and next(ESPObjects) == nil then 
            InitESP() 
        end
    end
})

-- Toggle สำหรับ Line
Tabs.ESP:AddToggle("ESP_Line_Toggle", {
    Title = "ESP Line",
    Default = false,
    Callback = function(v)
        State.ESP_Line = v
        if v and next(ESPObjects) == nil then 
            InitESP() 
        end
    end
})


Tabs.ESP:AddColorpicker("BoxColor", {
Title = "Box Color",
Default = BoxColor,
Callback = function(v)
if typeof(v) == "Color3" then
BoxColor = v
end
end
})

Tabs.ESP:AddColorpicker("LineColor", {
Title = "Line Color",
Default = LineColor,
Callback = function(v)
if typeof(v) == "Color3" then
LineColor = v
end
end
})

-- ESP NAME & Health bar🔥
--========================
-- SETTINGS
--========================
local MaxDistance = 3500

_G.NameESPEnabled = false
_G.HealthESPEnabled = false
_G.DistanceESPEnabled = false -- เพิ่มบรรทัดนี้


--========================
-- CACHE
--========================
local ESPCache = {}

--========================
-- CREATE ESP
--========================
--========================
-- CREATE ESP (Billboard Version)
--========================
local function CreateESP(Player)
    if Player == LocalPlayer then return end

    -- สร้าง Billboard สำหรับชื่อและระยะทาง (คมชัดกว่า)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ReaperTag"
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    Billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local NameLabel = Instance.new("TextLabel", Billboard)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(1, 0, 1, 0)
    NameLabel.Text = ""
    NameLabel.Font = Enum.Font.RobotoMono -- ฟอนต์ RobotoMono ตามสั่ง
    NameLabel.TextSize = 14
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextStrokeTransparency = 0
    NameLabel.RichText = true

    -- ระบบแถบเลือด Drawing (คงไว้ตามเดิม)
    local HealthOutline = Drawing.new("Square")
    HealthOutline.Visible = false
    HealthOutline.Filled = true
    HealthOutline.Thickness = 0
    HealthOutline.Color = Color3.fromRGB(0,0,0)
    HealthOutline.Transparency = 0.6

    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Filled = true
    HealthBar.Thickness = 0
    HealthBar.Color = Color3.fromRGB(0,255,100)
    HealthBar.Transparency = 1

    ESPCache[Player] = {
        Billboard = Billboard,
        NameLabel = NameLabel,
        HealthOutline = HealthOutline,
        HealthBar = HealthBar
    }
end

local function RemoveESP(Player)
    local ESP = ESPCache[Player]
    if ESP then
        if ESP.Billboard then ESP.Billboard:Destroy() end
        if ESP.HealthOutline then ESP.HealthOutline:Remove() end
        if ESP.HealthBar then ESP.HealthBar:Remove() end
        ESPCache[Player] = nil
    end
end

local function HideESP(ESP)
    if ESP.Billboard then ESP.Billboard.Enabled = false end
    ESP.HealthOutline.Visible = false
    ESP.HealthBar.Visible = false
end



--========================
-- PLAYER HANDLING
--========================
for _,Player in ipairs(Players:GetPlayers()) do
    CreateESP(Player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--========================
-- MAIN RENDER
--========================
RunService.RenderStepped:Connect(function()

    for Player,ESP in pairs(ESPCache) do

        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Head = Character and Character:FindFirstChild("Head")

        --========================
        -- VALIDATION
        --========================
        if not Character
        or not Humanoid
        or not Root
        or not Head
        or Humanoid.Health <= 0 then

            HideESP(ESP)
            continue
        end

        --========================
        -- DISTANCE
        --========================
        local Distance = (Camera.CFrame.Position - Root.Position).Magnitude

        if Distance > MaxDistance then
            HideESP(ESP)
            continue
        end

        --========================
        -- VIEWPORT
        --========================
        local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

        if not OnScreen then
            HideESP(ESP)
            continue
        end

        local HeadPos = Camera:WorldToViewportPoint(
            Head.Position + Vector3.new(0,0.6,0)
        )

        local LegPos = Camera:WorldToViewportPoint(
            Root.Position - Vector3.new(0,3,0)
        )

        --========================
        -- SCALE
        --========================
        local Height = math.abs(HeadPos.Y - LegPos.Y)
        local Width = Height / 2

        local X = RootPos.X - Width / 2
        local Y = RootPos.Y - Height / 2

                --========================
        -- NAME & DISTANCE ESP
        --========================
                --========================
        -- NAME & DISTANCE ESP (Format: NAME [ Distance ])
        --========================
        if _G.NameESPEnabled or _G.DistanceESPEnabled then
            ESP.Billboard.Enabled = true
            ESP.Billboard.Parent = Head
            
            local NameTag = _G.NameESPEnabled and Player.Name or "" -- ใช้ Username
            local DistTag = _G.DistanceESPEnabled and string.format(" <font color='#AAAAAA'>[ %dm ]</font>", math.floor(Distance)) or ""
            
            -- รวมข้อความ NAME [ Distance ]
            if _G.NameESPEnabled and _G.DistanceESPEnabled then
                ESP.NameLabel.Text = NameTag .. " " .. DistTag
            else
                ESP.NameLabel.Text = NameTag .. DistTag
            end
            
            -- ปรับขนาดตามระยะทาง
            ESP.NameLabel.TextSize = math.clamp(16 - (Distance / 150), 12, 16)
        else
            if ESP.Billboard then ESP.Billboard.Enabled = false end
        end




        --========================
        -- HEALTH BAR
        --========================
        if _G.HealthESPEnabled then

            local HealthPercent = math.clamp(
                Humanoid.Health / Humanoid.MaxHealth,
                0,
                1
            )

            local BarHeight = Height * HealthPercent

            local BarX = X - 7
            local BarY = Y

            -- OUTLINE
            ESP.HealthOutline.Visible = true
            ESP.HealthOutline.Size = Vector2.new(
                4,
                Height + 2
            )

            ESP.HealthOutline.Position = Vector2.new(
                BarX - 1,
                BarY - 1
            )

            -- BAR
            ESP.HealthBar.Visible = true
            ESP.HealthBar.Size = Vector2.new(
                2,
                BarHeight
            )

            ESP.HealthBar.Position = Vector2.new(
                BarX,
                BarY + (Height - BarHeight)
            )

            -- HEALTH COLOR
            ESP.HealthBar.Color = Color3.fromRGB(
                255 - (255 * HealthPercent),
                255 * HealthPercent,
                0
            )

        else

            ESP.HealthOutline.Visible = false
            ESP.HealthBar.Visible = false
        end
    end
end)

--========================
-- TOGGLES
--========================
Tabs.ESP:AddToggle("NameESP", {
    Title = "ESP Name",
    Default = false,
    Callback = function(v)
        _G.NameESPEnabled = v
    end
})

Tabs.ESP:AddToggle("HealthESP", {
    Title = "ESP Health",
    Default = false,
    Callback = function(v)
        _G.HealthESPEnabled = v
    end
})

Tabs.ESP:AddToggle("DistanceESP", {
    Title = "ESP Distance",
    Default = false,
    Callback = function(v)
        _G.DistanceESPEnabled = v
    end
})


-- ค่าเริ่มต้น
local hitboxEnabled = false
local hitboxSize = 6
local minSize = 1
local maxSize = 50

-- ฟังก์ชันจัดการ Hitbox (ตัวนี้จะทำงานแค่ครั้งเดียวเมื่อถูกเรียก)
local function applyHitbox(player)
    if player == LocalPlayer then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root then return end

    if hitboxEnabled then
        -- ขยาย Hitbox
        root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        root.Transparency = 0.6
        root.Material = Enum.Material.ForceField
        root.Color = Color3.fromRGB(255, 0, 0)
        root.CanCollide = false
    else
        -- คืนค่าปกติ
        root.Size = Vector3.new(2, 2, 1)
        root.Transparency = 1
        root.Material = Enum.Material.Plastic
        root.CanCollide = true
    end
end

-- ฟังก์ชันอัปเดตทุกคนในเซิร์ฟเวอร์พร้อมกัน (ใช้ตอนเปิด/ปิด หรือเปลี่ยนขนาด)
local function refreshAll()
    for _, p in ipairs(Players:GetPlayers()) do
        pcall(applyHitbox, p)
    end
end

-- ระบบ Event: จัดการคนที่เกิดใหม่ หรือคนที่เพิ่งเข้าเกม (ไม่ต้องใช้ Loop)
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- รอตัวละครโหลดเสร็จแป๊บนึง
        applyHitbox(player)
    end)
end

-- รันระบบ Event สำหรับทุกคน
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)

-- UI: TOGGLE
Tabs.ESP:AddToggle("HitboxToggle", {
    Title = "Hitbox Expand",
    Default = false,
    Callback = function(v)
        hitboxEnabled = v
        refreshAll() -- อัปเดตทุกคนทันทีที่กดปุ่ม
    end
})

-- UI: INPUT (แทน Slider เดิม)
Tabs.ESP:AddInput("HitboxSizeInput", {
    Title = "Hitbox Size (" .. minSize .. "-" .. maxSize .. ")",
    Default = tostring(hitboxSize),
    Placeholder = "...",
    NumericOnly = true,
    Finished = false, -- เปลี่ยนค่าทันทีที่พิมพ์
    Callback = function(v)
        local num = tonumber(v)
        if num then
            -- จำกัดค่าไว้ที่ 1 - 50 เพื่อความปลอดภัย
            hitboxSize = math.clamp(num, minSize, maxSize)
            
            -- ถ้าเปิดใช้งานอยู่ ให้รีเฟรชขนาดทันทีที่พิมพ์เลข
            if hitboxEnabled then
                refreshAll()
            end
        end
    end
})




--========================
-- TIME
--========================
local startTime = tick()

local function formatTime(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    return string.format("%02d:%02d:%02d", h, m, sec)
end


-- Key Times
--=========================
-- 🔑 KEY EXPIRY DISPLAY & AUTO REJOIN
--=========================
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FIREBASE_BASE_URL = "https://keysystem-reaper-default-rtdb.asia-southeast1.firebasedatabase.app/keys"
local KEY_FILE = "reaper_saved_key.txt"

local ExpiryLabel = Tabs.Status:AddParagraph({
    Title = "Key Remaining Time",
    Content = "Fetching data..."
})

local function startKeyTimer()
    task.spawn(function()
        if not isfile(KEY_FILE) then 
            ExpiryLabel:SetDesc("Status: No key file found")
            return 
        end
        
        local rawKey = readfile(KEY_FILE)
        local savedKey = rawKey:gsub("%s+", "") 
        
        local success, response = pcall(function()
            return game:HttpGet(string.format("%s/%s.json", FIREBASE_BASE_URL, savedKey))
        end)

        if success and response and response ~= "null" then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
            
            if decodeSuccess and data and data.expiresAt then
                if data.hwid == "" or data.hwid == nil or data.hwid == gethwid() then
                    local targetTime = tonumber(data.expiresAt) / 1000 
                    
                    while true do
                        local timeLeft = targetTime - os.time()
                        
                        if timeLeft > 0 then
                            local d = math.floor(timeLeft / 86400)
                            local h = math.floor((timeLeft % 86400) / 3600)
                            local m = math.floor((timeLeft % 3600) / 60)
                            local s = math.floor(timeLeft % 60)
                            
                            local displayStr = ""
                            
                            -- [คงไว้ตามต้นฉบับของคุณเป๊ะๆ]
                            if d > 0 then
                                displayStr = string.format("%d Days : %d Hours : %d Minutes : %d s", d, h, m, s)
                            elseif h > 0 then
                                displayStr = string.format("%d Hours : %d Minutes : %d s", h, m, s)
                            elseif m > 0 then
                                displayStr = string.format("%d Minutes : %d s", m, s)
                            else
                                displayStr = string.format("%d s", s)
                            end
                            
                            ExpiryLabel:SetDesc(displayStr)
                        else
                            -- [ส่วนที่ปรับปรุง: เมื่อหมดเวลาให้ Rejoin รัวๆ]
                            ExpiryLabel:SetDesc("Status: Key Expired!")
                            while true do
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                                end)
                                task.wait(0.5) -- ความเร็วในการพยายาม Rejoin (0.5 วินาที)
                            end
                            break
                        end
                        task.wait(1)
                    end
                    return
                end
            end
        end
        ExpiryLabel:SetDesc("Status: No Active Session")
    end)
end

startKeyTimer()






-- แสดงข้อมูล Profile ในแท็บ Status ที่อยู่ใน Table Tabs
Tabs.Status:AddParagraph({
    Title = "Player Profile",
    Content = "Display Name: " .. lp.DisplayName .. "\nUsername: @" .. lp.Name
})

local TimeLabel = Tabs.Status:AddParagraph({
    Title = "Time",
    Content = "Loading..."
})

local PlayerLabel = Tabs.Status:AddParagraph({
    Title = "Players",
    Content = "Loading..."
})

local PingLabel = Tabs.Status:AddParagraph({
    Title = "Ping",
    Content = "Loading..."
})

local FPSLabel = Tabs.Status:AddParagraph({
    Title = "FPS",
    Content = "Loading..."
})

--========================
-- FPS (REALISTIC)
--========================
local fps = 60
local frameCount = 0
local timeElapsed = 0

RunService.RenderStepped:Connect(function(dt)
    -- กันค่าเพี้ยน
    if dt <= 0 or dt > 0.1 then return end

    frameCount += 1
    timeElapsed += dt

    -- อัปเดตทุก 0.5 วิ
    if timeElapsed >= 0.5 then
        local rawFps = frameCount / timeElapsed

        -- จำกัดค่า
        rawFps = math.clamp(rawFps, 15, 240)

        fps = math.floor(rawFps + 0.5)

        frameCount = 0
        timeElapsed = 0
    end
end)

--========================
-- LOOP UPDATE
--========================
task.spawn(function()
    while true do
        pcall(function()

            -- TIME
            TimeLabel:SetDesc(formatTime(tick() - startTime))

            -- PLAYERS
            PlayerLabel:SetDesc(#Players:GetPlayers())

            -- PING (กันพัง)
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            PingLabel:SetDesc(ping .. " ms")

            -- FPS
            FPSLabel:SetDesc(fps)

        end)

        task.wait(0.5)
    end
end)

-- Credit
Tabs.Credit:AddParagraph({
    Title = "Credit",
    Content = "Made by x2sxqz"
})

Tabs.Credit:AddParagraph({
    Title = "UI Library",
    Content = "Fluent X Reaper"
})


local canClick = true

Tabs.Credit:AddButton({
    Title = "Discord",
    Description = "https://discord.gg/RPVTDFZyhw",
    Callback = function()

        if not canClick then return end
        canClick = false

        local link = "https://discord.gg/RPVTDFZyhw"
        setclipboard(link)

        local gui = Instance.new("ScreenGui")
        gui.Name = "CustomNotify"
        gui.ResetOnSpawn = false
        gui.Parent = game.CoreGui

        local frame = Instance.new("Frame")
        frame.Parent = gui
        frame.Size = UDim2.new(0, 280, 0, 70)
        frame.Position = UDim2.new(1, 300, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(70, 10, 10)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0

        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 60, 60)

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 12)

        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 12, 0, 15)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://131279093559313"

        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, -70, 1, 0)
        text.Position = UDim2.new(0, 60, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = "Copied Success\n" .. link
        text.TextColor3 = Color3.fromRGB(255, 200, 200)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Font = Enum.Font.SourceSansSemibold
        text.TextSize = 14

        -- 👉 เข้า
        local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -300, 0, 20)
        })
        tweenIn:Play()

        task.wait(2.5)

        -- 👉 ออก (สำคัญ: ต้องรอให้ tween จบก่อน destroy)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 300, 0, 20),
            BackgroundTransparency = 1
        })

        tweenOut:Play()
        tweenOut.Completed:Wait() -- 🔥 จุดสำคัญมาก

        gui:Destroy()

        task.wait(0.5)
        canClick = true
    end
})

-- Teleport
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local selectedPlayer
local teleportEnabled = false

local function getList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- =========================
-- DROPDOWN (ต้องมี ID + ห้ามมั่ว)
-- =========================
local Dropdown = Tabs.Teleport:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = getList(),
    Multi = false
})

-- 🔥 IMPORTANT: delay bind กัน Fluent บัค
task.defer(function()
    Dropdown:OnChanged(function(value)
		if value then
        selectedPlayer = Players:FindFirstChild(value)
		end
	end)
end)

-- =========================
-- REFRESH (แบบไม่พัง)
-- =========================
Tabs.Teleport:AddButton({
    Title = "Refresh Players",
    Callback = function()
        task.wait(0.1)

        if Dropdown and Dropdown.SetValues then
            pcall(function()
                Dropdown:SetValues(getList())
            end)
        end
    end
})

-- =========================
-- TELEPORT
-- =========================
Tabs.Teleport:AddToggle("tp", {
    Title = "Teleport",
    Default = false
}):OnChanged(function(state)
    teleportEnabled = state

    if state then
        task.spawn(function()
            while teleportEnabled do
                if selectedPlayer and selectedPlayer.Character then
                    local char = Players.LocalPlayer.Character
                    local target = selectedPlayer.Character

                    if char and target then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local tRoot = target:FindFirstChild("HumanoidRootPart")

                        if root and tRoot then
                            TweenService:Create(
                                root,
                                TweenInfo.new(0.4),
                                {CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)}
                            ):Play()
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

local spectating = false
local originalCameraSubject = nil

-- =========================
-- SPECTATE TOGGLE
-- =========================
Tabs.Teleport:AddToggle("spec", {
    Title = "Spectate Player",
    Default = false
}):OnChanged(function(state)
    spectating = state

    if state then
        if selectedPlayer and selectedPlayer.Character then
            local humanoid = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                -- เก็บของเดิมไว้
                originalCameraSubject = Camera.CameraSubject

                -- เปลี่ยนไปดูเป้า
                Camera.CameraSubject = humanoid
            end
        end
    else
        -- กลับมาที่ตัวเรา
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraSubject = humanoid
            end
        end
    end
end)

-- =========================
-- UPDATE TARGET (เวลาเปลี่ยน dropdown)
-- =========================
task.defer(function()
    Dropdown:OnChanged(function(value)
		if value then
        selectedPlayer = Players:FindFirstChild(value)

        -- ถ้ากำลัง spectate อยู่ → เปลี่ยนทันที
        if spectating and selectedPlayer and selectedPlayer.Character then
            local humanoid = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraSubject = humanoid
				end
			end
        end
    end)
end)

-- Server 🌟
-- [[ AUTO REJOIN LOGIC ]] --
local AutoRejoinEnabled = false
task.spawn(function()
    GuiService.ErrorMessageChanged:Connect(function()
        if AutoRejoinEnabled then
            local message = GuiService:GetErrorMessage()
            if message ~= "" then
                warn("Reaper Hub: Detected kick/disconnect. Rejoining in 5 seconds...")
                task.wait(5)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end
    end)
end)

Tabs.Server:AddToggle("AutoRejoinToggle", {
    Title = "Auto Rejoin",
    Description = "Auto Rejoin When kicked",
    Default = true,
    Callback = function(Value)
        AutoRejoinEnabled = Value
    end
})



-- Join low server
local PlaceId = game.PlaceId
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local response = game:HttpGet(url)
    return HttpService:JSONDecode(response)
end

local function findLowServer()
    local cursor = nil

    for i = 1, 5 do -- ลองดึงหลายหน้า
        local data = getServers(cursor)

        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                return server.id
            end
        end

        cursor = data.nextPageCursor
        if not cursor then break end
    end
end

-- 🔘 ปุ่ม
Tabs.Server:AddButton({
    Title = "Low Server",
    Description = "Server low players",
    Callback = function()
        local serverId = findLowServer()

        if serverId then
            TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
        end
    end
})

-- Server ⚔️ Rejoim
Tabs.Server:AddButton({
    Title = "Rejoin",
    Description = "กลับเข้าเซิร์ฟเดิม",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game.Players.LocalPlayer
        )
    end
})

Tabs.Server:AddButton({
    Title = "Server Hop",
    Description = "ไปเซิร์ฟใหม่",
    Callback = function()
        game:GetService("TeleportService"):Teleport(
            game.PlaceId,
            game.Players.LocalPlayer
        )
    end
})

-- JobID
local currentJobIdInput = ""

-- 📋 Copy JobId
Tabs.Server:AddButton({
    Title = "Copy Job ID",
    Description = "Copy current server Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
        end
    end
})

-- ⌨️ Input JobId
Tabs.Server:AddInput("JobIdInput", {
    Title = "Job ID",
    Default = "",
    Placeholder = "Paste Job ID here...",
    Callback = function(text)
        currentJobIdInput = text
    end
})

-- 🚀 Join JobId
Tabs.Server:AddButton({
    Title = "Join Server",
    Description = "Join server using Job ID",
    Callback = function()
        if currentJobIdInput == "" then return end

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            currentJobIdInput,
            LocalPlayer
        )
    end
})

-- main tab
-- === 1. ปรับปรุง Settings เพิ่ม IgnoredPlayers ===
local AimbotSettings = {
    Enabled = false,
    WallCheck = true,
    TargetPart = "Head",
    Mode = "Random", 
    SelectedPlayerName = nil,
    IgnoredPlayers = {},
    Smoothness = 1 -- ค่าเริ่มต้น (1 = ล็อคตาย)
}


local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function getActualPart(character, choice)
    if not character then return nil end
    if choice == "Head" then
        return character:FindFirstChild("Head")
    elseif choice == "Body" then
        return character:FindFirstChild("HumanoidRootPart")
    elseif choice == "Leg" then
        return character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg")
    end
    return nil
end

local function IsVisible(targetPart)
    if not AimbotSettings.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, targetPart.Parent}
    
    local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return rayResult == nil
end

-- === 2. ปรับปรุงฟังก์ชันหาเป้าหมายให้รองรับ Ignore List ===
local function GetClosestTargetToMouse()
    local target = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        -- ตรวจสอบว่าอยู่ในรายชื่อที่ Ignore หรือไม่ (เฉพาะโหมด Random)
        if AimbotSettings.Mode == "Random" and table.find(AimbotSettings.IgnoredPlayers, player.Name) then
            continue 
        end

        if player ~= LocalPlayer and player.Character then
            local part = getActualPart(player.Character, AimbotSettings.TargetPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if part and humanoid and humanoid.Health > 0 and IsVisible(part) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

local CurrentTarget = nil

-- === 3. ระบบหลัก: BindToRenderStep ===
RunService:BindToRenderStep("AimbotLock", Enum.RenderPriority.Camera.Value + 1, function()
    if AimbotSettings.Enabled then
        
        if AimbotSettings.Mode == "Random" then
            -- เช็คเงื่อนไข: ถ้าเป้าหมายเดิมตาย/หลุด/หรือเพิ่งถูกเพิ่มเข้า Ignore List ให้หาใหม่
            if not CurrentTarget or not CurrentTarget.Character or 
               not getActualPart(CurrentTarget.Character, AimbotSettings.TargetPart) or 
               CurrentTarget.Character.Humanoid.Health <= 0 or 
               (AimbotSettings.WallCheck and not IsVisible(getActualPart(CurrentTarget.Character, AimbotSettings.TargetPart))) or
               table.find(AimbotSettings.IgnoredPlayers, CurrentTarget.Name) then
                
                CurrentTarget = GetClosestTargetToMouse()
            end
        elseif AimbotSettings.Mode == "Select" then
            -- โหมด Select: ล็อคเฉพาะคนที่เราเลือก (ไม่สน Ignore List ตามคำขอ)
            local targetPlayer = Players:FindFirstChild(AimbotSettings.SelectedPlayerName or "")
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
                CurrentTarget = targetPlayer
            else
                CurrentTarget = nil
            end
        end

        -- การล็อคกล้อง
        if CurrentTarget and CurrentTarget.Character then
            local targetPart = getActualPart(CurrentTarget.Character, AimbotSettings.TargetPart)
            if targetPart then
                -- ตรวจสอบว่าเป้าหมายติดกำแพงหรือไม่ (ถ้าเปิด Wall Check ไว้)
if AimbotSettings.WallCheck and not IsVisible(targetPart) then
    CurrentTarget = nil -- ถ้าติดกำแพงให้ยกเลิกการล็อค
else
    -- ระบบดูด (Smoothing)
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
end
            end
        end
    else
        CurrentTarget = nil
    end
end)

-- === 4. UI Section (Fluent/Library Context) ===

-- เลือกโหมด
local ModeDropdown = Tabs.Main:AddDropdown("ModeDropdown", {
    Title = "Aimbot Mode",
    Values = {"Random", "Select"},
    Multi = false,
    Default = 1,
})
ModeDropdown:OnChanged(function(Value)
    AimbotSettings.Mode = Value
    CurrentTarget = nil 
end)

-- Dropdown สำหรับเลือกเป้าหมายเดี่ยว (Select Mode)
local PlayerDropdown = Tabs.Main:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
})
PlayerDropdown:OnChanged(function(Value)
    AimbotSettings.SelectedPlayerName = Value
end)

-- [เพิ่มใหม่] Multi-Select Dropdown สำหรับ Ignore List (Random Mode)
local IgnoreDropdown = Tabs.Main:AddDropdown("IgnoreDropdown", {
    Title = "Ignored Players",
    Description = "",
    Values = getPlayerNames(),
    Multi = true, -- เปิดใช้งานเลือกได้หลายคน
    Default = {},
})
IgnoreDropdown:OnChanged(function(Value)
    -- ใน Multi-dropdown 'Value' จะเป็น Table ของชื่อที่ถูกเลือก
    AimbotSettings.IgnoredPlayers = {}
    for name, state in pairs(Value) do
        if state then
            table.insert(AimbotSettings.IgnoredPlayers, name)
        end
    end
end)

local PartDropdown = Tabs.Main:AddDropdown("PartDropdown", {
    Title = "Target Part",
    Values = {"Head", "Body", "Leg"},
    Multi = false,
    Default = 1,
})
PartDropdown:OnChanged(function(Value)
    AimbotSettings.TargetPart = Value
end)

local SmoothDropdown = Tabs.Main:AddDropdown("SmoothDropdown", {
    Title = "Aimbot Level",
    Values = {"Low", "Medium", "High"},
    Multi = false,
    Default = "High",
})

SmoothDropdown:OnChanged(function(Value)
    if Value == "Low" then
        AimbotSettings.Smoothness = 0.05 -- หันจอหนีง่ายมาก
    elseif Value == "Medium" then
        AimbotSettings.Smoothness = 0.15 -- หนืดพอสมควร
    elseif Value == "High" then
        AimbotSettings.Smoothness = 1.0  -- ล็อคติดเป้าทันที
    end
end)

-- ปุ่ม Refresh รายชื่อ (อัปเดตทั้งคู่)
Tabs.Main:AddButton({
    Title = "Refresh List",
    Description = "",
    Callback = function()
        local names = getPlayerNames()
        PlayerDropdown:SetValues(names)
        IgnoreDropdown:SetValues(names)
    end
})

-- Aimbot
local AimbotToggle = Tabs.Main:AddToggle("AimbotToggle", {
    Title = "Enable Aimbot",
    Default = false
})
AimbotToggle:OnChanged(function(Value)
    AimbotSettings.Enabled = Value
end)



--========================================================
-- 🔥 [NEW] AUTO FIRE - REAPER HUB PC & MOBILE
--========================================================
local AF_Enabled = false
local AF_Platform = "Mobile" -- Default
local AF_Saved = false
local AF_Pos = nil
local AF_LastShot = 0
local AF_Mode = "Normal"
local AF_Delay = 0.3   
local AF_HoldTime = 0.05 
local IsShooting = false 

--// [ระบบแจ้งเตือน REAPER STYLE - คงความสวยงามตามเดิม]
local function SpawnNotify(msg)
    task.spawn(function()
        if CoreGui:FindFirstChild("ReaperNotify") then CoreGui.ReaperNotify:Destroy() end
        local gui = Instance.new("ScreenGui", CoreGui)
        gui.Name = "ReaperNotify"
        gui.DisplayOrder = 999999
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 280, 0, 70)
        frame.Position = UDim2.new(1, 300, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(70, 10, 10)
        frame.BackgroundTransparency = 0.25
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 60, 60)
        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 12, 0, 15)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://131279093559313" -- ไอคอนเดิมของคุณ
        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, -70, 1, 0)
        text.Position = UDim2.new(0, 60, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = "<b>REAPER SYSTEM</b>\n" .. msg
        text.TextColor3 = Color3.fromRGB(255, 200, 200)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Font = Enum.Font.SourceSansSemibold
        text.TextSize = 14
        text.RichText = true
        
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 0, 20)}):Play()
        task.wait(2.5)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 300, 0, 20), BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        gui:Destroy()
    end)
end

--// [ระบบตรวจจับเป้าหมาย]
local function GetHumanoid(part)
    local char = part.Parent
    while char and char ~= workspace do
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then return hum, char end
        char = char.Parent
    end
    return nil
end

local function CheckTarget()
    local viewportCenter = Camera.ViewportSize / 2
    local unitRay = Camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if result and result.Instance then
        local hum, char = GetHumanoid(result.Instance)
        if hum and hum.Health > 0 and char ~= LP.Character then return true end
    end
    return false
end

--// [ระบบส่ง Input แยกตาม Platform]
RunService.RenderStepped:Connect(function()
    if not AF_Enabled then return end
    if AF_Platform == "Mobile" and not AF_Saved then return end

    if CheckTarget() and not IsShooting then
        local now = tick()
        if now - AF_LastShot >= AF_Delay then
            AF_LastShot = now
            IsShooting = true 
            
            task.spawn(function()
                if AF_Platform == "Mobile" then
                    -- โหมดมือถือ: ใช้พิกัดปุ่ม
                    VIM:SendTouchEvent(99, 0, AF_Pos.X, AF_Pos.Y, game)
                    task.wait(AF_HoldTime)
                    VIM:SendTouchEvent(99, 2, AF_Pos.X, AF_Pos.Y, game)
                else
                    -- โหมด PC: ใช้คลิกเมาส์ซ้าย
    -- โหมด PC: ใช้ VIM แทนเพื่อแก้ปัญหากล้องสะบัดขึ้นฟ้า
    local viewportSize = Camera.ViewportSize
    local centerX, centerY = viewportSize.X / 2, viewportSize.Y / 2
    
    -- ส่งสัญญาณคลิกซ้ายไปที่กลางจอโดยตรง
    VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    task.wait(AF_HoldTime)
    VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
end


                IsShooting = false
            end)
        end
    end
end)

--// [UI สำหรับตั้งปุ่ม Mobile]
local AnchorGui = Instance.new("ScreenGui", CoreGui)
AnchorGui.Name = "ReaperAnchor"
AnchorGui.IgnoreGuiInset = true
AnchorGui.Enabled = false
local AnchorFrame = Instance.new("Frame", AnchorGui)
AnchorFrame.Size = UDim2.fromOffset(60, 60)
AnchorFrame.Position = UDim2.new(0.5, -30, 0.5, -30)
AnchorFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
AnchorFrame.BackgroundTransparency = 0.5
AnchorFrame.Active = true 
AnchorFrame.Draggable = true 
Instance.new("UICorner", AnchorFrame).CornerRadius = UDim.new(1, 0)
local SaveBtn = Instance.new("TextButton", AnchorFrame)
SaveBtn.Size = UDim2.fromOffset(80, 35)
SaveBtn.Position = UDim2.new(0.5, -40, 1, 10)
SaveBtn.Text = "SAVE"
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SaveBtn)

SaveBtn.MouseButton1Click:Connect(function()
    local inset = GuiService:GetGuiInset()
    local screenPos = AnchorFrame.AbsolutePosition
    local size = AnchorFrame.AbsoluteSize
    AF_Pos = Vector2.new(screenPos.X + (size.X/2), screenPos.Y + (size.Y/2) + inset.Y)
    AF_Saved = true
    AnchorGui.Enabled = false 
    SpawnNotify("บันทึกพิกัด Mobile สำเร็จ!")
end)

--// [UI Integration]
Tabs.Main:AddDropdown("AF_Platform", {
    Title = "Platform",
    Values = {"Mobile", "PC"},
    Default = "Mobile",
    Callback = function(val)
        AF_Platform = val
        AF_Saved = false
        if AnchorGui then AnchorGui.Enabled = (val == "Mobile" and AF_Enabled) end
        SpawnNotify("Mode : " .. val)
    end
})

Tabs.Main:AddToggle("AutoFireV3", {
    Title = "Auto Fire",
    Default = false,
    Callback = function(state)
        AF_Enabled = state
        if state then
            if AF_Platform == "Mobile" then
                AF_Saved = false
                AnchorGui.Enabled = true
                SpawnNotify("Press Save to working")
            else
                SpawnNotify("PC Mode")
            end
        else
            AnchorGui.Enabled = false
            IsShooting = false
        end
    end
})

Tabs.Main:AddDropdown("FireMode", {
    Title = "Fire Mode",
    Values = {"Normal", "Spam", "Rapid Click"},
    Default = "Normal",
    Callback = function(val)
        AF_Mode = val
        if val == "Normal" then AF_Delay = 0.3; AF_HoldTime = 0.05
        elseif val == "Spam" then AF_Delay = 0.05; AF_HoldTime = 0.02
        elseif val == "Rapid Click" then AF_Delay = 0; AF_HoldTime = 0 end
        SpawnNotify("Fire Mode: " .. val)
    end
})


-- wall Check
local WallCheckToggle = Tabs.Main:AddToggle("WallCheckToggle", {
    Title = "Wall Check",
    Default = true
})
WallCheckToggle:OnChanged(function(Value)
    AimbotSettings.WallCheck = Value
end)


-- Full Bright
--=========================
-- 🔥 FULL BRIGHT SYSTEM (SLIDER)
--=========================
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd
}

local CurrentBrightness = 2 -- ค่าเริ่มต้นในสคริปต์ (ไม่กระทบเกมจนกว่าจะเปิด)

-- 1. Slider สำหรับเลือกค่า (ปรับรอไว้ก่อนได้)
Tabs.Misc:AddSlider("BrightnessSlider", {
    Title = "Brightness Level",
    Description = "",
    Default = 2,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        CurrentBrightness = Value
        -- ถ้าเปิด Toggle อยู่ ให้เปลี่ยนค่าทันทีที่เลื่อน Slider
        if _G.FullBrightEnabled then
            Lighting.Brightness = CurrentBrightness
        end
    end
})

-- 2. Toggle สำหรับสั่งเปิด/ปิด (ตัวควบคุมหลัก)
Tabs.Misc:AddToggle("FullBrightToggle", {
    Title = "Enable Full Bright",
    Default = false,
    Callback = function(Value)
        _G.FullBrightEnabled = Value -- เก็บสถานะไว้เช็คใน Slider
        
        if Value then
            -- เมื่อเปิด: สั่งเปลี่ยนค่า Lighting ทั้งหมด
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = CurrentBrightness
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        else
            -- เมื่อปิด: คืนค่าเดิมของเกมทันที
            Lighting.Ambient = DefaultLighting.Ambient
            Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.FogEnd = DefaultLighting.FogEnd
        end
    end
})



-- Memmory clear
--=========================
-- 🔥 MEMORY CLEANER LOGIC
--=========================
local function StartCleanLoop()
    local threshold = 200 * 1024 -- 200MB
    task.spawn(function()
        while State.MemClean do
            if gcinfo() > threshold then
                collectgarbage("collect")
            end
            task.wait(60) -- เช็คทุก 60 วินาที
        end
    end)
end

-- Memory Cleanup Toggle (No Notification)
Tabs.Misc:AddToggle("MemCleanup", {
    Title = "Memory Clean",
    Default = false,
    Callback = function(Value)
        State.MemClean = Value
        if Value then
            StartCleanLoop()
        end
    end
})


-- Safe Mode

local SafeModeActive = false
local SafeModeType = "Tween"
local OriginalPos = nil
local SafeAltitude = 5000 

local function HandleSafeMode(state)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return end

    if state then
        -- [ ขาขึ้น ]
        OriginalPos = hrp.CFrame 
        local targetCFrame = hrp.CFrame + Vector3.new(0, SafeAltitude, 0)

        if SafeModeType == "Instant" then
            hrp.CFrame = targetCFrame
            task.wait(0.1)
            if SafeModeActive then hrp.Anchored = true end -- เช็คซ้ำว่ายังเปิดอยู่ไหม
        else
            hrp.Anchored = false
            local tweenIn = game:GetService("TweenService"):Create(
                hrp, 
                TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {CFrame = targetCFrame}
            )
            tweenIn:Play()
            tweenIn.Completed:Connect(function()
                if SafeModeActive then hrp.Anchored = true end
            end)
        end
    else
        -- [ ขาลง ]
        hrp.Anchored = false
        if OriginalPos then
            if SafeModeType == "Instant" then
                hrp.CFrame = OriginalPos
            else
                game:GetService("TweenService"):Create(
                    hrp, 
                    TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {CFrame = OriginalPos}
                ):Play()
            end
        end
    end
end

-- --- UI Section ---
-- 1. เลือกโหมด (Dropdown) - อยู่ด้านบนตามสั่ง
Tabs.Misc:AddDropdown("SafeModeType", {
    Title = "Safe Mode Method",
    Description = "",
    Values = {"Tween", "Instant"},
    Default = "Tween",
    Callback = function(Value)
        SafeModeType = Value
    end
})

-- 2. ปุ่มเปิดปิด (Toggle) - อยู่ด้านล่าง
Tabs.Misc:AddToggle("SafeModeToggle", {
    Title = "Safe Mode",
    Description = "",
    Default = false,
    Callback = function(Value)
        SafeModeActive = Value
        HandleSafeMode(Value)
    end
})


-- Max Zoom
Tabs.Misc:AddToggle("MaxZoom", {
    Title = "Max Zoom",
    Default = false,

    Callback = function(v)

        if v then
            LocalPlayer.CameraMaxZoomDistance = 999999
        else
            LocalPlayer.CameraMaxZoomDistance = DefaultZoom
        end
    end
})

-- Anti Afk
-- ลบ UI เก่า
if game.CoreGui:FindFirstChild("REAPER_AFK_UI") then
    game.CoreGui.REAPER_AFK_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "REAPER_AFK_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main Frame (ปรับให้ยาวขึ้น)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 150) -- เพิ่มความกว้างเป็น 300
MainFrame.Position = UDim2.new(0.5, -150, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- UICorner (ขอบมน)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- UIStroke (ขอบสีแดง)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0) -- สีแดง
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0.5, -30, 0, 10)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://131279093559313"
Logo.Parent = MainFrame

-- REAPER HUB | ANTI AFK Text
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 75)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "REAPER HUB | ANTI AFK"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Timer Label (เลขล้วน)
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Name = "TimerLabel"
TimerLabel.Size = UDim2.new(1, 0, 0, 30)
TimerLabel.Position = UDim2.new(0, 0, 0, 105)
TimerLabel.BackgroundTransparency = 1
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.Text = "00:00"
TimerLabel.Font = Enum.Font.RobotoMono
TimerLabel.TextSize = 26
TimerLabel.Parent = MainFrame

local function formatTime(sec)
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

local startTime = 0

Tabs.Misc:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(v)
        getgenv().AntiAFK = v
        if v then
            startTime = os.time()
            MainFrame.Visible = true

            task.spawn(function()
                while getgenv().AntiAFK do
                    local elapsed = os.time() - startTime
                    TimerLabel.Text = formatTime(elapsed)
                    task.wait(1)
                end
            end)

            task.spawn(function()
                while getgenv().AntiAFK do
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1080)
                end
            end)
        else
            MainFrame.Visible = false
        end
    end
})


-- FPS BOOST
local saved = {}
local connection = nil

local function optimizeObject(v)
    -- ตรวจสอบว่าวัตถุอยู่ใน Workspace เท่านั้น (ป้องกัน UI)
    if not v:IsDescendantOf(workspace) then return end

    if v:IsA("Texture") or v:IsA("Decal") then
        if not saved[v] then saved[v] = v.Transparency end
        v.Transparency = 1
    elseif v:IsA("BasePart") then
        if not saved[v] then
            -- เก็บค่าเดิมในรูปแบบ Table เพื่อคืนค่าได้ครบถ้วน
            saved[v] = {
                Material = v.Material,
                Reflectance = v.Reflectance,
                CastShadow = v.CastShadow
            }
        end
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
    end
end

local function applyOptimize(state)
    if state then
        -- 1. จัดการเฉพาะใน Workspace
        for _, v in ipairs(workspace:GetDescendants()) do
            optimizeObject(v)
        end

        -- 2. ดักจับวัตถุใหม่ที่โหลดเข้า Workspace เท่านั้น
        connection = workspace.DescendantAdded:Connect(function(v)
            task.defer(function() 
                if v and v.Parent then optimizeObject(v) end 
            end)
        end)
        
        lighting.GlobalShadows = false
    else
        -- ปิดการดักจับ
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- 3. คืนค่าเดิม (Restoration Logic)
        for obj, data in pairs(saved) do
            if obj and obj.Parent then
                if typeof(data) == "table" then
                    obj.Material = data.Material
                    obj.Reflectance = data.Reflectance
                    obj.CastShadow = data.CastShadow
                else
                    obj.Transparency = data
                end
            end
        end
        
        -- เคลียร์ Memory
        table.clear(saved)
        lighting.GlobalShadows = true
    end
end

-- FPS Toggle
Tabs.Misc:AddToggle("FPSBoost", {
    Title = "FPS Boost",
    Default = false
}):OnChanged(function(v)
    applyOptimize(v)
end)



--=========================
-- 🔥 FPS CAP SYSTEM (FIXED)
--=========================

local SelectedFPS = 60

-- Slider
Tabs.Misc:AddSlider("FPSCapSlider", {
    Title = "FPS Cap",
    Description = "",
    Default = 60,
    Min = 30,
    Max = 240,
    Rounding = 0,

    Callback = function(Value)
        SelectedFPS = tonumber(Value) or 60
    end
})

-- Button
Tabs.Misc:AddButton({
    Title = "Set FPS",
    Description = "",

    Callback = function()
        local Success, Error = pcall(function()

            if not setfpscap then
                warn("setfpscap is not supported by this executor.")
                return
            end

            local FinalFPS = (SelectedFPS >= 240) and 999 or SelectedFPS

            setfpscap(FinalFPS)

            if typeof(StartFPSManager) == "function" then
                StartFPSManager()
            end

        end)

        if not Success then
            warn("[FPS Cap Error]:", Error)
        end
    end
})



-- Console
--// STATE
local consoleEnabled = false
local MAX_LOGS = 1000
local logItems = {}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ReaperConsole"
gui.Parent = game.CoreGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 270)
main.Position = UDim2.new(0.5, -210, 0.5, -135)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.Visible = false
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke", main)
stroke.Transparency = 0.85

--// HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,32)
header.BackgroundColor3 = Color3.fromRGB(28,28,34)

Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Reaper Console"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1,1,1)

--// SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0,0,0,34)
scroll.Size = UDim2.new(1,0,1,-70)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local padding = Instance.new("UIPadding", scroll)
padding.PaddingLeft = UDim.new(0,6)
padding.PaddingTop = UDim.new(0,6)

--// BOTTOM
local bottom = Instance.new("Frame", main)
bottom.Size = UDim2.new(1,0,0,32)
bottom.Position = UDim2.new(0,0,1,-32)
bottom.BackgroundColor3 = Color3.fromRGB(24,24,30)

--// CLEAR BUTTON
local clear = Instance.new("TextButton", bottom)
clear.Size = UDim2.new(0,70,0,24)
clear.Position = UDim2.new(1,-80,0.5,-12)
clear.Text = "Clear"
clear.Font = Enum.Font.Gotham
clear.TextSize = 13
clear.BackgroundColor3 = Color3.fromRGB(40,40,50)
clear.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", clear)

--// CLEAR FUNCTION
clear.MouseButton1Click:Connect(function()

	for _,v in ipairs(logItems) do
		if v then
			v:Destroy()
		end
	end

	table.clear(logItems)

	scroll.CanvasPosition = Vector2.new(0,0)
end)

--// CREATE LOG UI
local function createLog(text, msgType)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1,-6,0,0)
	container.AutomaticSize = Enum.AutomaticSize.Y

	local prefix = "[INFO]"
	local color = Color3.fromRGB(220,220,220)
	local bg = Color3.fromRGB(30,30,35)

	if msgType == Enum.MessageType.MessageError then

		prefix = "[ERROR]"
		color = Color3.fromRGB(255,80,80)
		bg = Color3.fromRGB(55,25,25)

	elseif msgType == Enum.MessageType.MessageWarning then

		prefix = "[WARN]"
		color = Color3.fromRGB(255,200,0)
		bg = Color3.fromRGB(55,50,20)
	end

	container.BackgroundColor3 = bg

	Instance.new("UICorner", container).CornerRadius = UDim.new(0,6)

	local pad = Instance.new("UIPadding", container)
	pad.PaddingLeft = UDim.new(0,6)
	pad.PaddingRight = UDim.new(0,6)
	pad.PaddingTop = UDim.new(0,4)
	pad.PaddingBottom = UDim.new(0,4)

	local time = os.date("%H:%M:%S")

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.new(1,0,0,0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Code
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.RichText = false

	label.Text = "["..time.."] "..prefix.."  "..tostring(text)
	label.TextColor3 = color

	-- hover effect
	container.MouseEnter:Connect(function()
		container.BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.05)
	end)

	container.MouseLeave:Connect(function()
		container.BackgroundColor3 = bg
	end)

	label.Parent = container

	return container
end

--// ADD LOG
local function addLog(text, msgType)

	local item = createLog(text, msgType)
	item.Parent = scroll

	table.insert(logItems, item)

	-- LIMIT
	if #logItems > MAX_LOGS then

		local old = table.remove(logItems, 1)

		if old then
			old:Destroy()
		end
	end

	-- AUTO SCROLL
	task.defer(function()

		scroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, layout.AbsoluteContentSize.Y)
		)
	end)
end

--// LOAD OLD LOGS
for _,log in ipairs(LogService:GetLogHistory()) do
	addLog(log.message, log.messageType)
end

--// LISTEN NEW LOGS
LogService.MessageOut:Connect(function(message, messageType)
	addLog(message, messageType)
end)

--// TOGGLE
Tabs.Misc:AddToggle("Console", {
	Title = "Console",
	Default = false,

	Callback = function(v)
		consoleEnabled = v
		main.Visible = v
	end
})

--=========================
-- ⚙ SETTINGS TAB
--=========================

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("ReaperHub")
SaveManager:SetFolder("ReaperHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig() -- 🔥 ตัวนี้แหละ

Window:SelectTab(1)
-- Lib Toggle
--=========================
-- TOGGLE BUTTON
--=========================
if game.CoreGui:FindFirstChild("ToggleUI") then
    game.CoreGui.ToggleUI:Destroy()
end


--=========================
-- GUI
--=========================
local gui = Instance.new("ScreenGui")
gui.Name = "ToggleUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game.CoreGui

--=========================
-- BORDER
--=========================
local border = Instance.new("Frame")
border.Parent = gui
border.Size = UDim2.new(0,0,0,0)
border.BackgroundColor3 = Color3.fromRGB(0,0,0)
border.ZIndex = 1
border.AnchorPoint = Vector2.new(0,0)

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0,14)
borderCorner.Parent = border

--=========================
-- BUTTON
--=========================
local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0,60,0,60)
button.Position = UDim2.new(0,60,0.2,0)
button.AnchorPoint = Vector2.new(0,0)

button.BackgroundTransparency = 1
button.ZIndex = 999999
button.AutoButtonColor = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

--=========================
-- IMAGE
--=========================
local imgOn = "rbxassetid://86279908104891"
local imgOff = "rbxassetid://86279908104891"

button.Image = imgOn
button.ScaleType = Enum.ScaleType.Fit

--=========================
-- AUTO ALIGN
--=========================
local function UpdateBorder()

    local offset = (border.Size.X.Offset - button.Size.X.Offset) / 2

    border.Position = UDim2.new(
        button.Position.X.Scale,
        button.Position.X.Offset - offset,
        button.Position.Y.Scale,
        button.Position.Y.Offset - offset
    )
end

UpdateBorder()

--=========================
-- DRAG SYSTEM
--=========================
local dragging = false
local dragStart, startPos

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if dragging then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        UpdateBorder()
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

--=========================
-- TOGGLE
--=========================
local isOpen = true

button.MouseButton1Click:Connect(function()

    isOpen = not isOpen

    if Window then
        Window:Minimize(not isOpen)
    end

    button.Image = isOpen and imgOff or imgOn

end)




-- Load Success 
task.wait(2)
print("Reaper Hub Loaded")
