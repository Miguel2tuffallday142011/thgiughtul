-- Primordial UI Library
-- Recreated from reference image

local PrimordialUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Theme
local Theme = {
    BG          = Color3.fromRGB(22, 22, 22),
    BGSecondary = Color3.fromRGB(28, 28, 28),
    BGTertiary  = Color3.fromRGB(32, 32, 32),
    BGItem      = Color3.fromRGB(38, 38, 38),
    Accent      = Color3.fromRGB(204, 70, 90),    AccentDim   = Color3.fromRGB(160, 50, 50),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecond  = Color3.fromRGB(160, 160, 160),
    TextDim     = Color3.fromRGB(100, 100, 100),
    Border      = Color3.fromRGB(45, 45, 45),
    TabBar      = Color3.fromRGB(18, 18, 18),
    Sidebar     = Color3.fromRGB(25, 25, 25),
    SliderFill  = Color3.fromRGB(220, 80, 80),
    SliderBG    = Color3.fromRGB(50, 50, 50),
}

-- Utility
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.15, style, dir), props):Play()
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function MakePadding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.Parent = parent
    return p
end

local function MakeListLayout(parent, dir, spacing, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection     = dir or Enum.FillDirection.Vertical
    l.Padding           = UDim.new(0, spacing or 4)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function MakeFrame(parent, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or Theme.BG
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function MakeLabel(parent, text, size, pos, color, font, textsize)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,16)
    l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextColor3 = color or Theme.TextPrimary
    l.Font = font or Enum.Font.Gotham
    l.TextSize = textsize or 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BorderSizePixel = 0
    l.RichText = true
    l.Parent = parent
    return l
end

-- ─────────────────────────────────────────────────────────────
-- WINDOW CREATE
-- ─────────────────────────────────────────────────────────────
function PrimordialUI:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "cipher"
    local image    = config.Image    or nil
    local subtitle = config.Subtitle or ""
    local size     = config.Size     or Vector2.new(760, 500)

    local Window = {
        _tabs     = {},
        _pages    = {},
        _selTab   = nil,
        _selPage  = nil,
    }

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrimordialUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer.PlayerGui end
    Window._sg = sg

    -- Main frame
    local main = MakeFrame(sg,
        UDim2.fromOffset(size.X, size.Y),
        UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        Theme.BG)
    main.Name = "Main"
    MakeCorner(main, 10)
    Window._main = main

    -- Drag support
    do
        local dragging, dragStart, startPos = false, nil, nil
        main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- Header bar (logo + title)
    local header = MakeFrame(main,
        UDim2.new(1,0,0,50),
        UDim2.new(0,0,0,0),
        Theme.BGSecondary)
    header.ZIndex = 2
    MakeCorner(header, 10)
    -- Fix bottom corners of header
    local hfix = MakeFrame(header, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), Theme.BGSecondary)

    local titleLabel = MakeLabel(header,
        title,
        UDim2.fromOffset(200, 28),
        UDim2.fromOffset(14, 11),
        Theme.TextPrimary,
        Enum.Font.GothamBold, 20)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Separator line under header
    local sep = MakeFrame(main, UDim2.new(1,0,0,1), UDim2.new(0,0,0,50), Theme.Accent)

    -- Content area (everything below header, above tab bar)
    local content = MakeFrame(main,
        UDim2.new(1,0,1,-100),
        UDim2.new(0,0,0,51),
        Theme.BG)
    content.ClipsDescendants = true
    Window._content = content

    -- Left sidebar (sub-pages list)
    local sidebar = MakeFrame(content,
        UDim2.new(0,150,1,0),
        UDim2.new(0,0,0,0),
        Theme.Sidebar)
    sidebar.Name = "Sidebar"
    MakePadding(sidebar, 8, 6, 8, 6)
    local sideList = MakeListLayout(sidebar, Enum.FillDirection.Vertical, 2)
    Window._sidebar = sidebar

    -- Sidebar right border
    local sideBar = MakeFrame(content,
        UDim2.new(0,1,1,0),
        UDim2.new(0,150,0,0),
        Theme.Border)

    -- Right pane (sub-tabs + columns)
    local rightPane = MakeFrame(content,
        UDim2.new(1,-151,1,0),
        UDim2.new(0,151,0,0),
        Theme.BG)
    Window._rightPane = rightPane

    -- Sub-tabs bar inside right pane
    local subTabBar = MakeFrame(rightPane,
        UDim2.new(1,0,0,36),
        UDim2.new(0,0,0,0),
        Theme.BGSecondary)
    MakeListLayout(subTabBar, Enum.FillDirection.Horizontal, 0,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    MakePadding(subTabBar, 0, 0, 0, 8)
    Window._subTabBar = subTabBar

    -- Sub-tab underline
    local subUnderline = MakeFrame(rightPane,
        UDim2.new(1,0,0,1),
        UDim2.new(0,0,0,35),
        Theme.Border)

    -- Column area
    local colArea = MakeFrame(rightPane,
        UDim2.new(1,0,1,-37),
        UDim2.new(0,0,0,37),
        Theme.BG)
    colArea.ClipsDescendants = true
    Window._colArea = colArea

    -- Bottom tab bar
    local tabBar = MakeFrame(main,
        UDim2.new(1,0,0,48),
        UDim2.new(0,0,1,-48),
        Theme.TabBar)
    local tabFix = MakeFrame(tabBar, UDim2.new(1,0,0,6), UDim2.new(0,0,0,0), Theme.TabBar)
    local tabSep = MakeFrame(tabBar, UDim2.new(1,0,0,1), UDim2.new(0,0,0,0), Theme.Accent)
    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1,0,1,0)
    tabList.BackgroundTransparency = 1
    tabList.Parent = tabBar
    MakeListLayout(tabList, Enum.FillDirection.Horizontal, 0,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
    Window._tabBar = tabList
    MakeCorner(tabBar, 10)

    -- ─────────────────────────────────────────────────────────────
    -- ADD TAB (bottom bar)
    -- ─────────────────────────────────────────────────────────────
    function Window:AddTab(config)
        config = config or {}
        local tabName = config.Text or "Tab"
        local icon    = config.Icon or "⚙"

        local Tab = { _pages = {}, _selPage = nil, _window = Window }

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = Window._tabBar

        local iconL = Instance.new("TextLabel")
        iconL.Size = UDim2.new(1,0,0,18)
        iconL.Position = UDim2.new(0,0,0.5,-16)
        iconL.BackgroundTransparency = 1
        iconL.Text = icon
        iconL.TextColor3 = Theme.TextDim
        iconL.Font = Enum.Font.GothamBold
        iconL.TextSize = 16
        iconL.Parent = btn

        local nameL = MakeLabel(btn, tabName,
            UDim2.new(1,0,0,14),
            UDim2.new(0,0,0.5,3),
            Theme.TextDim, Enum.Font.Gotham, 11)
        nameL.TextXAlignment = Enum.TextXAlignment.Center

        -- Active indicator line at top of tab bar
        local indicator = MakeFrame(btn,
            UDim2.new(0.6,0,0,2),
            UDim2.new(0.2,0,0,0),
            Theme.Accent)
        indicator.Name = "Indicator"
        MakeCorner(indicator, 1)
        indicator.Visible = false

        local tabContent = MakeFrame(Window._content,
            UDim2.new(1,-151,1,0),
            UDim2.new(0,151,0,0),
            Theme.BGSecondary)  -- BGSecondary so top bar blends seamlessly
        -- Clip below the sub-tab bar to BG color
        local tabContentBG = MakeFrame(tabContent,
            UDim2.new(1,0,1,-36),
            UDim2.new(0,0,0,36),
            Theme.BG)
        tabContentBG.ZIndex = 1
        tabContent.Visible = false
        Tab._frame = tabContent

        -- When tab activated, show its sidebar pages
        function Tab:_activate()
            -- Hide all tabs and their sidebar entries
            for _, t in ipairs(Window._tabs) do
                t._frame.Visible = false
                t._indicator.Visible = false
                Tween(t._iconL, {TextColor3 = Theme.TextDim}, 0.15)
                Tween(t._nameL, {TextColor3 = Theme.TextDim}, 0.15)
                for _, p in ipairs(t._pages) do
                    if p._sideBtn then p._sideBtn.Visible = false end
                end
            end
            -- Show this tab
            self._frame.Visible = true
            self._indicator.Visible = true
            Tween(self._iconL, {TextColor3 = Theme.Accent}, 0.15)
            Tween(self._nameL, {TextColor3 = Theme.TextPrimary}, 0.15)
            -- Show this tab's sidebar entries
            for _, p in ipairs(self._pages) do
                if p._sideBtn then p._sideBtn.Visible = true end
            end
            Window._selTab = self
            -- Select first page
            if self._pages[1] then
                self._pages[1]:_activate()
            end
        end

        Tab._indicator = indicator
        Tab._iconL = iconL
        Tab._nameL = nameL

        btn.MouseButton1Click:Connect(function() Tab:_activate() end)
        btn.MouseEnter:Connect(function()
            if Window._selTab ~= Tab then
                Tween(iconL, {TextColor3 = Theme.TextSecond}, 0.1)
                Tween(nameL, {TextColor3 = Theme.TextSecond}, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window._selTab ~= Tab then
                Tween(iconL, {TextColor3 = Theme.TextDim}, 0.1)
                Tween(nameL, {TextColor3 = Theme.TextDim}, 0.1)
            end
        end)

        table.insert(Window._tabs, Tab)

        -- Auto-select first tab
        if #Window._tabs == 1 then
            task.defer(function() Tab:_activate() end)
        end

        -- ─────────────────────────────────────────────────────────────
        -- ADD PAGE (left sidebar)
        -- ─────────────────────────────────────────────────────────────
        function Tab:AddPage(config)
            config = config or {}
            local pageName = config.Text or "Page"
            local pageSub  = config.Sub  or ""

            local Page = { _subTabs = {}, _selSubTab = nil, _tab = Tab }

            -- Sidebar entry — hidden by default, shown when parent tab activates
            local sideBtn = Instance.new("TextButton")
            sideBtn.Size = UDim2.new(1,0,0,46)
            sideBtn.BackgroundTransparency = 1
            sideBtn.Text = ""
            sideBtn.BorderSizePixel = 0
            sideBtn.Visible = true  -- visible by default; Tab._activate manages visibility
            sideBtn.Parent = Window._sidebar

            local sideAccent = MakeFrame(sideBtn,
                UDim2.new(0,3,0.6,0),
                UDim2.new(0,0,0.2,0),
                Theme.Accent)
            sideAccent.Name = "SideAccent"
            MakeCorner(sideAccent, 2)
            sideAccent.Visible = false

            local sideBG = MakeFrame(sideBtn,
                UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
                Theme.Accent)
            sideBG.BackgroundTransparency = 1
            MakeCorner(sideBG, 4)

            local sideTitle = MakeLabel(sideBtn, pageName,
                UDim2.new(1,-12,0,18),
                UDim2.new(0,10,0,8),
                Theme.TextDim, Enum.Font.GothamBold, 13)

            local sideSub = MakeLabel(sideBtn, pageSub,
                UDim2.new(1,-12,0,13),
                UDim2.new(0,10,0,26),
                Theme.TextDim, Enum.Font.Gotham, 11)

            -- Page frame (holds sub-tab bar + columns)
            -- Parent to tabContent so it hides automatically with tab
            local pageFrame = MakeFrame(tabContent,
                UDim2.new(1,-151,1,0),
                UDim2.new(0,151,0,0),
                Theme.BG)
            pageFrame.Visible = false
            Page._frame = pageFrame

            -- Sub-tab bar sits on the persistent top bar
            local subBarBG = MakeFrame(pageFrame,
                UDim2.new(1,0,0,36),
                UDim2.new(0,0,0,0),
                Theme.BGSecondary)
            subBarBG.ZIndex = 2

            local subBar = subBarBG
            MakeListLayout(subBar, Enum.FillDirection.Horizontal, 0,
                Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
            Page._subBar = subBar

            -- Column scroll area
            -- Content scroll area (shared, sub-tabs create their own holders inside)
            local colScroll = Instance.new("ScrollingFrame")
            colScroll.Size = UDim2.new(1,0,1,-37)
            colScroll.Position = UDim2.new(0,0,0,37)
            colScroll.BackgroundTransparency = 1
            colScroll.BorderSizePixel = 0
            colScroll.ScrollBarThickness = 3
            colScroll.ScrollBarImageColor3 = Theme.Accent
            colScroll.CanvasSize = UDim2.new(0,0,0,0)
            colScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            colScroll.Name = "ColScroll"
            colScroll.Parent = pageFrame
            Page._colScroll = colScroll
            Page._leftCol = colScroll   -- sub-tabs will create their own frames inside
            Page._rightCol = colScroll  -- placeholder, not used directly

            function Page:_activate()
                for _, p in ipairs(Tab._pages) do
                    p._frame.Visible = false
                    p._sideAccent.Visible = false
                    Tween(p._sideTitle, {TextColor3 = Theme.TextDim}, 0.15)
                    Tween(p._sideSub,   {TextColor3 = Theme.TextDim}, 0.15)
                end
                self._frame.Visible = true
                self._sideAccent.Visible = true
                Tween(self._sideTitle, {TextColor3 = Theme.TextPrimary}, 0.15)
                Tween(self._sideSub,   {TextColor3 = Theme.Accent}, 0.15)
                Tab._selPage = self
                -- Select first sub-tab
                if self._subTabs[1] then
                    self._subTabs[1]:_activate()
                end
            end

            Page._sideAccent = sideAccent
            Page._sideBG     = sideBG
            Page._sideTitle  = sideTitle
            Page._sideSub    = sideSub
            Page._sideBtn    = sideBtn

            sideBtn.MouseButton1Click:Connect(function() Page:_activate() end)
            sideBtn.MouseEnter:Connect(function()
                if Tab._selPage ~= Page then
                    Tween(sideTitle, {TextColor3 = Theme.TextSecond}, 0.1)
                end
            end)
            sideBtn.MouseLeave:Connect(function()
                if Tab._selPage ~= Page then
                    Tween(sideTitle, {TextColor3 = Theme.TextDim}, 0.1)
                end
            end)

            table.insert(Tab._pages, Page)

            -- ─────────────────────────────────────────────────────────────
            -- ADD SUB-TAB (top bar of right pane)
            -- ─────────────────────────────────────────────────────────────
            function Page:AddSubTab(config)
                config = config or {}
                local stName = config.Text or "SubTab"

                local SubTab = { _sections = {}, _left = {}, _right = {}, _page = Page }

                local stBtn = Instance.new("TextButton")
                stBtn.Size = UDim2.new(0,80,1,0)
                stBtn.BackgroundTransparency = 1
                stBtn.Text = ""
                stBtn.BorderSizePixel = 0
                stBtn.Parent = Page._subBar

                local stLabel = MakeLabel(stBtn, stName,
                    UDim2.new(1,0,1,0),
                    UDim2.new(0,0,0,0),
                    Theme.TextDim, Enum.Font.Gotham, 12)
                stLabel.TextXAlignment = Enum.TextXAlignment.Center

                local stUnderline = MakeFrame(stBtn,
                    UDim2.new(0.7,0,0,2),
                    UDim2.new(0.15,0,1,-2),
                    Theme.Accent)
                stUnderline.Name = "Underline"
                stUnderline.Visible = false

                -- SubTab gets its OWN colHolder inside the shared colScroll
                local stColHolder = Instance.new("Frame")
                stColHolder.Size = UDim2.new(1, -16, 0, 0)
                stColHolder.Position = UDim2.new(0, 8, 0, 8)
                stColHolder.AnchorPoint = Vector2.new(0, 0)
                stColHolder.BackgroundTransparency = 1
                stColHolder.BorderSizePixel = 0
                stColHolder.AutomaticSize = Enum.AutomaticSize.Y
                stColHolder.Visible = false
                stColHolder.Parent = Page._colScroll

                local stLeftHolder = MakeFrame(stColHolder,
                    UDim2.new(1, 0, 0, 0), UDim2.new(0,0,0,0), Theme.BG)
                stLeftHolder.AnchorPoint = Vector2.new(0,0)
                stLeftHolder.AutomaticSize = Enum.AutomaticSize.Y
                MakeListLayout(stLeftHolder, Enum.FillDirection.Vertical, 8)
                SubTab._leftHolder = stLeftHolder

                local stRightHolder = MakeFrame(stColHolder,
                    UDim2.new(0.5, -4, 0, 0), UDim2.new(0.5, 4, 0, 0), Theme.BG)
                stRightHolder.AnchorPoint = Vector2.new(0,0)
                stRightHolder.AutomaticSize = Enum.AutomaticSize.Y
                stRightHolder.Visible = false
                MakeListLayout(stRightHolder, Enum.FillDirection.Vertical, 8)
                SubTab._rightHolder = stRightHolder
                SubTab._colHolder = stColHolder
                SubTab._hasTwoCols = false

                function SubTab:_activate()
                    for _, st in ipairs(Page._subTabs) do
                        if st._colHolder then st._colHolder.Visible = false end
                        st._underline.Visible = false
                        Tween(st._label, {TextColor3 = Theme.TextDim}, 0.12)
                    end
                    if self._colHolder then self._colHolder.Visible = true end
                    self._underline.Visible = true
                    Tween(self._label, {TextColor3 = Theme.TextPrimary}, 0.12)
                    Page._selSubTab = self
                end

                SubTab._label     = stLabel
                SubTab._underline = stUnderline

                stBtn.MouseButton1Click:Connect(function() SubTab:_activate() end)
                stBtn.MouseEnter:Connect(function()
                    if Page._selSubTab ~= SubTab then
                        Tween(stLabel, {TextColor3 = Theme.TextSecond}, 0.1)
                    end
                end)
                stBtn.MouseLeave:Connect(function()
                    if Page._selSubTab ~= SubTab then
                        Tween(stLabel, {TextColor3 = Theme.TextDim}, 0.1)
                    end
                end)

                table.insert(Page._subTabs, SubTab)
                if #Page._subTabs == 1 then
                    task.defer(function()
                        if Page._selSubTab == nil then SubTab:_activate() end
                    end)
                end

                -- ─────────────────────────────────────────────────────────────
                -- ADD SECTION (grouped box with title, inside a column)
                -- ─────────────────────────────────────────────────────────────
                function SubTab:AddSection(config)
                    config = config or {}
                    local sTitle = config.Title or "Section"
                    local side   = config.Side  or "Left"

                    -- First right section: switch to two-column layout
                    if side == "Right" and not SubTab._hasTwoCols then
                        SubTab._hasTwoCols = true
                        SubTab._leftHolder.Size = UDim2.new(0.5, -4, 0, 0)
                        SubTab._rightHolder.Size = UDim2.new(0.5, -4, 0, 0)
                        SubTab._rightHolder.Visible = true
                    end

                    local holder = side == "Right" and SubTab._rightHolder or SubTab._leftHolder

                    local Section = {}

                    local box = MakeFrame(holder, UDim2.fromOffset(0, 0), nil, Theme.BGTertiary)
                    box.Size = UDim2.new(1, 0, 0, 0)
                    box.AutomaticSize = Enum.AutomaticSize.Y
                    MakeCorner(box, 6)
                    MakePadding(box, 10, 10, 10, 10)
                    local boxList = MakeListLayout(box, Enum.FillDirection.Vertical, 8)

                    -- Section title
                    local titleRow = MakeFrame(box, UDim2.new(1,0,0,16), nil, Theme.BGTertiary)
                    local titleL = MakeLabel(titleRow, sTitle,
                        UDim2.new(1,0,1,0), nil,
                        Theme.TextSecond, Enum.Font.GothamBold, 12)
                    -- Divider line after title
                    local div = MakeFrame(box, UDim2.new(1,0,0,1), nil, Theme.Accent)

                    Section._box = box

                    -- ── Toggle ──────────────────────────────────────────────
                    function Section:AddToggle(config)
                        config = config or {}
                        local label    = config.Text     or "Toggle"
                        local default  = config.Default  or false
                        local callback = config.Callback or function() end
                        local flag     = config.Flag

                        local row = MakeFrame(box, UDim2.new(1,0,0,24), nil, Theme.BGTertiary)

                        local lbl = MakeLabel(row, label,
                            UDim2.new(1,-44,1,0), nil,
                            default and Theme.TextPrimary or Theme.TextDim,
                            Enum.Font.Gotham, 12)

                        local trackBtn = Instance.new("TextButton")
                        trackBtn.Size = UDim2.fromOffset(36, 18)
                        trackBtn.Position = UDim2.new(1,-38,0.5,-9)
                        trackBtn.BackgroundColor3 = default and Theme.Accent or Theme.SliderBG
                        trackBtn.Text = ""
                        trackBtn.BorderSizePixel = 0
                        trackBtn.Parent = row
                        MakeCorner(trackBtn, 9)

                        local knob = MakeFrame(trackBtn,
                            UDim2.fromOffset(12,12),
                            UDim2.fromOffset(default and 20 or 3, 3),
                            Theme.TextPrimary)
                        MakeCorner(knob, 6)

                        local value = default
                        local function updateUI()
                            Tween(trackBtn, {BackgroundColor3 = value and Theme.Accent or Theme.SliderBG}, 0.15)
                            Tween(knob, {Position = UDim2.fromOffset(value and 20 or 3, 3)}, 0.15)
                            Tween(lbl, {TextColor3 = value and Theme.TextPrimary or Theme.TextDim}, 0.15)
                        end

                        trackBtn.MouseButton1Click:Connect(function()
                            value = not value
                            updateUI()
                            callback(value)
                        end)

                        local Toggle = {Value = value}
                        function Toggle:SetValue(v)
                            value = v
                            Toggle.Value = v
                            updateUI()
                            callback(v)
                        end
                        return Toggle
                    end

                    -- ── Slider ───────────────────────────────────────────────
                    function Section:AddSlider(config)
                        config = config or {}
                        local label    = config.Text     or "Slider"
                        local min      = config.Min      or 0
                        local max      = config.Max      or 100
                        local default  = config.Default  or min
                        local suffix   = config.Suffix   or ""
                        local callback = config.Callback or function() end
                        local decimals = config.Decimals or 0

                        local row = MakeFrame(box, UDim2.new(1,0,0,36), nil, Theme.BGTertiary)

                        local topRow = MakeFrame(row, UDim2.new(1,0,0,16), nil, Theme.BGTertiary)
                        local lbl = MakeLabel(topRow, label, UDim2.new(1,-60,1,0), nil,
                            Theme.TextSecond, Enum.Font.Gotham, 12)
                        local valLbl = MakeLabel(topRow, tostring(default)..suffix,
                            UDim2.fromOffset(55,16), UDim2.new(1,-56,0,0),
                            Theme.TextDim, Enum.Font.GothamBold, 12)
                        valLbl.TextXAlignment = Enum.TextXAlignment.Right

                        local track = MakeFrame(row, UDim2.new(1,0,0,4), UDim2.new(0,0,0,24), Theme.SliderBG)
                        MakeCorner(track, 2)
                        local fill = MakeFrame(track, UDim2.new(0,0,1,0), nil, Theme.SliderFill)
                        fill.Name = "Fill"
                        MakeCorner(fill, 2)

                        local value = default
                        local function pct() return (value - min) / (max - min) end
                        local function updateUI()
                            Tween(fill, {Size = UDim2.new(pct(),0,1,0)}, 0.05)
                            local fmt = decimals > 0 and string.format("%."..decimals.."f", value) or tostring(math.floor(value))
                            valLbl.Text = fmt .. suffix
                        end
                        updateUI()

                        local sliderDragging = false
                        local function applyDrag(x)
                            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            local raw = min + (max - min) * rel
                            local scale = 10^decimals
                            value = math.round(raw * scale) / scale
                            updateUI()
                            callback(value)
                        end

                        local sliderBtn = Instance.new("TextButton")
                        sliderBtn.Size = UDim2.new(1,0,1,0)
                        sliderBtn.BackgroundTransparency = 1
                        sliderBtn.Text = ""
                        sliderBtn.ZIndex = 5
                        sliderBtn.Parent = track

                        sliderBtn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                               inp.UserInputType == Enum.UserInputType.Touch then
                                sliderDragging = true
                                applyDrag(inp.Position.X)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if not sliderDragging then return end
                            if inp.UserInputType == Enum.UserInputType.MouseMovement or
                               inp.UserInputType == Enum.UserInputType.Touch then
                                applyDrag(inp.Position.X)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
                               inp.UserInputType == Enum.UserInputType.Touch then
                                sliderDragging = false
                            end
                        end)

                        local Slider = {Value = value}
                        function Slider:SetValue(v)
                            value = math.clamp(v, min, max)
                            Slider.Value = value
                            updateUI()
                            callback(value)
                        end
                        return Slider
                    end

                    -- ── Dropdown ─────────────────────────────────────────────
                    function Section:AddDropdown(config)
                        config = config or {}
                        local label    = config.Text     or "Dropdown"
                        local options  = config.Options  or {}
                        local default  = config.Default  or (options[1] or "")
                        local callback = config.Callback or function() end

                        local row = MakeFrame(box, UDim2.new(1,0,0,44), nil, Theme.BGTertiary)
                        local lbl = MakeLabel(row, label,
                            UDim2.new(1,0,0,16), nil, Theme.TextSecond, Enum.Font.Gotham, 12)

                        local ddBtn = Instance.new("TextButton")
                        ddBtn.Size = UDim2.new(1,0,0,24)
                        ddBtn.Position = UDim2.fromOffset(0,18)
                        ddBtn.BackgroundColor3 = Theme.BGItem
                        ddBtn.Text = ""
                        ddBtn.BorderSizePixel = 0
                        ddBtn.Parent = row
                        MakeCorner(ddBtn, 4)

                        local selectedL = MakeLabel(ddBtn, default,
                            UDim2.new(1,-24,1,0), UDim2.fromOffset(8,0),
                            Theme.TextPrimary, Enum.Font.Gotham, 12)

                        local arrow = MakeLabel(ddBtn, "▾",
                            UDim2.fromOffset(16,16),
                            UDim2.new(1,-20,0,4),
                            Theme.TextDim, Enum.Font.Gotham, 12)
                        arrow.TextXAlignment = Enum.TextXAlignment.Center

                        local value = default
                        local isOpen = false
                        local dropList = nil

                        local function closeDropdown()
                            if dropList then dropList:Destroy(); dropList = nil end
                            isOpen = false
                            arrow.Text = "▾"
                        end

                        local function openDropdown()
                            if dropList then closeDropdown(); return end
                            isOpen = true
                            arrow.Text = "▴"

                            local listH = #options * 24 + 4
                            -- Open above the button
                            dropList = MakeFrame(row,
                                UDim2.new(1,0,0, listH),
                                UDim2.new(0,0,0, -(listH + 2)),
                                Theme.BGItem)
                            dropList.ZIndex = 10
                            MakeCorner(dropList, 4)
                            MakePadding(dropList, 2,2,2,2)
                            MakeListLayout(dropList, Enum.FillDirection.Vertical, 0)

                            for _, opt in ipairs(options) do
                                local optBtn = Instance.new("TextButton")
                                optBtn.Size = UDim2.new(1,0,0,24)
                                optBtn.BackgroundTransparency = 1
                                optBtn.Text = opt
                                optBtn.TextColor3 = opt == value and Theme.Accent or Theme.TextPrimary
                                optBtn.Font = Enum.Font.Gotham
                                optBtn.TextSize = 12
                                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                                optBtn.BorderSizePixel = 0
                                optBtn.ZIndex = 11
                                local op = MakePadding(optBtn,0,0,0,8)
                                optBtn.Parent = dropList

                                optBtn.MouseEnter:Connect(function()
                                    Tween(optBtn, {BackgroundColor3 = Theme.BGSecondary}, 0.1)
                                    optBtn.BackgroundTransparency = 0
                                    MakeCorner(optBtn, 4)
                                end)
                                optBtn.MouseLeave:Connect(function()
                                    optBtn.BackgroundTransparency = 1
                                end)
                                optBtn.MouseButton1Click:Connect(function()
                                    value = opt
                                    selectedL.Text = opt
                                    closeDropdown()
                                    callback(opt)
                                end)
                            end
                        end

                        ddBtn.MouseButton1Click:Connect(function()
                            if isOpen then closeDropdown() else openDropdown() end
                        end)

                        local Dropdown = {Value = value}
                        function Dropdown:SetValue(v)
                            value = v
                            selectedL.Text = v
                            Dropdown.Value = v
                            callback(v)
                        end
                        return Dropdown
                    end

                    -- ── KeyPicker ────────────────────────────────────────────
                    function Section:AddKeyPicker(config)
                        config = config or {}
                        local label    = config.Text     or "Keybind"
                        local default  = config.Default  or "None"
                        local callback = config.Callback or function() end
                        local linked   = config.Linked   or nil  -- linked Toggle object

                        local row = MakeFrame(box, UDim2.new(1,0,0,24), nil, Theme.BGTertiary)
                        local lbl = MakeLabel(row, label,
                            UDim2.new(1,-80,1,0), nil, Theme.TextSecond, Enum.Font.Gotham, 12)

                        local keyBtn = Instance.new("TextButton")
                        keyBtn.Size = UDim2.fromOffset(70,18)
                        keyBtn.Position = UDim2.new(1,-72,0.5,-9)
                        keyBtn.BackgroundColor3 = Theme.BGItem
                        keyBtn.Text = "Key: "..default
                        keyBtn.TextColor3 = Theme.Accent
                        keyBtn.Font = Enum.Font.Gotham
                        keyBtn.TextSize = 11
                        keyBtn.BorderSizePixel = 0
                        keyBtn.Parent = row
                        MakeCorner(keyBtn, 4)

                        local listening = false
                        local value = default
                        local boundKey = nil

                        -- Try to convert default string to KeyCode
                        pcall(function()
                            if default ~= "None" then
                                boundKey = Enum.KeyCode[default]
                            end
                        end)

                        keyBtn.MouseButton1Click:Connect(function()
                            listening = true
                            keyBtn.Text = "..."
                            keyBtn.TextColor3 = Theme.TextDim
                        end)

                        UserInputService.InputBegan:Connect(function(inp, gp)
                            if gp then return end
                            if listening then
                                if inp.UserInputType == Enum.UserInputType.Keyboard then
                                    listening = false
                                    value = inp.KeyCode.Name
                                    boundKey = inp.KeyCode
                                    keyBtn.Text = "Key: "..value
                                    keyBtn.TextColor3 = Theme.Accent
                                    callback(inp.KeyCode)
                                end
                                return
                            end
                            -- Toggle linked feature when key pressed
                            if boundKey and inp.KeyCode == boundKey then
                                if linked and linked.SetValue then
                                    linked:SetValue(not linked.Value)
                                end
                            end
                        end)

                        local KP = {Value = value}
                        function KP:SetValue(v)
                            value = tostring(v)
                            keyBtn.Text = "Key: "..value
                            KP.Value = value
                            callback(v)
                        end
                        return KP
                    end

                    -- ── Button ───────────────────────────────────────────────
                    function Section:AddButton(config)
                        config = config or {}
                        local label    = config.Text     or "Button"
                        local callback = config.Callback or function() end

                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1,0,0,28)
                        btn.BackgroundColor3 = Theme.BGItem
                        btn.Text = label
                        btn.TextColor3 = Theme.TextPrimary
                        btn.Font = Enum.Font.GothamBold
                        btn.TextSize = 12
                        btn.BorderSizePixel = 0
                        btn.Parent = box
                        MakeCorner(btn, 4)

                        btn.MouseEnter:Connect(function()
                            Tween(btn, {BackgroundColor3 = Theme.Accent}, 0.1)
                        end)
                        btn.MouseLeave:Connect(function()
                            Tween(btn, {BackgroundColor3 = Theme.BGItem}, 0.1)
                        end)
                        btn.MouseButton1Click:Connect(function()
                            task.spawn(callback)
                        end)
                        return btn
                    end

                    -- ── Label ────────────────────────────────────────────────
                    function Section:AddLabel(text)
                        return MakeLabel(box, text or "",
                            UDim2.new(1,0,0,14), nil, Theme.TextDim, Enum.Font.Gotham, 11)
                    end

                    -- ── TextBox ───────────────────────────────────────────────
                    function Section:AddTextBox(config)
                        config = config or {}
                        local label    = config.Text     or "TextBox"
                        local default  = config.Default  or ""
                        local placeholder = config.Placeholder or "Type here..."
                        local callback = config.Callback or function() end

                        local row = MakeFrame(box, UDim2.new(1,0,0,44), nil, Theme.BGTertiary)
                        local lbl = MakeLabel(row, label,
                            UDim2.new(1,0,0,16), nil, Theme.TextSecond, Enum.Font.Gotham, 12)

                        local tbFrame = MakeFrame(row, UDim2.new(1,0,0,22), UDim2.fromOffset(0,18), Theme.BGItem)
                        MakeCorner(tbFrame, 4)
                        MakePadding(tbFrame, 0,6,0,6)

                        local tb = Instance.new("TextBox")
                        tb.Size = UDim2.new(1,0,1,0)
                        tb.BackgroundTransparency = 1
                        tb.Text = default
                        tb.PlaceholderText = placeholder
                        tb.PlaceholderColor3 = Theme.TextDim
                        tb.TextColor3 = Theme.TextPrimary
                        tb.Font = Enum.Font.Gotham
                        tb.TextSize = 12
                        tb.TextXAlignment = Enum.TextXAlignment.Left
                        tb.BorderSizePixel = 0
                        tb.ClearTextOnFocus = false
                        tb.Parent = tbFrame

                        tb.FocusLost:Connect(function(enter)
                            callback(tb.Text)
                        end)
                        tb.Focused:Connect(function()
                            Tween(tbFrame, {BackgroundColor3 = Theme.BGSecondary}, 0.1)
                        end)
                        tb.FocusLost:Connect(function()
                            Tween(tbFrame, {BackgroundColor3 = Theme.BGItem}, 0.1)
                        end)

                        local TB = {Value = default}
                        function TB:SetValue(v)
                            tb.Text = tostring(v)
                            TB.Value = v
                            callback(v)
                        end
                        return TB
                    end

                    -- ── ColorPicker ───────────────────────────────────────────
                    function Section:AddColorPicker(config)
                        config = config or {}
                        local label    = config.Text     or "Color"
                        local default  = config.Default  or Color3.fromRGB(255,255,255)
                        local callback = config.Callback or function() end

                        local row = MakeFrame(box, UDim2.new(1,0,0,24), nil, Theme.BGTertiary)
                        local lbl = MakeLabel(row, label,
                            UDim2.new(1,-44,1,0), nil, Theme.TextSecond, Enum.Font.Gotham, 12)

                        local swatchBtn = Instance.new("TextButton")
                        swatchBtn.Size = UDim2.fromOffset(30, 16)
                        swatchBtn.Position = UDim2.new(1,-32,0.5,-8)
                        swatchBtn.BackgroundColor3 = default
                        swatchBtn.Text = ""
                        swatchBtn.BorderSizePixel = 0
                        swatchBtn.Parent = row
                        MakeCorner(swatchBtn, 3)

                        local value = default
                        local isOpen = false
                        local picker = nil

                        local function closePicker()
                            if picker then picker:Destroy(); picker = nil end
                            isOpen = false
                        end

                        local function openPicker()
                            if picker then closePicker(); return end
                            isOpen = true

                            -- Open above the swatch — use ScreenGui overlay for correct Z
                            picker = Instance.new("Frame")
                            picker.Size = UDim2.fromOffset(230, 230)
                            picker.BackgroundColor3 = Theme.BGItem
                            picker.BorderSizePixel = 0
                            picker.ZIndex = 50
                            MakeCorner(picker, 6)

                            -- Position above the swatch in screen coords
                            local absPos = swatchBtn.AbsolutePosition
                            picker.Position = UDim2.fromOffset(
                                math.clamp(absPos.X - 160, 10, 999),
                                absPos.Y - 240)
                            picker.Parent = sg  -- parent to ScreenGui for top Z

                            MakePadding(picker, 8,8,8,8)

                            -- Saturation/Brightness square
                            local sbField = Instance.new("Frame")
                            sbField.Size = UDim2.fromOffset(160, 160)
                            sbField.Position = UDim2.fromOffset(0, 0)
                            sbField.BackgroundColor3 = Color3.fromHSV(h_val, 1, 1)
                            sbField.BorderSizePixel = 0
                            sbField.ZIndex = 51
                            sbField.Parent = picker
                            MakeCorner(sbField, 4)

                            -- White left→right gradient (saturation)
                            local whiteGrad = Instance.new("Frame")
                            whiteGrad.Size = UDim2.new(1,0,1,0)
                            whiteGrad.BackgroundColor3 = Color3.fromRGB(255,255,255)
                            whiteGrad.BorderSizePixel = 0
                            whiteGrad.ZIndex = 52
                            whiteGrad.Parent = sbField
                            MakeCorner(whiteGrad, 4)
                            local wg = Instance.new("UIGradient")
                            wg.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
                            wg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
                            wg.Parent = whiteGrad

                            -- Black bottom→top gradient (brightness)
                            local blackGrad = Instance.new("Frame")
                            blackGrad.Size = UDim2.new(1,0,1,0)
                            blackGrad.BackgroundColor3 = Color3.fromRGB(0,0,0)
                            blackGrad.BorderSizePixel = 0
                            blackGrad.ZIndex = 53
                            blackGrad.Parent = sbField
                            MakeCorner(blackGrad, 4)
                            local bg2 = Instance.new("UIGradient")
                            bg2.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
                            bg2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
                            bg2.Rotation = 90
                            bg2.Parent = blackGrad

                            -- Make sbField clickable
                            local sbClick = Instance.new("TextButton")
                            sbClick.Size = UDim2.new(1,0,1,0)
                            sbClick.BackgroundTransparency = 1
                            sbClick.Text = ""
                            sbClick.ZIndex = 55
                            sbClick.Parent = sbField

                            -- Saturation cursor dot
                            local h_val, s_val, v_val = default:ToHSV()
                            local sbCursor = MakeFrame(sbField, UDim2.fromOffset(10,10),
                                UDim2.fromScale(s_val, 1-v_val), Theme.TextPrimary)
                            sbCursor.AnchorPoint = Vector2.new(0.5,0.5)
                            MakeCorner(sbCursor, 5)
                            sbCursor.ZIndex = 53
                            local sbInner = MakeFrame(sbCursor, UDim2.fromOffset(4,4),
                                UDim2.new(0.5,-2,0.5,-2), Theme.BGItem)
                            MakeCorner(sbInner, 2)
                            sbInner.ZIndex = 54

                            -- Hue bar (right side)
                            local hueBar = Instance.new("ImageButton")
                            hueBar.Size = UDim2.fromOffset(12, 160)
                            hueBar.Position = UDim2.fromOffset(172, 0)
                            hueBar.Image = "rbxassetid://8180989234"
                            hueBar.ScaleType = Enum.ScaleType.Crop
                            hueBar.BorderSizePixel = 0
                            hueBar.AutoButtonColor = false
                            hueBar.ZIndex = 51
                            hueBar.Parent = picker
                            MakeCorner(hueBar, 3)

                            local hueCursor = MakeFrame(hueBar, UDim2.new(1,4,0,3),
                                UDim2.new(-0.2, 0, h_val, -1), Theme.TextPrimary)
                            hueCursor.ZIndex = 52
                            MakeCorner(hueCursor, 1)

                            -- Hex input at bottom
                            local hexFrame = MakeFrame(picker, UDim2.fromOffset(214,22),
                                UDim2.fromOffset(0,170), Theme.BGSecondary)
                            MakeCorner(hexFrame, 4)
                            local hexBox = Instance.new("TextBox")
                            hexBox.Size = UDim2.new(1,-8,1,0)
                            hexBox.Position = UDim2.fromOffset(6,0)
                            hexBox.BackgroundTransparency = 1
                            hexBox.Text = "#"..string.upper(default:ToHex()).."FF"
                            hexBox.TextColor3 = Theme.TextSecond
                            hexBox.Font = Enum.Font.GothamBold
                            hexBox.TextSize = 12
                            hexBox.TextXAlignment = Enum.TextXAlignment.Left
                            hexBox.BorderSizePixel = 0
                            hexBox.ClearTextOnFocus = false
                            hexBox.ZIndex = 52
                            hexBox.Parent = hexFrame

                            local function applyColor()
                                value = Color3.fromHSV(h_val, s_val, v_val)
                                swatchBtn.BackgroundColor3 = value
                                sbField.BackgroundColor3 = Color3.fromHSV(h_val, 1, 1)
                                sbCursor.Position = UDim2.fromScale(
                                    math.clamp(s_val, 0.01, 0.99),
                                    math.clamp(1-v_val, 0.01, 0.99))
                                hueCursor.Position = UDim2.new(-0.2, 0, math.clamp(h_val, 0, 0.98), -1)
                                hexBox.Text = "#"..string.upper(value:ToHex()).."FF"
                                callback(value)
                            end
                            applyColor()

                            local dragSB, dragHue = false, false

                            sbClick.InputBegan:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                                    dragSB = true
                                    local rel = (Vector2.new(inp.Position.X, inp.Position.Y) - sbField.AbsolutePosition) / sbField.AbsoluteSize
                                    s_val = math.clamp(rel.X,0,1); v_val = math.clamp(1-rel.Y,0,1); applyColor()
                                end
                            end)
                            hueBar.InputBegan:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                                    dragHue = true
                                    local rel = (inp.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y
                                    h_val = math.clamp(rel,0,1); applyColor()
                                end
                            end)
                            UserInputService.InputChanged:Connect(function(inp)
                                if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                                if dragSB then
                                    local rel = (Vector2.new(inp.Position.X, inp.Position.Y) - sbField.AbsolutePosition) / sbField.AbsoluteSize
                                    s_val = math.clamp(rel.X,0,1); v_val = math.clamp(1-rel.Y,0,1); applyColor()
                                elseif dragHue then
                                    local rel = (inp.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y
                                    h_val = math.clamp(rel,0,1); applyColor()
                                end
                            end)
                            UserInputService.InputEnded:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                                    dragSB = false; dragHue = false
                                end
                            end)

                            hexBox.FocusLost:Connect(function()
                                pcall(function()
                                    local hex = hexBox.Text:gsub("#",""):sub(1,6)
                                    local col = Color3.fromHex(hex)
                                    h_val, s_val, v_val = col:ToHSV()
                                    applyColor()
                                end)
                            end)

                            -- Close when clicking outside
                            local closConn
                            closConn = UserInputService.InputBegan:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                    local mp = Vector2.new(inp.Position.X, inp.Position.Y)
                                    local ap = picker.AbsolutePosition
                                    local as = picker.AbsoluteSize
                                    if mp.X < ap.X or mp.X > ap.X+as.X or mp.Y < ap.Y or mp.Y > ap.Y+as.Y then
                                        closConn:Disconnect()
                                        task.defer(closePicker)
                                    end
                                end
                            end)
                        end

                        swatchBtn.MouseButton1Click:Connect(function()
                            if isOpen then closePicker() else openPicker() end
                        end)

                        local CP = {Value = value}
                        function CP:SetValue(v)
                            value = v
                            swatchBtn.BackgroundColor3 = v
                            CP.Value = v
                            callback(v)
                        end
                        return CP
                    end

                    return Section
                end -- AddSection

                return SubTab
            end -- AddSubTab

            return Page
        end -- AddPage

        return Tab
    end -- AddTab

    -- Notify system
    function Window:Notify(config)
        config = config or {}
        local msg      = config.Title   or config.Text or "Notification"
        local lifetime = config.Lifetime or 3

        local notifHolder = Window._sg:FindFirstChild("NotifHolder")
        if not notifHolder then
            notifHolder = MakeFrame(Window._sg,
                UDim2.fromOffset(260,500),
                UDim2.new(1,-270,1,-20),
                Theme.BG)
            notifHolder.Name = "NotifHolder"
            notifHolder.BackgroundTransparency = 1
            notifHolder.AnchorPoint = Vector2.new(0,1)
            notifHolder.Position = UDim2.new(1,-270,1,-10)
            MakeListLayout(notifHolder, Enum.FillDirection.Vertical, 6,
                Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
        end

        local nFrame = MakeFrame(notifHolder,
            UDim2.fromOffset(240,0), nil, Theme.BGSecondary)
        nFrame.AutomaticSize = Enum.AutomaticSize.Y
        MakeCorner(nFrame, 6)
        MakePadding(nFrame, 10,12,10,12)

        local accent = MakeFrame(nFrame, UDim2.fromOffset(3,0), UDim2.fromOffset(-12,-10), Theme.Accent)
        accent.AnchorPoint = Vector2.new(0,0)
        accent.AutomaticSize = Enum.AutomaticSize.Y
        MakeCorner(accent, 2)

        local msgL = MakeLabel(nFrame, msg,
            UDim2.new(1,0,0,0), nil,
            Theme.TextPrimary, Enum.Font.Gotham, 12)
        msgL.AutomaticSize = Enum.AutomaticSize.Y
        msgL.TextWrapped = true

        -- Bottom progress bar
        local bar = MakeFrame(nFrame, UDim2.new(1,0,0,2), nil, Theme.Accent)
        bar.AnchorPoint = Vector2.new(0,0)
        Tween(bar, {Size = UDim2.new(0,0,0,2)}, lifetime, Enum.EasingStyle.Linear)

        nFrame.BackgroundTransparency = 1
        MakeCorner(nFrame, 6)
        Tween(nFrame, {BackgroundTransparency = 0}, 0.2)

        task.delay(lifetime, function()
            Tween(nFrame, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function()
                nFrame:Destroy()
            end)
        end)
    end

    -- Menu keybind (RightShift by default to show/hide)
    local menuKeybind = Enum.KeyCode.RightShift
    
    -- Use a separate connection that ignores gameProcessed for menu toggle
    UserInputService.InputBegan:Connect(function(inp)
        -- Menu toggle — always fires regardless of gameProcessed
        if inp.KeyCode == menuKeybind then
            Window._main.Visible = not Window._main.Visible
        end
    end)

    function Window:SetMenuKey(key)
        if typeof(key) == "EnumItem" then
            menuKeybind = key
        elseif typeof(key) == "string" then
            pcall(function() menuKeybind = Enum.KeyCode[key] end)
        end
    end

    -- ─────────────────────────────────────────────────────────────
    -- ACCENT COLOR CHANGER
    -- ─────────────────────────────────────────────────────────────
    function Window:SetAccent(color)
        Theme.Accent = color
        Theme.SliderFill = color
        -- Recursively update all descendants with accent color
        local function updateDescendants(parent)
            for _, obj in ipairs(parent:GetDescendants()) do
                -- Update slider fills
                if obj.Name == "Fill" and obj:IsA("Frame") then
                    obj.BackgroundColor3 = color
                end
                -- Update tab indicators
                if obj.Name == "Indicator" and obj:IsA("Frame") then
                    obj.BackgroundColor3 = color
                end
                -- Update sub-tab underlines
                if obj.Name == "Underline" and obj:IsA("Frame") then
                    obj.BackgroundColor3 = color
                end
                -- Update scrollbar
                if obj:IsA("ScrollingFrame") then
                    obj.ScrollBarImageColor3 = color
                end
                -- Update sidebar accent bars
                if obj.Name == "SideAccent" and obj:IsA("Frame") then
                    obj.BackgroundColor3 = color
                end
            end
        end
        pcall(function() updateDescendants(Window._main) end)
        -- Update tab indicators explicitly
        for _, t in ipairs(Window._tabs) do
            if t._indicator then
                t._indicator.BackgroundColor3 = color
            end
        end
    end

    -- ─────────────────────────────────────────────────────────────
    -- CONFIG SYSTEM (uses writefile/readfile if available)
    -- ─────────────────────────────────────────────────────────────
    local _configFolder = "cipher_configs"

    local function ensureFolder()
        pcall(function()
            if not isfolder(_configFolder) then
                makefolder(_configFolder)
            end
        end)
    end

    function Window:GetConfigs()
        local list = {}
        pcall(function()
            ensureFolder()
            for _, f in ipairs(listfiles(_configFolder)) do
                local name = f:match("([^/\\]+)%.json$") or f:match("([^/\\]+)%.cfg$")
                if name then table.insert(list, name) end
            end
        end)
        return list
    end

    function Window:SaveConfig(name)
        if not name or name == "" then return false, "No name" end
        pcall(function()
            ensureFolder()
            local data = {}
            -- Collect all item values
            for tabName, tab in pairs(Window._tabs) do
                for _, page in ipairs(tab._pages) do
                    for _, sub in ipairs(page._subTabs) do
                        for _, sec in ipairs(sub._sections or {}) do
                            for _, item in ipairs(sec._items or {}) do
                                if item.Flag and item.Value ~= nil then
                                    data[item.Flag] = item.Value
                                end
                            end
                        end
                    end
                end
            end
            local json = game:GetService("HttpService"):JSONEncode(data)
            writefile(_configFolder.."/"..name..".json", json)
        end)
        return true
    end

    function Window:LoadConfig(name)
        local ok = false
        pcall(function()
            ensureFolder()
            local raw = readfile(_configFolder.."/"..name..".json")
            local data = game:GetService("HttpService"):JSONDecode(raw)
            -- Apply values (scripts register items with Flags)
            for flag, val in pairs(data) do
                for _, tab in ipairs(Window._tabs) do
                    for _, page in ipairs(tab._pages) do
                        for _, sub in ipairs(page._subTabs) do
                            for _, sec in ipairs(sub._sections or {}) do
                                for _, item in ipairs(sec._items or {}) do
                                    if item.Flag == flag and item.SetValue then
                                        pcall(function() item:SetValue(val) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            ok = true
        end)
        return ok
    end

    function Window:DeleteConfig(name)
        pcall(function()
            delfile(_configFolder.."/"..name..".json")
        end)
    end

    return Window
end -- CreateWindow

return PrimordialUI
