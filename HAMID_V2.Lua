-- SAMEER ULTIMATE – FULL GUI + CHAT SYNC (NOCLIP/NOSIT/BANG)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- CONFIG
local target = "none"
local master = ""
local speed = 0.45
local active = false
local banging = false
local noclipActive = false
local nositActive = false

-- ROTATING FILLER PATTERNS
local fillerPatterns = { "@", "#-", "@#", "_-", "~-", "=: " }
local patternIndex = 1

-- TOP 20 PREFIXES
local prefixes = {
    "tmx meh king", "tmx meh beast", "tmx meh hunter", "tmx meh storm",
    "tmx meh shadow", "tmx meh venom", "tmx meh rocket", "tmx meh flash",
    "tmx meh thunder", "tmx meh phantom", "tmx meh ghost", "tmx meh alpha999",
    "tmx meh frost", "tmx meh steel", "tmx meh HAMID", "tmx meh wolf",
    "HAMIDxALPHA", "HAMID op", "king Alpha", "HAMID on top"
}

-- SEND MESSAGE
local function send(msg)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(msg) end
        else
            local rs = game:GetService("ReplicatedStorage")
            local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
            if ev then
                local say = ev:FindFirstChild("SayMessageRequest")
                if say then say:FireServer(msg, "All") end
            end
        end
    end)
end

-- NOCLIP ENGINE
local function updateNoclip()
    local char = LP.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipActive
            end
        end
    end
end

RS.RenderStepped:Connect(function()
    if noclipActive then updateNoclip() end
end)

-- NOSIT ENGINE
local function nositCheck()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if hum.Sit and nositActive then hum.Sit = false end
        if hum.SeatPart and nositActive then
            hum.Sit = false
            hum.SeatPart = nil
        end
    end
end

RS.Stepped:Connect(function()
    if nositActive then nositCheck() end
end)

-- BANG ENGINE
RS.Heartbeat:Connect(function()
    if banging and target ~= "none" then
        local tP = Players:FindFirstChild(target)
        if tP and tP.Character and tP.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = tP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.1)
                task.wait()
                hrp.CFrame = tP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.1)
            end
        end
    end
end)

