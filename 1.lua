local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k \~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

function Library:CreateWindow(options)
    local title = options.Title or "UI Library"
    
    local screenGui = create("ScreenGui", {
        Name = "ArchiveXNova",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local mainFrame = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(300, 300),
        Position = UDim2.new(0.5, -150, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui
    })
    
    local corner = create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = titleBar})
    
    local titleLabel = create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    local minimizeBtn = create("TextButton", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -34, 0, 4),
        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
        Text = "−",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 18,
        Font = Enum.Font.Gotham,
        Parent = titleBar
    })
    
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minimizeBtn})
    
    local contentFrame = create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -34),
        Position = UDim2.fromOffset(0, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = mainFrame
    })
    
    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = contentFrame
    })
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Draggable (mouse + touch)
    local dragging, dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        mainFrame.Position = newPos
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
    
    -- Minimize / Restore logic
    local minimized = false
    local originalSize = mainFrame.Size
    local originalPos = mainFrame.Position
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            mainFrame.Size = UDim2.fromOffset(300, 34)
            contentFrame.Visible = false
            minimizeBtn.Text = "+"
        else
            mainFrame.Size = originalSize
            contentFrame.Visible = true
            minimizeBtn.Text = "−"
        end
        
        TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = minimized and UDim2.fromOffset(300, 34) or originalSize
        }):Play()
    end)
    
    -- Window object
    local window = {}
    
    function window:Section(name)
        local section = {}
        
        local sectionFrame = create("Frame", {
            Size = UDim2.new(1, -16, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = #contentFrame:GetChildren() + 1,
            Parent = contentFrame
        })
        
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 8),
            Parent = sectionFrame
        })
        
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(160, 170, 255),
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sectionFrame
        })
        
        local itemLayout = create("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = sectionFrame
        })
        
        itemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sectionFrame.Size = UDim2.new(1, -16, 0, itemLayout.AbsoluteContentSize.Y + 30)
        end)
        
        function section:Button(text, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Color3.fromRGB(45, 45, 60),
                BorderSizePixel = 0,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 13,
                Font = Enum.Font.GothamSemibold,
                Parent = sectionFrame
            })
            
            create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
            
            local hover = create("Frame", {
                Size = UDim2.fromScale(1,1),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 1,
                Parent = btn
            })
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(hover, TweenInfo.new(0.2), {BackgroundTransparency = 0.92}):Play()
            end)
            
            btn.MouseLeave:Connect(function()
                TweenService:Create(hover, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end)
            
            btn.MouseButton1Click:Connect(callback or function() end)
            
            return btn
        end
        
        function section:Label(text)
            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(190, 190, 200),
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
        end
        
        function section:Toggle(text, default, callback)
            local toggled = default or false
            local tog = {}
            
            local frame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            
            local indicator = create("Frame", {
                Size = UDim2.fromOffset(42, 22),
                Position = UDim2.new(1, -50, 0.5, -11),
                BackgroundColor3 = toggled and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(70, 70, 85),
                Parent = frame
            })
            
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = indicator})
            
            local circle = create("Frame", {
                Size = UDim2.fromOffset(18, 18),
                Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
                BackgroundColor3 = Color3.fromRGB(230, 230, 240),
                Parent = indicator
            })
            
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = circle})
            
            local function update()
                TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    BackgroundColor3 = toggled and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(70, 70, 85)
                }):Play()
                
                TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                }):Play()
            end
            
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggled = not toggled
                    update()
                    if callback then callback(toggled) end
                end
            end)
            
            if default then update() end
            
            function tog:Set(value)
                toggled = value
                update()
                if callback then callback(toggled) end
            end
            
            return tog
        end
        
        function section:Slider(text, min, max, default, step, callback)
            local value = default or min
            step = step or 1
            
            local frame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 18),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            
            local valueLabel = create("TextLabel", {
                Size = UDim2.fromOffset(50, 18),
                Position = UDim2.new(1, -55, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = Color3.fromRGB(180, 180, 200),
                TextSize = 13,
                Font = Enum.Font.Gotham,
                Parent = frame
            })
            
            local bar = create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.fromOffset(0, 24),
                BackgroundColor3 = Color3.fromRGB(50, 50, 65),
                Parent = frame
            })
            
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = bar})
            
            local fill = create("Frame", {
                Size = UDim2.fromScale((value - min) / (max - min), 1),
                BackgroundColor3 = Color3.fromRGB(90, 140, 255),
                BorderSizePixel = 0,
                Parent = bar
            })
            
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = fill})
            
            local draggingSlider = false
            
            local function updateSlider(posX)
                local relX = math.clamp((posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local newVal = min + (max - min) * relX
                newVal = math.floor((newVal - min) / step + 0.5) * step + min
                newVal = math.clamp(newVal, min, max)
                
                value = newVal
                valueLabel.Text = tostring(value)
                TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.fromScale(relX, 1)}):Play()
                
                if callback then callback(value) end
            end
            
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSlider(input.Position.X)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)
            
            updateSlider(bar.AbsolutePosition.X + (default - min)/(max - min) * bar.AbsoluteSize.X)
            
            local slider = {}
            function slider:Set(val)
                value = math.clamp(val, min, max)
                valueLabel.Text = tostring(value)
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.fromScale(rel, 1)
                if callback then callback(value) end
            end
            return slider
        end
        
        function section:Dropdown(text, options, default, callback)
            local selected = default or options[1]
            local open = false
            
            local frame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            local mainBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Color3.fromRGB(45, 45, 60),
                BorderSizePixel = 0,
                Text = text .. " : " .. selected,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 13,
                Font = Enum.Font.GothamSemibold,
                Parent = frame
            })
            
            create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = mainBtn})
            
            local listFrame = create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.fromOffset(0, 34),
                BackgroundColor3 = Color3.fromRGB(30, 30, 38),
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                Visible = false,
                ZIndex = 2,
                Parent = frame
            })
            
            create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = listFrame})
            
            local listPadding = create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                Parent = listFrame
            })
            
            local listLayoutDD = create("UIListLayout", {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = listFrame
            })
            
            local function toggleDropdown()
                open = not open
                listFrame.Visible = open
                
                TweenService:Create(listFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Size = open and UDim2.new(1, 0, 0, math.min(#options * 34 + 8, 140)) or UDim2.new(1,0,0,0)
                }):Play()
            end
            
            mainBtn.MouseButton1Click:Connect(toggleDropdown)
            
            for _, opt in ipairs(options) do
                local btn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 55),
                    BorderSizePixel = 0,
                    Text = opt,
                    TextColor3 = opt == selected and Color3.fromRGB(140, 200, 255) or Color3.fromRGB(190, 190, 210),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    Parent = listFrame
                })
                
                create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = btn})
                
                btn.MouseButton1Click:Connect(function()
                    selected = opt
                    mainBtn.Text = text .. " : " .. selected
                    toggleDropdown()
                    for _, b in ipairs(listFrame:GetChildren()) do
                        if b:IsA("TextButton") then
                            b.TextColor3 = (b.Text == selected) and Color3.fromRGB(140, 200, 255) or Color3.fromRGB(190, 190, 210)
                        end
                    end
                    if callback then callback(selected) end
                end)
            end
            
            local dd = {}
            function dd:Set(val)
                if table.find(options, val) then
                    selected = val
                    mainBtn.Text = text .. " : " .. selected
                    for _, b in ipairs(listFrame:GetChildren()) do
                        if b:IsA("TextButton") then
                            b.TextColor3 = (b.Text == selected) and Color3.fromRGB(140, 200, 255) or Color3.fromRGB(190, 190, 210)
                        end
                    end
                    if callback then callback(selected) end
                end
            end
            return dd
        end
        
        return section
    end
    
    return window
end

return Library
