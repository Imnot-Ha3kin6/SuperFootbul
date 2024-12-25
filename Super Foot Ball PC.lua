-- Start of full script implementation with all features
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled

if isMobile then
   local UILib = {}
   local function setupMobile(gui)
       gui.Size = UDim2.new(0.8, 0, 0.7, 0)
       gui.Position = UDim2.new(0.5, 0, 0.5, 0)
       gui.AnchorPoint = Vector2.new(0.5, 0.5)
       
       local toggleButton = Instance.new("TextButton")
       toggleButton.Size = UDim2.new(0, 50, 0, 50)
       toggleButton.Position = UDim2.new(0, 10, 0.5, 0)
       toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
       toggleButton.Text = "UI"
       toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
       toggleButton.Parent = game.CoreGui
       
       local corner = Instance.new("UICorner")
       corner.CornerRadius = UDim.new(0, 10)
       corner.Parent = toggleButton
       
       toggleButton.TouchTap:Connect(function()
           gui.Visible = not gui.Visible
       end)
       
       for _, obj in ipairs(gui:GetDescendants()) do
           if obj:IsA("TextButton") or obj:IsA("ImageButton") then
               obj.Size = UDim2.new(obj.Size.X.Scale, 0, obj.Size.Y.Scale * 1.2, 0)
               obj.TouchTap:Connect(function()
                   if obj.MouseButton1Click then
                       obj.MouseButton1Click:Fire()
                   end
               end)
           elseif obj:IsA("ScrollingFrame") then
               obj.ScrollingEnabled = true
               obj.TouchScrollingEnabled = true
               obj.ScrollBarThickness = 12
           end
       end
   end
   
   local oldLoadstring = loadstring
   loadstring = function(...)
       local result = oldLoadstring(...)
       if result then
           local oldResult = result
           return function()
               local ui = oldResult()
               local oldNew = ui.new
               ui.new = function(...)
                   local window = oldNew(...)
                   setupMobile(window.MainUI)
                   return window
               end
               return ui
           end
       end
       return result
   end
end

local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/StepBroFurious/Script/main/HydraHubUi.lua'))()
local Window = UILib.new("Super Football", game.Players.LocalPlayer.Name, "Fwiend")

-- Main Category
local Category1 = Window:Category("Main", "http://www.roblox.com/asset/?id=8395621517")
local SubButton1 = Category1:Button("Combat", "http://www.roblox.com/asset/?id=8395747586")
local SubButton4 = Category1:Button("Blatant", "http://www.roblox.com/asset/?id=8395747586")
local Section1 = SubButton1:Section("Le Main", "Left")
local Section1a2 = SubButton1:Section("Some Team Exploits", "Right")
local Section4 = SubButton4:Section("Movement", "Left")

-- ESP Category 
local Category2 = Window:Category("ESP", "http://www.roblox.com/asset/?id=8395621517")
local SubButton2 = Category2:Button("Visual", "http://www.roblox.com/asset/?id=8395747586")
local Section2 = SubButton2:Section("Highlights", "Left")

-- Misc Category
local Category3 = Window:Category("Misc", "http://www.roblox.com/asset/?id=8395621517")
local SubButton3 = Category3:Button("Settings", "http://www.roblox.com/asset/?id=8395747586")
local Section3 = SubButton3:Section("Options", "Left")

-- Toggle keybind for PC
Section3:Keybind({
   Title = "Toggle Menu",
   Description = "Keybind to toggle menu visibility",
   Default = Enum.KeyCode.RightControl
}, function()
   Window.MainUI.Visible = not Window.MainUI.Visible
end)

-- ESP color configuration
local currentEspColor = Color3.fromRGB(0, 255, 0)

Section2:ColorPicker({
   Title = "ESP Color",
   Description = "Change ESP highlight color",
   Default = currentEspColor
}, function(color)
   currentEspColor = color
   for _, highlight in pairs(playerHighlights) do
       if highlight then
           highlight.FillColor = color
           highlight.OutlineColor = color
       end
   end
   if ballHighlight then
       ballHighlight.FillColor = color
       ballHighlight.OutlineColor = color
   end
end)