-- ROTATING FILLER
local function buildFiller(endPart)
    local pattern = fillerPatterns[patternIndex]
    patternIndex = patternIndex + 1
    if patternIndex > #fillerPatterns then patternIndex = 1 end
    local targetLen = 140 - #endPart
    if targetLen < 10 then targetLen = 10 end
    local repeatCount = math.floor(targetLen / #pattern) + 1
    local filler = string.rep(pattern, repeatCount)
    filler = filler:sub(1, targetLen)
    return filler
end

-- SPAM ENGINE
local function startSpam()
    if active then return end
    active = true
    task.spawn(function()
        local msgCount = 0
        while active do
            for _, p in pairs(prefixes) do
                if not active then break end
                local endP = (target == "none") and " " .. p or " " .. target .. " " .. p
                local filler = buildFiller(endP)
                local msg = filler .. endP
                send(string.lower(msg))
                msgCount = msgCount + 1
                local variance = (math.random(-3, 3) / 100)
                local waitTime = math.max(0.25, speed + variance)
                task.wait(waitTime)
                if msgCount % 10 == 0 then task.wait(1.1) end
            end
            task.wait(0.1)
        end
    end)
end

local function stopSpam()
    active = false
    banging = false
    send("🦁 RUK GAYA.")
end

-- CHAT COMMAND HANDLER (SYNCED WITH GUI)
local function runCmd(msg, speaker)
    local sn = speaker.Name:lower()
    local sd = speaker.DisplayName:lower()
    if speaker ~= LP and sn ~= master and sd ~= master then return end
    local parts = {}
    for w in msg:gmatch("%S+") do table.insert(parts, w) end
    if #parts == 0 then return end
    local cmd = parts[1]:lower()
    
    if cmd == "!rejoin" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    elseif cmd == "!speed" and parts[2] then
        local ns = tonumber(parts[2])
        if ns and ns > 0 then speed = ns send("[⚡ speed set to "..speed.."s ⚡]") end
    elseif cmd == "!target" and parts[2] then
        target = parts[2]:lower()
        send("🦁 target: " .. target)
    elseif cmd == "!setmaster" and parts[2] then
        master = parts[2]:lower()
        send("🦁 master set: " .. master)
    elseif cmd == "!bang" then
        banging = not banging
        send("🦁 bang mode: " .. (banging and "on" or "off"))
        if updateBangButton then updateBangButton() end   -- sync GUI
    elseif cmd == "!noclip" then
        noclipActive = not noclipActive
        updateNoclip()
        send("🦁 noclip: " .. (noclipActive and "on" or "off"))
        if updateNoclipButton then updateNoclipButton() end
    elseif cmd == "!nosit" then
        nositActive = not nositActive
        send("🦁 anti-sit: " .. (nositActive and "on" or "off"))
        if updateNositButton then updateNositButton() end
    elseif cmd == "!start" then
        startSpam()
    elseif cmd == "!stop" then
        stopSpam()
    end
end

-- HOOK CHAT
for _, plr in pairs(Players:GetPlayers()) do
    plr.Chatted:Connect(function(m) runCmd(m, plr) end)
end
Players.PlayerAdded:Connect(function(plr)
    plr.Chatted:Connect(function(m) runCmd(m, plr) end)
end)

-- ONLY ONE STARTUP MESSAGE
send("👑HAMIDxALPHA👑")

-- ============================
--      COMPACT PHONE GUI
-- ============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SameerBeastGUI"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not screenGui.Parent then screenGui.Parent = LP:WaitForChild("PlayerGui") end

-- LION BUTTON
local lionBtn = Instance.new("TextButton")
lionBtn.Size = UDim2.new(0, 45, 0, 45)
lionBtn.Position = UDim2.new(0, 10, 0, 50)
lionBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
lionBtn.BackgroundTransparency = 0.1
lionBtn.Text = "🦁"
lionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lionBtn.TextSize = 28
lionBtn.Font = Enum.Font.GothamBold
lionBtn.BorderSizePixel = 0
lionBtn.Parent = screenGui

local lionCorner = Instance.new("UICorner")
lionCorner.CornerRadius = UDim.new(1, 0)
lionCorner.Parent = lionBtn

local lionStroke = Instance.new("UIStroke")
lionStroke.Color = Color3.fromRGB(255, 200, 100)
lionStroke.Thickness = 2
lionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
lionStroke.Parent = lionBtn

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 340)
frame.Position = UDim2.new(0.5, -110, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "👑HAMID PAPA👑"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

local minMaxBtn = Instance.new("TextButton")
minMaxBtn.Size = UDim2.new(0, 22, 0, 22)
minMaxBtn.Position = UDim2.new(1, -28, 0, 1.5)
minMaxBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
minMaxBtn.BackgroundTransparency = 0.2
minMaxBtn.Text = "−"
minMaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minMaxBtn.TextSize = 16
minMaxBtn.Font = Enum.Font.GothamBold
minMaxBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -52, 0, 1.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- LABELS
local function makeLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.85, 0, 0, 18)
    l.Position = UDim2.new(0.075, 0, y, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 10
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = frame
    return l
end

local statusLbl = makeLabel("⚪ idle", 0.07)
local targetLbl = makeLabel("target: none", 0.14)
local masterLbl = makeLabel("master: none", 0.21)
local speedLbl = makeLabel("speed: 0.45s", 0.28)

-- INPUTS
local function makeTextBox(ph, y, w)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(w, 0, 0, 22)
    box.Position = UDim2.new(0.075, 0, y, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    box.BackgroundTransparency = 0.1
    box.PlaceholderText = ph
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 11
    box.Font = Enum.Font.Gotham
    box.Parent = frame
    return box
end

local function makeSetBtn(text, x, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0, 22)
    btn.Position = UDim2.new(x, 0, y, 0)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.15
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    return btn
end

local targetBox = makeTextBox("username", 0.35, 0.55)
local setTarget = makeSetBtn("set", 0.675, 0.35, Color3.fromRGB(0, 150, 200))

local masterBox = makeTextBox("master", 0.43, 0.55)
local setMaster = makeSetBtn("set", 0.675, 0.43, Color3.fromRGB(0, 150, 200))

local speedBox = makeTextBox("speed", 0.51, 0.3)
local setSpeed = makeSetBtn("spd", 0.69, 0.51, Color3.fromRGB(200, 150, 0))

-- BUTTONS
local function makeBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 28)
    btn.Position = UDim2.new(0.075, 0, y, 0)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.15
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local startBtn = makeBtn("▶ START", 0.6, Color3.fromRGB(0, 180, 0))
local stopBtn = makeBtn("⏹ STOP", 0.6, Color3.fromRGB(180, 0, 0))
stopBtn.Position = UDim2.new(0.525, 0, 0.6, 0)

local bangBtn = makeBtn("💥 BANG", 0.7, Color3.fromRGB(150, 0, 150))
local noclipBtn = makeBtn("🚫 NOCLIP", 0.7, Color3.fromRGB(0, 100, 200))
noclipBtn.Position = UDim2.new(0.525, 0, 0.7, 0)

local nositBtn = makeBtn("🪑 NOSIT", 0.8, Color3.fromRGB(200, 100, 0))
local rejoinBtn = makeBtn("🔄 REJOIN", 0.8, Color3.fromRGB(0, 100, 200))
rejoinBtn.Position = UDim2.new(0.525, 0, 0.8, 0)

-- BUTTON UPDATE FUNCTIONS (global so chat can call them)
function updateBangButton()
    bangBtn.Text = banging and "💥 BANG ON" or "💥 BANG OFF"
    bangBtn.BackgroundColor3 = banging and Color3.fromRGB(200,0,100) or Color3.fromRGB(150,0,150)
end

function updateNoclipButton()
    noclipBtn.Text = noclipActive and "🚫 NOCLIP ON" or "🚫 NOCLIP OFF"
    noclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(0, 100, 200)
end

function updateNositButton()
    nositBtn.Text = nositActive and "🪑 NOSIT ON" or "🪑 NOSIT OFF"
    nositBtn.BackgroundColor3 = nositActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 100, 0)
