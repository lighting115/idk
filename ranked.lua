
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local AbilitySpam4 = {
    enabled = false,
    connection = nil
}
function AbilitySpam4:GetPlayerCFrame()
    local p = LocalPlayer
    return p and p.Character and p.Character.HumanoidRootPart and p.Character.HumanoidRootPart.CFrame or CFrame.new()
end

function AbilitySpam4:GetCurrentCharacter()
    local ok, res = pcall(function()
        return LocalPlayer.Data.Character.Value
    end)
    if ok and res then return res end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum:GetAttribute("CharacterName") or "Unknown"
end

function AbilitySpam4:HasAbility4(characterName)
    local ok, res = pcall(function()
        local chars = ReplicatedStorage:WaitForChild("Characters")
        local folder = chars:FindFirstChild(characterName)
        local ab = folder and folder:FindFirstChild("Abilities")
        return ab and ab:FindFirstChild("4") ~= nil
    end)
    return ok and res
end

function AbilitySpam4:FindNearestPlayer()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local th = p.Character:FindFirstChild("Humanoid")
            if tr and th then
                local hp = th:GetAttribute("Health")
                if hp then
                    local d = (hrp.Position - tr.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = p
                    end
                end
            end
        end
    end
    return nearest
end

function AbilitySpam4:GetNearestPlayerCFrame()
    local p = self:FindNearestPlayer()
    return p and p.Character and p.Character.HumanoidRootPart and p.Character.HumanoidRootPart.CFrame or CFrame.new()
end

function AbilitySpam4:UseAbility4(number)
    local charName = self:GetCurrentCharacter()
    if not self:HasAbility4(charName) then return end

    local target = self:FindNearestPlayer()
    if not target then return end

    local targetChar = target.Character
    local targetCF = self:GetNearestPlayerCFrame()

    pcall(function()
        local ability = ReplicatedStorage.Characters[charName].Abilities[number]
        ReplicatedStorage.Remotes.Abilities.Ability:FireServer(ability,9000000)
		local servertime = workspace:GetServerTimeNow()

        local actions = {377,380,383,384,385,387,389}
        for i=1,4 do
            local args = {
                ability,
                charName..":Abilities:"..number,
                i,
                9000000,
                {
                    HitboxCFrames = {targetCF,targetCF},
                    BestHitCharacter = targetChar,
                    HitCharacters = {targetChar},
                    Ignore = i>2 and {ActionNumber1={targetChar}} or {},
                    DeathInfo = {},
                    BlockedCharacters = {},
                    HitInfo = {
                        IsFacing = not (i==1 or i==2),
                        IsInFront = i<=2,
                        Blocked = i>2 and false or nil
                    },
                    ServerTime = servertime,
                    Actions = i>2 and {ActionNumber1={}} or {},
                    FromCFrame = targetCF
                },
                "Action"..actions[i],
                i==2 and 0.1 or nil
            }

            if i==4 then
                args[5].RockCFrame = targetCF
                args[5].Actions = {
                    ActionNumber1 = {
                        [target.Name] = {
                            StartCFrameStr = tostring(targetCF.X)..","..tostring(targetCF.Y)..","..tostring(targetCF.Z)..",0,0,0,0,0,0,0,0,0",
                            ImpulseVelocity = Vector3.new(1901,-25000,291),
                            AbilityName = number,
                            RotVelocityStr = "0,0,0",
                            VelocityStr = "1.900635,0.010867,0.291061",
                            Duration = 2,
                            RotImpulseVelocity = Vector3.new(5868,-6649,-7414),
                            Seed = math.random(1,1e6),
                            LookVectorStr = "0.988493,0,0.151268"
                        }
                    }
                }
            end

            ReplicatedStorage.Remotes.Combat.Action:FireServer(unpack(args))
        end
    end)
end

function AbilitySpam4:Start()
    if self.connection then return end
    self.enabled = true
    self.connection = RunService.Heartbeat:Connect(function()
        if not self.enabled then return end
        for i=1,1 do
        self:UseAbility4(4)
        task.wait()
        pcall(function()
                local c = self:GetCurrentCharacter()
                ReplicatedStorage.Remotes.Abilities.AbilityCanceled:FireServer(
                    ReplicatedStorage.Characters[c].Abilities["4"]
                )
            end)
        self:UseAbility4(3)
        task.wait()
        pcall(function()
                local c = self:GetCurrentCharacter()
                ReplicatedStorage.Remotes.Abilities.AbilityCanceled:FireServer(
                    ReplicatedStorage.Characters[c].Abilities["3"]
                )
            end)
        end
    end)
end
function AbilitySpam4:Start2()
    if self.connection then return end
    self.enabled = true
    self.connection = RunService.Heartbeat:Connect(function()
        if not self.enabled then return end
        for i=1,4 do
        self:UseAbility4(4)
        task.wait()
        pcall(function()
                local c = self:GetCurrentCharacter()
                ReplicatedStorage.Remotes.Abilities.AbilityCanceled:FireServer(
                    ReplicatedStorage.Characters[c].Abilities["4"]
                )
            end)
        self:UseAbility4(3)
        task.wait()
        pcall(function()
                local c = self:GetCurrentCharacter()
                ReplicatedStorage.Remotes.Abilities.AbilityCanceled:FireServer(
                    ReplicatedStorage.Characters[c].Abilities["3"]
                )
            end)
        end
    end)
end

function AbilitySpam4:Stop()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.enabled = false
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local enabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(0, 10, 1, -50)
button.AnchorPoint = Vector2.new(0, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
button.Text = "ON"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local function updateButton()
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        button.Text = "ON"
    else
        button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        button.Text = "OFF"
    end
end

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateButton()
    if enabled then
        pcall(function() AbilitySpam4:Start() end)
    else
        pcall(function() AbilitySpam4:Stop() end)
    end
end)
local MobRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Character"):WaitForChild("ChangeCharacter")
local mob = game:GetService("Players").LocalPlayer.Data.Character.Value
if mob ~= "Mob" then
    MobRemote:FireServer("Mob")
    task.wait(0.2)
end

updateButton()
task.wait(0.05)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(0.2)
pcall(function() AbilitySpam4:Start2() end)
task.wait(9)
pcall(function() AbilitySpam4:Stop() end)
task.wait()
pcall(function() AbilitySpam4:Start() end)