-- Team Check
local character = game.Players.LocalPlayer.Character
if character then
   local group = character.Parent.Parent
   if group.Name == "goalhome" then
       print("Player is on home team")
   elseif group.Name == "goalaway" then
       print("Player is on away team") 
   else
       print("Player is not on a team")
   end
end

-- Walkspeed Slider
Section1:Slider({
   Title = "Walk Speed",
   Description = "Adjust your walk speed",
   Min = 0,
   Max = 28,
   Default = 16
}, function(value)
   if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
       game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
   end
end)

-- ESP Functions
local function createHighlight(object, color)
  local highlight = Instance.new("Highlight")
  highlight.FillColor = color
  highlight.OutlineColor = color
  highlight.FillTransparency = 0.5
  highlight.Parent = object
  return highlight
end

-- Ball ESP Toggle
local ballHighlight = nil
Section2:Toggle({
  Title = "Ball ESP",
  Description = "Highlight the ball",
  Default = false
}, function(enabled)
  if enabled then
      if ballHighlight then
          ballHighlight:Destroy()
          ballHighlight = nil
      end
      
      local ball = workspace:FindFirstChild("ServerBall")
      if ball and ball:FindFirstChild("mesh") then
          ballHighlight = createHighlight(ball.mesh, currentEspColor)
      end
  else
      if ballHighlight then
          ballHighlight:Destroy()
          ballHighlight = nil
      end
  end
end)

-- Player ESP Toggle
local playerHighlights = {}
Section2:Toggle({
  Title = "Player ESP",
  Description = "Highlight other players",
  Default = false
}, function(enabled)
  if enabled then
      for _, player in pairs(game.Players:GetPlayers()) do
          if player ~= game.Players.LocalPlayer and player.Character then
              playerHighlights[player.Name] = createHighlight(player.Character, currentEspColor)
          end
      end
      
      game.Players.PlayerAdded:Connect(function(player)
          if player.Character then
              playerHighlights[player.Name] = createHighlight(player.Character, currentEspColor)
          end
          player.CharacterAdded:Connect(function(char)
              playerHighlights[player.Name] = createHighlight(char, currentEspColor)
          end)
      end)
  else
      for _, highlight in pairs(playerHighlights) do
          if highlight then highlight:Destroy() end
      end
      playerHighlights = {}
  end
end)

-- Infinite Stamina Toggle
local staminaLoop = nil
Section1:Toggle({
  Title = "Infinite Stamina",
  Description = "Never run out of energy",
  Default = false
}, function(enabled)
  if enabled then
      if staminaLoop then return end
      staminaLoop = game:GetService("RunService").Heartbeat:Connect(function()
          if game.Players.LocalPlayer.Character and 
             game.Players.LocalPlayer.Character:FindFirstChild("Energy") then
              game.Players.LocalPlayer.Character.Energy.Value = 100
          end
      end)
  else
      if staminaLoop then
          staminaLoop:Disconnect()
          staminaLoop = nil
      end
  end
end)

-- Auto Hit Ball Toggle
local hitballLoop = nil 
Section1:Toggle({
  Title = "Auto Hit Ball",
  Description = "Auto hit ball",
  Default = false
}, function(enabled)
  if enabled then
      if hitballLoop then return end
      hitballLoop = game:GetService("RunService").Heartbeat:Connect(function()
          local character = game.Players.LocalPlayer.Character
          if character and character:FindFirstChild("HumanoidRootPart") then
              local rootPart = character.HumanoidRootPart
              local lookVector = rootPart.CFrame.LookVector
              local currentPos = rootPart.Position
              local targetCFrame = CFrame.new(currentPos, currentPos + lookVector)
              
              local ball = workspace:FindFirstChild("ServerBall")
              if ball then
                  local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("KickBall")
                  
                  remote:FireServer(999, targetCFrame, "dribble")
                  task.wait(0.1)
                  remote:FireServer(1000, targetCFrame, "dribble")
                  task.wait(0.4)
              end
          end
      end)
  else
      if hitballLoop then
          hitballLoop:Disconnect()
          hitballLoop = nil
      end
  end
end)