end

-- BUTTON ACTIONS (GUI toggles)
setTarget.MouseButton1Click:Connect(function()
    local nt = targetBox.Text:lower()
    if nt ~= "" then target = nt targetLbl.Text = "target: " .. target send("🦁 target: " .. target) targetBox.Text = "" end
end)

setMaster.MouseButton1Click:Connect(function()
    local nm = masterBox.Text:lower()
    if nm ~= "" then master = nm masterLbl.Text = "master: " .. master send("🦁 master set: " .. master) masterBox.Text = "" end
end)

setSpeed.MouseButton1Click:Connect(function()
    local ns = tonumber(speedBox.Text)
    if ns and ns > 0 then speed = ns speedLbl.Text = "speed: " .. ns .. "s" send("[⚡ speed set to " .. ns .. "s ⚡]") else speedBox.Text = tostring(speed) end
end)

startBtn.MouseButton1Click:Connect(function()
    if not active then startSpam() statusLbl.Text = "🟢 SPAMMING" statusLbl.TextColor3 = Color3.fromRGB(0,255,0)
    else send("🦁 already spamming!") end
end)

stopBtn.MouseButton1Click:Connect(function()
    if active or banging then stopSpam() statusLbl.Text = "🔴 STOPPED" statusLbl.TextColor3 = Color3.fromRGB(255,100,100) end
end)

bangBtn.MouseButton1Click:Connect(function()
    banging = not banging
    updateBangButton()
    send("🦁 bang mode: " .. (banging and "on" or "off"))
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    updateNoclip()
    updateNoclipButton()
    send("🦁 noclip: " .. (noclipActive and "on" or "off"))
end)

nositBtn.MouseButton1Click:Connect(function()
    nositActive = not nositActive
    updateNositButton()
    send("🦁 anti-sit: " .. (nositActive and "on" or "off"))
end)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)

local function toggleMainFrame()
    frame.Visible = not frame.Visible
    minMaxBtn.Text = frame.Visible and "−" or "+"
end

minMaxBtn.MouseButton1Click:Connect(toggleMainFrame)
closeBtn.MouseButton1Click:Connect(function()
    stopSpam()
    screenGui:Destroy()
end)
lionBtn.MouseButton1Click:Connect(toggleMainFrame)

-- Initialize buttons
updateBangButton()
updateNoclipButton()
updateNositButton()
statusLbl.TextColor3 = Color3.fromRGB(200,200,200)

print("✅ HAMID KING V2 LOADED – GUI & CHAT FULLY SYNCED")