-- Anti Score
local antiScoreLoop = nil
Section4:Toggle({
 Title = "Anti Score",
 Description = "Block goals automatically",
 Default = false
}, function(enabled)
 if enabled then
     if antiScoreLoop then return end
     antiScoreLoop = game:GetService("RunService").Heartbeat:Connect(function()
         local character = game.Players.LocalPlayer.Character
         if not character then return end
         
         local team = character.Parent.Parent
         if team.Name ~= "goalhome" and team.Name ~= "goalaway" then return end
         
         local goal = workspace[team.Name].RegisterGoal
         goal.Size = Vector3.new(60, 152, 80)
         
         local ball = workspace:FindFirstChild("ServerBall")
         if not ball then return end
         
         local distance = (ball.Position - goal.Position).Magnitude
         if distance <= 30 then
             local savedPos = character.HumanoidRootPart.CFrame
             local ballDir = (ball.Position - goal.Position).Unit
             local blockPos = ball.Position - ballDir * 5
             
             character.HumanoidRootPart.CFrame = CFrame.new(blockPos, ball.Position)
             
             task.wait(0.1)
             character.HumanoidRootPart.CFrame = savedPos
         end
     end)
 else
     if antiScoreLoop then
         antiScoreLoop:Disconnect()
         antiScoreLoop = nil
     end
 end
end)

-- Ball Teleport Toggle
local tpLoop = nil
Section4:Toggle({
   Title = "Ball Teleport",
   Description = "Teleport repeatedly to the ball",
   Default = false
}, function(enabled)
   if enabled then
       if tpLoop then return end
       tpLoop = game:GetService("RunService").Heartbeat:Connect(function()
           local character = game.Players.LocalPlayer.Character
           local ball = workspace:FindFirstChild("ServerBall")
           
           if character and character:FindFirstChild("HumanoidRootPart") and ball then
               local currentOrientation = character.HumanoidRootPart.CFrame.Rotation
               character.HumanoidRootPart.CFrame = CFrame.new(ball.Position) * currentOrientation
           end
       end)
   else
       if tpLoop then
           tpLoop:Disconnect()
           tpLoop = nil
       end
   end
end)

-- Team Position Functions
local function joinTeam(teamSide, position)
  local args = {
      [1] = teamSide,
      [2] = position
  }
  game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("chosenTeam"):FireServer(unpack(args))
end

Section1:Dropdown({
  Title = "Home Team Position",
  Description = "Select your position for Home team", 
  Default = "CenterBack",  
  Options = {
      ["CenterBack"] = false,
      ["GoalKeeper"] = false, 
      ["RightWing"] = false,
      ["RightBack"] = false,
      ["LeftWing"] = false,
      ["LeftBack"] = false,
      ["Striker"] = false
  }
}, function(value)
  for pos, selected in pairs(value) do
      if selected then
          joinTeam("home", pos)
      end
  end
end)

Section1:Dropdown({
  Title = "Away Team Position",
  Description = "Select your position for Away team",
  Default = "CenterBack",
  Options = {
      ["CenterBack"] = false,
      ["GoalKeeper"] = false, 
      ["RightWing"] = false,
      ["RightBack"] = false,
      ["LeftWing"] = false,
      ["LeftBack"] = false,
      ["Striker"] = false
  }
}, function(value)
  for pos, selected in pairs(value) do
      if selected then
          joinTeam("away", pos)
      end
  end
end)

-- Remove Goalie Walls Button
Section1a2:Button({
   Title = "Remove Goalie Walls",
   Description = "Delete the goalie walls",
   ButtonName = "Remove",
}, function()
   if workspace:FindFirstChild("GKwalls") then
       workspace.GKwalls:Destroy()
   end
end)

-- Destroy GUI Button
Section3:Button({
   Title = "Destroy Menu",
   Description = "Remove the GUI",
   ButtonName = "Destroy"
}, function()
   if Window.MainUI and Window.MainUI.Parent then
       Window.MainUI:Destroy()
   end
end)
