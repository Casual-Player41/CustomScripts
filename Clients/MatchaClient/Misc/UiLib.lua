local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


--#region So far I changed what I needed ^^
local MatchaUI = {}



MatchaUI.__index = MatchaUI


local AccentColor = Color3.fromHex("#39FF14")  -- Lime Green

local Theme = {
  Background = Color3.fromHex("#0A0A0A"),
  TopBar = Color3.fromHex("#111111"),
  LeftBar = Color3.fromHex("#141414"),
  CategoryActive = AccentColor,
  CategoryHover = Color3.fromHex("#1F1F1F"),
  CategoryText = Color3.fromHex("#FFFFFF"),
  ContentBg = Color3.fromHex("#0A0A0A"),
  ElementBg = Color3.fromHex("#141414"),
  ElementBorder = Color3.fromHex("#2A2A2A"),
  AccentOn = AccentColor,
  AccentOff = Color3.fromHex("#2A2A2A"),
  TextPrimary = Color3.fromHex("#FFFFFF"),
  TextSecondary = Color3.fromHex("#AAAAAA"),
  TextDisabled = Color3.fromHex("#555555"),
  SliderTrack = Color3.fromHex("#2A2A2A"),
  SliderFill = AccentColor,
  SliderKnob = Color3.fromHex("#FFFFFF"),
  DropdownBg = Color3.fromHex("#111111"),
  DropdownItem = Color3.fromHex("#0A0A0A"),
  DropdownHover = Color3.fromHex("#1F1F1F"),
  InputBg = Color3.fromHex("#0D0D0D"),
  InputBorder = AccentColor,
  TooltipBg = Color3.fromHex("#050505"),
  NotifBg = Color3.fromHex("#111111"),
  NotifBorder = AccentColor,

  ScrollBar = Color3.fromHex("#1A1A1A"),
  ScrollThumb = AccentColor,
  TitleText = Color3.fromHex("#FFFFFF"),
  CloseBtn = Color3.fromHex("#CC2200"),
  MinimizeBtn = Color3.fromHex("#444444"),
  SectionHeader = Color3.fromHex("#1A1A1A"),
  SectionText = AccentColor,
}

local _focusedInput = nil


local _objects  = {}
local _windows  = {}
local _notifs   = {}
local _tooltips = {}


MatchaUI.Choosing = false

local function newDraw(type)
  local obj = Drawing.new(type)
  table.insert(_objects, obj)
  return obj
end

local function createRectangle(x, y, w, h, color, zIndex, filled, thickness)
  local r = newDraw("Square")
  r.Position     = Vector2.new(x, y)
  r.Size         = Vector2.new(w, h)
  r.Color        = color or Theme.ElementBg
  r.ZIndex       = zIndex or 10
  r.Filled       = (filled ~= false)
  r.Thickness    = thickness or 1
  r.Transparency = 1
  r.Visible      = true
  return r
end

local _currentFont = Drawing.Fonts.Monospace
local _textObjects = {}

local function createText(text, x, y, size, color, zIndex, centered, outline)
  local t = newDraw("Text")
  t.Text         = tostring(text)
  t.Position     = Vector2.new(x, y)
  t.Size         = size or 14
  t.Color        = color or Theme.TextPrimary
  t.ZIndex       = zIndex or 11
  t.Center       = centered or false
  t.Outline      = (outline ~= false)
  t.Font         = _currentFont
  t.Transparency = 1
  t.Visible      = true
  table.insert(_textObjects, t)
  return t
end

local function isInBoxBounds(mx, my, x, y, w, h)
  return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function _setGroupVisible(group, state)
  for _, obj in ipairs(group) do
    if obj and obj.Remove then
      pcall(function()
        obj.Visible = state
      end)
    end
  end
end


local Mouse = LocalPlayer:GetMouse()
local _lastMouse1  = false
local _mouseJustDown  = false
local _mouseJustUp    = false


local KeyNames = {
  [8] = "Backspace", [9] = "Tab", [13] = "Enter", [16] = "Shift", [17] = "Ctrl", [18] = "Alt", [20] = "CapsLock", [27] = "Esc",
  [32] = "Space", [33] = "PageUp", [34] = "PageDown", [35] = "End", [36] = "Home", [37] = "Left", [38] = "Up", [39] = "Right", [40] = "Down", [45] = "Insert", [46] = "Delete",
  [48] = "0", [49] = "1", [50] = "2", [51] = "3", [52] = "4", [53] = "5",
  [54] = "6", [55] = "7", [56] = "8", [57] = "9",
  [65] = "A", [66] = "B", [67] = "C", [68] = "D", [69] = "E", [70] = "F",[71] = "G", [72] = "H", [73] = "I", [74] = "J", [75] = "K", [76] = "L", [77] = "M", [78] = "N", [79] = "O", [80] = "P", [81] = "Q", [82] = "R", [83] = "S", [84] = "T", [85] = "U", [86] = "V", [87] = "W", [88] = "X", [89] = "Y", [90] = "Z",
  [112] = "F1", [113] = "F2", [114] = "F3", [115] = "F4", [116] = "F5", [117] = "F6", [118] = "F7", [119] = "F8", [120] = "F9", [121] = "F10", [122] = "F11", [123] = "F12",
}


local _MouseVKCodes = {
  [1] = true, [2] = true, [4] = true, [5] = true, [6] = true,
}

local VALID_KEYBIND_KEYS = {
  [8] = true, [9] = true, [13] = true, [16] = true, [17] = true, [18] = true, [20] = true, [27] = true,
  [32] = true, [33] = true, [34] = true, [35] = true, [36] = true, [37] = true, [38] = true, [39] = true, [40] = true, [45] = true, [46] = true,
  [48] = true, [49] = true, [50] = true, [51] = true, [52] = true, [53] = true, [54] = true, [55] = true, [56] = true, [57] = true,
  [65] = true, [66] = true, [67] = true, [68] = true, [69] = true, [70] = true, [71] = true, [72] = true, [73] = true, [74] = true, [75] = true, [76] = true, [77] = true, [78] = true, [79] = true, [80] = true, [81] = true, [82] = true, [83] = true, [84] = true, [85] = true, [86] = true, [87] = true, [88] = true, [89] = true, [90] = true,
  [112] = true, [113] = true, [114] = true, [115] = true, [116] = true, [117] = true, [118] = true, [119] = true, [120] = true, [121] = true, [122] = true, [123] = true,
}


-- ACCENT COLOR REGISTRY; -- Must be declared before CreateWindow so element builder closures can call trackAccent(). SetAccentColor() iterates this table to repaint every accent-colored Drawing object live.
local _accentObjects = {}  -- array of Drawing objects whose .Color = AccentColor

local function trackAccent(obj)
	table.insert(_accentObjects, obj)
end


-- Theme color registery: Maps each Theme key to a list of Drawing objects that use it.
local _themeObjects = {}  -- { [themeKey] = { obj, ... } }

local function trackTheme(key, obj)
  if not _themeObjects[key] then
    _themeObjects[key] = {}
  end
  table.insert(_themeObjects[key], obj)
end

-- Window constructor: Returns a Window object. All elements are added to a window.
-- Layout: TopBar  (title, minimize, close); LeftBar (categories); Content (element panels per category)

local TOPBAR_H    = 28
local LEFTBAR_W   = 120
local CONTENT_PAD = 8
local CAT_H       = 28
local ELEM_H      = 32
local ELEM_PAD    = 6

function MatchaUI.CreateWindow(opts)
  opts = opts or {}
  local wx      = opts.X       or 100
  local wy      = opts.Y       or 80
  local ww      = opts.Width   or 500
  local wh      = opts.Height  or 380
  local title   = opts.Title   or "MatchaUI"
  local baseZ   = opts.ZIndex  or 100

  local win = {
    X = wx, Y = wy, W = ww, H = wh,
    BaseZ      = baseZ,
    Visible    = true,
    Minimized  = false,
    Dragging   = false,
    DragOffX   = 0, DragOffY = 0,
    Categories = {},
    ActiveCat  = nil,
    _draws     = {},
    _elements  = {},
  }

  local function draw(d) table.insert(win._draws, d); return d end

  -- Shadow / border
  local shadow = draw(createRectangle(wx-2, wy-2, ww+4, wh+4, Color3.fromHex("#000000"), baseZ, true))
  shadow.Transparency = 0.6

  -- Main background
  local bg = draw(createRectangle(wx, wy, ww, wh, Theme.Background, baseZ+1, true))
  trackTheme("Background", bg)

  -- TopBar
  local topBar = draw(createRectangle(wx, wy, ww, TOPBAR_H, Theme.TopBar, baseZ+2, true))
  trackTheme("TopBar", topBar)

  -- Title text
  local titleTxt = draw(createText(title, wx + 10, wy + 7, 14, Theme.TitleText, baseZ+3, false, true))
  trackTheme("TitleText", titleTxt)

  -- Minimize button
  local minBtn  = draw(createRectangle(wx + ww - 52, wy + 6, 18, 16, Theme.MinimizeBtn, baseZ+3, true))
  trackTheme("MinimizeBtn", minBtn)
  local minTxt  = draw(createText("-", wx + ww - 52 + 6, wy + 7, 13, Color3.fromHex("#FFFFFF"), baseZ+4, false, false))

  -- Close button
  local closeBtn  = draw(createRectangle(wx + ww - 26, wy + 6, 18, 16, Theme.CloseBtn, baseZ+3, true))
  trackTheme("CloseBtn", closeBtn)
  local closeTxt  = draw(createText("X", wx + ww - 26 + 5, wy + 7, 12, Color3.fromHex("#FFFFFF"), baseZ+4, false, false))

  -- LeftBar
  local leftBar = draw(createRectangle(wx, wy + TOPBAR_H, LEFTBAR_W, wh - TOPBAR_H, Theme.LeftBar, baseZ+2, true))
  trackTheme("LeftBar", leftBar)

  -- Content area background
  local contentBg = draw(createRectangle(wx + LEFTBAR_W, wy + TOPBAR_H, ww - LEFTBAR_W, wh - TOPBAR_H, Theme.ContentBg, baseZ+2, true))
  trackTheme("ContentBg", contentBg)


  local function reposition(nx, ny)
    local dx, dy = nx - win.X, ny - win.Y
    win.X, win.Y = nx, ny

    shadow.Position    = Vector2.new(nx-2, ny-2)
    bg.Position        = Vector2.new(nx, ny)
    topBar.Position    = Vector2.new(nx, ny)
    titleTxt.Position  = Vector2.new(nx+10, ny+7)
    minBtn.Position    = Vector2.new(nx+ww-52, ny+6)
    minTxt.Position    = Vector2.new(nx+ww-52+6, ny+7)
    closeBtn.Position  = Vector2.new(nx+ww-26, ny+6)
    closeTxt.Position  = Vector2.new(nx+ww-26+5, ny+7)
    leftBar.Position   = Vector2.new(nx, ny+TOPBAR_H)
    contentBg.Position = Vector2.new(nx+LEFTBAR_W, ny+TOPBAR_H)

    -- Shift category labels and content
    for _, cat in ipairs(win.Categories) do
      cat._label.Position = cat._label.Position + Vector2.new(dx, dy)
      cat._bg.Position    = cat._bg.Position    + Vector2.new(dx, dy)
      for _, elem in ipairs(cat._elemObjs) do
        for _, obj in ipairs(elem) do
          pcall(function() obj.Position = obj.Position + Vector2.new(dx, dy) end)
        end
      end
    end
    -- Update element descriptor position fields used for hit-testing
    for _, elem in ipairs(win._elements) do
      if elem._x then elem._x = elem._x + dx end
      if elem._y then elem._y = elem._y + dy end
      -- Toggle track
      if elem._tx then elem._tx = elem._tx + dx end
      if elem._ty then elem._ty = elem._ty + dy end
      -- Slider track
      if elem._trackX then elem._trackX = elem._trackX + dx end
      if elem._trackY then elem._trackY = elem._trackY + dy end
      -- ValueLabel stable anchor
      if elem._valRightEdge then elem._valRightEdge = elem._valRightEdge + dx end
      -- Dropdown items
      if elem._itemObjs then
        for _, item in ipairs(elem._itemObjs) do
          if item._x then item._x = item._x + dx end
          if item._y then item._y = item._y + dy end
        end
      end
      -- ColorPicker panel objects (shift header + all panel draw objects)
      if elem._swatches then
        for _, sw in ipairs(elem._swatches) do
          if sw._x then sw._x = sw._x + dx end
          if sw._y then sw._y = sw._y + dy end
        end
      end
      -- ColorPicker: update all hit-test coordinates for header and panel
      if elem.Type == "ColorPicker" then
        if elem._headerX then elem._headerX = elem._headerX + dx end
        if elem._headerY then elem._headerY = elem._headerY + dy end
        if elem._arrowX  then elem._arrowX  = elem._arrowX  + dx end
        if elem._arrowY  then elem._arrowY  = elem._arrowY  + dy end
        -- Panel floats to the right of the window; shift with the window
        if elem._panelX  then elem._panelX  = elem._panelX  + dx end
        if elem._panelY  then elem._panelY  = elem._panelY  + dy end
        -- Palette swatches hit-test coords
        for _, sw in ipairs(elem._paletteSwatch or {}) do
          sw._x = sw._x + dx
          sw._y = sw._y + dy
        end
        -- Stepper/slider buttons hit-test coords
        for _, btn in ipairs(elem._btnObjs or {}) do
          btn._x = btn._x + dx
          btn._y = btn._y + dy
          if btn._trackX then btn._trackX = btn._trackX + dx end
          if btn._knobY  then btn._knobY  = btn._knobY  + dy end
        end
        -- Also shift channelSliders internal track coords
        local cs2 = elem._channelSliders or {}
        for _, s2 in pairs(cs2) do
          if s2._trackX then s2._trackX = s2._trackX + dx end
          if s2._knobY  then s2._knobY  = s2._knobY  + dy end
        end
      end
      -- ScrollFrame scrollbar X anchor
      if elem._sbX then elem._sbX = elem._sbX + dx end
    end
  end

  local function setWinVisible(state)
    win.Visible = state
    for _, d in ipairs(win._draws) do
      pcall(function() d.Visible = state end)
    end
    -- When becoming visible, show ONLY the active category's elements.
    -- All other categories must stay hidden.
    for _, cat in ipairs(win.Categories) do
      local showCat = state and (win.ActiveCat == cat)
      for _, elem in ipairs(cat._elemObjs) do
        for _, obj in ipairs(elem) do
          pcall(function() obj.Visible = showCat end)
        end
      end
      -- On show, restore correct per-element sub-object states for active cat
      if showCat then
        for _, elem in ipairs(win._elements) do
          if elem._cat ~= cat then continue end
          if elem.Type == "Checkbox" and elem._check then
            elem._check.Visible = elem.State
          end
          if elem.Type == "TextInput" and elem._cursor then
            elem._cursor.Visible = false
          end
          if elem.Type == "Dropdown" then
            elem._isOpen = false
            elem._arrow.Text = "v"
            for _, item in ipairs(elem._itemObjs) do
              item._bg.Visible  = false
              item._txt.Visible = false
            end
          end
          if elem.Type == "ColorPicker" then
            elem._cpOpen = false
            elem._arrowTxt.Text = "v"
            elem._panelBg.Visible = false
            for _, r in ipairs(elem._hueRects) do r.Visible = false end
            elem._hueCursor.Visible = false
            for _, sv in ipairs(elem._svRects) do sv._r.Visible = false end
            elem._svCursor.Visible = false
            elem._panelBorder.Visible = false
            local cs = elem._channelSliders or {}
            for _, ch in ipairs({"R","G","B"}) do 
              local s=cs[ch] 
              if s then
                s._lbl.Visible = false; s._val.Visible = false
                s._bg.Visible = false; s._fill.Visible=false
                if s._knob then 
                  s._knob.Visible = false 
              end
            end 
          end

            elem._hexLabel.Visible = false
            if elem._prevPatch then elem._prevPatch.Visible = false end
            for _, sw in ipairs(elem._paletteSwatch or {}) do pcall(function() sw._r.Visible = false end) 
            end
          end
        end
      end
    end
    -- Clear focused input on hide
    if not state and _focusedInput then
      _focusedInput.Focused = false
      if _focusedInput._cursor then _focusedInput._cursor.Visible = false end
      setrobloxinput(true)  -- restore Roblox input when UI hides
      _focusedInput = nil
    end
    -- Close any open dropdowns and reset Choosing on hide
    if not state then
      MatchaUI.Choosing = false
      for _, w in ipairs(_windows) do
        for _, elem in ipairs(w._elements) do
          if elem.Type == "Dropdown" and elem._isOpen then
            elem._isOpen = false
            elem._arrow.Text = "v"
            for _, item in ipairs(elem._itemObjs) do
              item._bg.Visible  = false
              item._txt.Visible = false
            end
          end
        end
      end
    end
  end

  local function minimize()
    win.Minimized = not win.Minimized
    local showContent = not win.Minimized
    bg.Size         = showContent and Vector2.new(ww, wh) or Vector2.new(ww, TOPBAR_H)
    shadow.Size     = showContent and Vector2.new(ww+4, wh+4) or Vector2.new(ww+4, TOPBAR_H+4)
    leftBar.Visible     = showContent
    contentBg.Visible   = showContent
    for _, cat in ipairs(win.Categories) do
      cat._label.Visible = showContent
      cat._bg.Visible    = showContent
      if win.ActiveCat == cat then
        for _, elem in ipairs(cat._elemObjs) do
          for _, obj in ipairs(elem) do
            pcall(function() obj.Visible = showContent end)
          end
        end
        -- On un-minimize, restore correct per-element sub-object states
        if showContent then
          for _, elem in ipairs(win._elements) do
            if elem._cat ~= cat then continue end
            if elem.Type == "Checkbox" and elem._check then
              elem._check.Visible = elem.State
            end
            if (elem.Type == "TextInput") and elem._cursor then
              elem._cursor.Visible = false
            end
            if elem.Type == "Dropdown" then
              elem._isOpen = false
              elem._arrow.Text = "v"
              for _, item in ipairs(elem._itemObjs) do
                item._bg.Visible  = false
                item._txt.Visible = false
              end
            end
            if elem.Type == "ColorPicker" then
              elem._cpOpen = false
              elem._arrowTxt.Text = ">"
              elem._panelBg.Visible = false
              elem._panelBorder.Visible = false
              for _, r in ipairs(elem._hueRects) do r.Visible = false end
              elem._hueCursor.Visible = false
              for _, sv in ipairs(elem._svRects) do sv._r.Visible = false end
              elem._svCursor.Visible = false
              local cs = elem._channelSliders or {}
              for _, ch in ipairs({"R","G","B"}) do local s=cs[ch] 
                if s then
                  s._lbl.Visible = false; s._val.Visible = false
                  s._bg.Visible = false; s._fill.Visible = false
                  if s._knob then s._knob.Visible = false 
                  end
                end 
              end
              elem._hexLabel.Visible = false
              if elem._prevPatch then elem._prevPatch.Visible = false end
              for _, sw in ipairs(elem._paletteSwatch or {}) do pcall(function() sw._r.Visible = false end) end
            end
          end
        else
          -- On minimize, clear focused input if it belongs to this window
          if _focusedInput and _focusedInput._cat == cat then
            _focusedInput.Focused = false
            if _focusedInput._cursor then _focusedInput._cursor.Visible = false end
            setrobloxinput(true)
            _focusedInput = nil
          end
        end
      end
    end
    minTxt.Text = win.Minimized and "+" or "-"
  end

  local function addCategory(name)
    local idx  = #win.Categories
    local cy   = win.Y + TOPBAR_H + idx * CAT_H + 4
    local cx   = win.X + 4

    local catBg = draw(createRectangle(cx, cy, LEFTBAR_W - 8, CAT_H - 2, Theme.LeftBar, baseZ+3, true))
    trackTheme("LeftBar", catBg)
    local catLbl = draw(createText(name, cx + 8, cy + 7, 13, Theme.CategoryText, baseZ+4, false, true))
    trackTheme("CategoryText", catLbl)

    local cat = {
      Name      = name,
      _bg       = catBg,
      _label    = catLbl,
      _elemObjs = {},      -- list of draw-object arrays per element
      _elems    = {},      -- element descriptors
      _scrollY  = 0,
    }
    table.insert(win.Categories, cat)

    if not win.ActiveCat then
      win.ActiveCat = cat
      catBg.Color   = Theme.CategoryActive
    end

    return cat
  end

 
  local function contentCursorY(cat) --  -- Content cursor tracker (returns current Y for next element)
    local baseY = win.Y + TOPBAR_H + CONTENT_PAD + cat._scrollY
    for _, eObjs in ipairs(cat._elemObjs) do
      -- each element stores its height in eObjs._h
      baseY = baseY + (eObjs._h or ELEM_H) + ELEM_PAD
    end
    return baseY
  end

  local function contentX()
    return win.X + LEFTBAR_W + CONTENT_PAD
  end

  local function contentW()
    return ww - LEFTBAR_W - CONTENT_PAD * 2
  end


  local function activateCategory(cat) -- Activate a category (show its content, hide others)
    if win.ActiveCat == cat then return end
    -- hide old
    if win.ActiveCat then
      win.ActiveCat._bg.Color = Theme.LeftBar
      for _, elem in ipairs(win.ActiveCat._elemObjs) do
        for _, obj in ipairs(elem) do
          pcall(function() obj.Visible = false end)
        end
      end
      -- Ensure the focused input loses focus when switching categories
      if _focusedInput and _focusedInput._cat == win.ActiveCat then
        _focusedInput.Focused = false
        if _focusedInput._cursor then _focusedInput._cursor.Visible = false end
        setrobloxinput(true)
        _focusedInput = nil
      end
    end
    win.ActiveCat = cat
    cat._bg.Color = Theme.CategoryActive
    -- Show the new category's base draw objects
    for _, elem in ipairs(cat._elemObjs) do
      for _, obj in ipairs(elem) do
        pcall(function() obj.Visible = true end)
      end
    end
    -- Correct per-element sub-object states AFTER making the base set visible
    for _, elem in ipairs(win._elements) do
      if elem._cat ~= cat then continue end
      -- Checkbox: marker only visible if checked
      if elem.Type == "Checkbox" and elem._check then
        elem._check.Visible = elem.State
      end
      -- TextInput: cursor always starts hidden until re-focused
      if (elem.Type == "TextInput") and elem._cursor then
        elem._cursor.Visible = false
      end
      -- Dropdown: item list always starts closed
      if elem.Type == "Dropdown" then
        elem._isOpen = false
        elem._arrow.Text = "v"
        for _, item in ipairs(elem._itemObjs) do
          item._bg.Visible  = false
          item._txt.Visible = false
        end
      end
      -- ColorPicker: panel always starts closed
      if elem.Type == "ColorPicker" then
        elem._cpOpen = false
        elem._arrowTxt.Text = ">"
        elem._panelBg.Visible = false
        elem._panelBorder.Visible = false
        for _, r in ipairs(elem._hueRects) do r.Visible = false end
        elem._hueCursor.Visible = false
        for _, sv in ipairs(elem._svRects) do sv._r.Visible = false end
        elem._svCursor.Visible = false
        local cs = elem._channelSliders or {}
        for _, ch in ipairs({"R","G","B"}) do local s=cs[ch] 
          if s then
            s._lbl.Visible = false; s._val.Visible = false
            s._bg.Visible=false; s._fill.Visible=false
            if s._knob then s._knob.Visible=false 
            end
          end 
        end
        elem._hexLabel.Visible = false
        if elem._prevPatch then elem._prevPatch.Visible = false end
        for _, sw in ipairs(elem._paletteSwatch or {}) do pcall(function() sw._r.Visible = false end) end
      end
    end
  end

  local function registerElem(cat, objs, h) -- -- Helper: register element draw-objects with a category
    objs._h = h or ELEM_H
    table.insert(cat._elemObjs, objs)
    -- hide if not active
    if win.ActiveCat ~= cat then
      for _, obj in ipairs(objs) do
        pcall(function() obj.Visible = false end)
      end
    end
  end

  local function registerElemDesc(cat, elem) -- Helper: register an element descriptor and tag it with its category
    elem._cat = cat
    table.insert(win._elements, elem)
    return elem
  end

  local function addSection(cat, labelText) -- SECTION HEADER (grouping label)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local objs = {}
    local bg   = draw(createRectangle(cx, cy, cw, 20, Theme.SectionHeader, baseZ+5, true))
    trackTheme("SectionHeader", bg)
    local lbl  = draw(createText(labelText, cx + 6, cy + 4, 12, Theme.SectionText, baseZ+6, false, true))
    trackAccent(lbl)
    table.insert(objs, bg); table.insert(objs, lbl)
    registerElem(cat, objs, 20)
    return objs
  end

  local function addButton(cat, labelText, callback) -- ── BUTTON
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local objs  = {}
    local btnBg = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", btnBg)
    local btnLbl = draw(createText(labelText, cx + cw/2, cy + ELEM_H/2 - 6, 14, Theme.TextPrimary, baseZ+6, true, false))
    trackTheme("TextPrimary", btnLbl)
    table.insert(objs, btnBg); table.insert(objs, btnLbl)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type = "Button", _bg = btnBg, _draws = objs,
      _x=cx, _y=cy, _w=cw, _h=ELEM_H,
      Callback = callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- ── TOGGLE
  local function addToggle(cat, labelText, default, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local state = default or false
    local objs = {}
    local bg  = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 8, cy + ELEM_H/2 - 7, 13, Theme.TextPrimary, baseZ+6, false, true))
    trackTheme("TextPrimary", lbl)
    local trackW, trackH = 36, 16
    local tx = cx + cw - trackW - 8
    local ty = cy + ELEM_H/2 - trackH/2
    local track   = draw(createRectangle(tx, ty, trackW, trackH, state and Theme.AccentOn or Theme.AccentOff, baseZ+6, true))
    if not state then trackTheme("AccentOff", track) end
    -- knob
    local knobSz  = 12
    local knob    = draw(createRectangle(
      state and (tx + trackW - knobSz - 2) or (tx + 2),
      ty + 2, knobSz, knobSz, Theme.SliderKnob, baseZ+7, true
    ))
    table.insert(objs, bg); table.insert(objs, lbl)
    table.insert(objs, track); table.insert(objs, knob)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="Toggle", _bg=bg, _draws=objs,
      _x=cx, _y=cy, _w=cw, _h=ELEM_H,
      _tx=tx, _ty=ty, _trackW=trackW, _trackH=trackH,
      _knob=knob, _track=track, _knobSz=knobSz,
      State=state, Callback=callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- ── SLIDER
  local function addSlider(cat, labelText, min, max, default, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local h   = ELEM_H + 10
    local val = default or min
    local objs = {}
    local bg  = draw(createRectangle(cx, cy, cw, h, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 8, cy + 6, 12, Theme.TextPrimary, baseZ+6, false, true))
    trackTheme("TextPrimary", lbl)
    local valLbl = draw(createText(tostring(math.floor(val)), cx + cw - 30, cy + 6, 12, Theme.AccentOn, baseZ+6, false, true))
    trackAccent(valLbl)
    -- track
    local trackPad = 8
    local trackW = cw - trackPad*2
    local trackY  = cy + h - 12
    local trackBg = draw(createRectangle(cx + trackPad, trackY, trackW, 4, Theme.SliderTrack, baseZ+6, true))
    trackTheme("SliderTrack", trackBg)
    -- fill
    local fillPct = (val - min) / math.max(max - min, 0.001)
    local fillW   = math.floor(trackW * fillPct)
    local fillRect = draw(createRectangle(cx + trackPad, trackY, math.max(fillW,1), 4, Theme.SliderFill, baseZ+7, true))
    trackAccent(fillRect)
    -- knob
    local knobW, knobH = 10, 14
    local knobX = cx + trackPad + fillW - knobW/2
    local knobY = trackY - 5
    local knob  = draw(createRectangle(knobX, knobY, knobW, knobH, Theme.SliderKnob, baseZ+8, true))
    trackTheme("SliderKnob", knob)
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, valLbl)
    table.insert(objs, trackBg); table.insert(objs, fillRect); table.insert(objs, knob)
    registerElem(cat, objs, h)
    local elem = {
      Type="Slider", _bg=bg, _draws=objs,
      _x=cx, _y=cy, _w=cw, _h=h,
      _trackX = cx + trackPad, _trackY = trackY,
      _trackW = trackW,
      _fillRect = fillRect, _knob = knob, _valLbl = valLbl,
      _knobW = knobW, _knobH = knobH,
      Min=min, Max=max, Value=val,
      Dragging=false, Callback=callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- ── DROPDOWN
  local function addDropdown(cat, labelText, options, default, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local selected = default or (options and options[1]) or ""
    local isOpen   = false
    local objs     = {}
    local bg  = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 8, cy + ELEM_H/2 - 7, 12, Theme.TextSecondary, baseZ+6, false, true))
    trackTheme("TextSecondary", lbl)
    local boxBg  = draw(createRectangle(cx + cw - 130, cy + 4, 122, 22, Theme.InputBg, baseZ+6, true))
    trackTheme("InputBg", boxBg)
    local selTxt = draw(createText(selected, cx + cw - 126, cy + 9, 12, Theme.TextPrimary, baseZ+7, false, true))
    trackTheme("TextPrimary", selTxt)
    local arrow  = draw(createText("v", cx + cw - 14, cy + 9, 11, Theme.AccentOn, baseZ+7, false, false))
    trackAccent(arrow)
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, boxBg)
    table.insert(objs, selTxt); table.insert(objs, arrow)

    -- Dropdown items (hidden by default, high Z)
    local itemObjs = {}
    local dropBaseZ = baseZ + 50
    for i, opt in ipairs(options or {}) do
      local iBg  = draw(createRectangle(0, 0, 122, 22, Theme.DropdownItem, dropBaseZ, true))
      trackTheme("DropdownItem", iBg)
      local iTxt = draw(createText(opt, 0, 0, 12, Theme.TextPrimary, dropBaseZ+1, false, true))
      trackTheme("TextPrimary", iTxt)
      iBg.Visible  = false
      iTxt.Visible = false
      table.insert(itemObjs, {_bg=iBg, _txt=iTxt, _value=opt, _x=0, _y=0, _idx=i})
      table.insert(objs, iBg); table.insert(objs, iTxt)
    end
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="Dropdown", _bg=bg, _draws=objs,
      _x=cx+cw-130, _y=cy, _w=122, _h=ELEM_H,
      _boxX=cx+cw-130,
      _selTxt=selTxt, _itemObjs=itemObjs, _arrow=arrow,
      _isOpen=isOpen, Selected=selected,
      Callback=callback, Options=options or {},
    }

    function elem:SetOptions(newOpts, newDefault)
      newOpts = newOpts or {}

      if self._isOpen then
        self._isOpen = false
        self._arrow.Text = "v"
        for _, item in ipairs(self._itemObjs) do
          item._bg.Visible  = false
          item._txt.Visible = false
        end
        MatchaUI.Choosing = false
      end

      for i = #objs, 6, -1 do
        local obj = objs[i]
        for gi = #_objects, 1, -1 do
          if _objects[gi] == obj then
            table.remove(_objects, gi)
            break
          end
        end
        for _, bucket in pairs(_themeObjects) do
          for ti = #bucket, 1, -1 do
            if bucket[ti] == obj then
              table.remove(bucket, ti)
              break
            end
          end
        end
        for xi = #_textObjects, 1, -1 do
          if _textObjects[xi] == obj then
            table.remove(_textObjects, xi)
            break
          end
        end
        pcall(function() obj:Remove() end)
        table.remove(objs, i)
      end

      local newItemObjs = {}
      local dropBaseZ   = baseZ + 50
      for i, opt in ipairs(newOpts) do
        local iBg  = newDraw("Square")
        iBg.Position    = Vector2.new(0, 0)
        iBg.Size        = Vector2.new(122, 22)
        iBg.Color       = Theme.DropdownItem
        iBg.ZIndex      = dropBaseZ
        iBg.Filled      = true
        iBg.Thickness   = 1
        iBg.Transparency = 1
        iBg.Visible     = false
        trackTheme("DropdownItem", iBg)

        local iTxt = newDraw("Text")
        iTxt.Text         = tostring(opt)
        iTxt.Position     = Vector2.new(0, 0)
        iTxt.Size         = 12
        iTxt.Color        = Theme.TextPrimary
        iTxt.ZIndex       = dropBaseZ + 1
        iTxt.Center       = false
        iTxt.Outline      = true
        iTxt.Font         = _currentFont
        iTxt.Transparency = 1
        iTxt.Visible      = false
        trackTheme("TextPrimary", iTxt)
        table.insert(_textObjects, iTxt)

        table.insert(newItemObjs, {_bg=iBg, _txt=iTxt, _value=opt, _x=0, _y=0, _idx=i})
        table.insert(objs, iBg); table.insert(objs, iTxt)
      end

      self._itemObjs = newItemObjs
      self.Options   = newOpts

      local sel = newDefault or newOpts[1] or "None"
      self.Selected      = sel
      self._selTxt.Text  = sel
    end

    registerElemDesc(cat, elem)
    return elem
  end

  -- ── TEXT INPUT
  local function addTextInput(cat, labelText, placeholder, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local text = ""
    local focused = false
    local objs = {}
    local bg  = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 8, cy + ELEM_H/2 - 7, 12, Theme.TextSecondary, baseZ+6, false, true))
    trackTheme("TextSecondary", lbl)
    local inputBg = draw(createRectangle(cx + cw - 160, cy + 4, 152, 22, Theme.InputBg, baseZ+6, true))
    trackTheme("InputBg", inputBg)
    local inputTxt = draw(createText(placeholder or "", cx + cw - 156, cy + 9, 12, Theme.TextDisabled, baseZ+7, false, true))
    trackTheme("TextDisabled", inputTxt)
    local cursor   = draw(createRectangle(cx + cw - 156, cy + 7, 1, 14, Theme.AccentOn, baseZ+8, true))
    trackAccent(cursor)
    cursor.Visible = false
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, inputBg)
    table.insert(objs, inputTxt); table.insert(objs, cursor)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="TextInput", _bg=bg, _draws=objs,
      _x=cx+cw-160, _y=cy, _w=160, _h=ELEM_H,
      _inputTxt=inputTxt, _cursor=cursor, _inputBg=inputBg,
      _placeholder=placeholder or "",
      Text=text, Focused=focused, Callback=callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- ── CHECKBOX
  local function addCheckbox(cat, labelText, default, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local state = default or false
    local objs = {}
    local bg  = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 30, cy + ELEM_H/2 - 7, 13, Theme.TextPrimary, baseZ+6, false, true))
    trackTheme("TextPrimary", lbl)
    local boxSz = 16
    local bx = cx + 8
    local by = cy + ELEM_H/2 - boxSz/2
    local box  = draw(createRectangle(bx, by, boxSz, boxSz, Theme.InputBg, baseZ+6, true))
    trackTheme("InputBg", box)
    local boxBorder = draw(createRectangle(bx, by, boxSz, boxSz, Theme.ElementBorder, baseZ+6, false))
    trackTheme("ElementBorder", boxBorder)
    boxBorder.Filled = false
    local check = draw(createRectangle(bx+3, by+3, boxSz-6, boxSz-6, Theme.AccentOn, baseZ+7, true))
    trackAccent(check)
    check.Visible = state
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, box)
    table.insert(objs, boxBorder); table.insert(objs, check)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="Checkbox", _bg=bg, _draws=objs,
      _x=cx, _y=cy, _w=cw, _h=ELEM_H,
      _check=check, _box=box,
      State=state, Callback=callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- ── KEYBIND
  local function addKeybind(cat, labelText, defaultKey, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local key = defaultKey or 0x2D
    local _listening = false
    local objs = {}
    local bg  = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl = draw(createText(labelText, cx + 8, cy + ELEM_H/2 - 7, 12, Theme.TextSecondary, baseZ+6, false, true))
    trackTheme("TextSecondary", lbl)
    local kbBg  = draw(createRectangle(cx + cw - 100, cy + 4, 92, 22, Theme.InputBg, baseZ+6, true))
    trackTheme("InputBg", kbBg)
    local kbTxt = draw(createText("[ " .. (KeyNames[key] or "?") .. " ]", cx + cw - 98, cy + 9, 12, Theme.TextPrimary, baseZ+7, false, true))
    trackTheme("TextPrimary", kbTxt)
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, kbBg); table.insert(objs, kbTxt)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="Keybind", _bg=bg, _draws=objs,
      _x=cx+cw-100, _y=cy, _w=92, _h=ELEM_H,
      _kbTxt=kbTxt, Key=key, Listening=false,
      Callback=callback,
    }
    registerElemDesc(cat, elem)
    return elem
  end

  -- Color picker; Layout: Header row : [Label]  [Preview swatch]  [> button] Panel (opens to the RIGHT of the window, floating): Left  : hex color palette (10 cols × 8 rows of swatches); Right : R/G/B +/- steppers + hex label + live preview
  local function addColorPicker(cat, labelText, defaultColor, callback)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local rowH = ELEM_H
    local color = defaultColor or Color3.fromRGB(255, 100, 100)
    local objs = {}

    local bg      = draw(createRectangle(cx, cy, cw, rowH, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl     = draw(createText(labelText, cx + 8, cy + 6, 12, Theme.TextSecondary, baseZ+6, false, true))
    trackTheme("TextSecondary", lbl)
    local preview = draw(createRectangle(cx + cw - 54, cy + 4, 22, 22, color, baseZ+7, true))
    local arrowBtn = draw(createRectangle(cx + cw - 28, cy + 4, 22, 22, Theme.InputBg, baseZ+7, true))
    trackTheme("InputBg", arrowBtn)
    local arrowTxt = draw(createText(">", cx + cw - 22, cy + 8, 12, Theme.AccentOn, baseZ+8, false, false))
    trackAccent(arrowTxt)
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, preview)
    table.insert(objs, arrowBtn); table.insert(objs, arrowTxt)

    local panelX  = win.X + ww + 4
    local panelY  = cy
    local swatchSz = 16
    local swatchGap = 2
    local palCols = 10
    local palRows = 8
    local palW    = palCols * (swatchSz + swatchGap) - swatchGap
    local palH    = palRows * (swatchSz + swatchGap) - swatchGap
    local rsAreaX = panelX + palW + 8
    local rsAreaW = 80
    local panelW  = palW + 8 + rsAreaW + 8
    local panelH  = palH + 8

    local panelObjs = {}
    local panelObjOffsets = {}

    local function addPanelObj(o)
      table.insert(panelObjs, o)
      table.insert(objs, o)
      pcall(function()
        table.insert(panelObjOffsets, {
          dx = o.Position.X - panelX,
          dy = o.Position.Y - panelY,
        })
      end)
      return o
    end

    local panelBg = addPanelObj(draw(createRectangle(panelX, panelY, panelW, panelH + 4, Theme.DropdownBg, baseZ+50, true)))
    trackTheme("DropdownBg", panelBg)
    panelBg.Visible = false

    local panelBorder = addPanelObj(draw(createRectangle(panelX, panelY, panelW, panelH + 4, Theme.ElementBorder, baseZ+50, false)))
    trackTheme("ElementBorder", panelBorder)
    panelBorder.Filled = false; panelBorder.Thickness = 1; panelBorder.Visible = false

    local PALETTE = {
      "8B0000","B22222","CC2200","FF0000","FF4500","FF6347","FF7F50","FF8C00","FFA500","FFD700",
      "FFFF00","ADFF2F","7FFF00","00FF00","00FA9A","00FF7F","39FF14","00FF80","00FFAA","00FFCC",
      "00FFFF","00CED1","00BFFF","1E90FF","0000FF","0000CD","00008B","191970","483D8B","6A0DAD",
      "8B008B","9400D3","EE82EE","FF00FF","FF1493","FF69B4","FFB6C1","C71585","DB7093","FF007F",
      "A52A2A","8B4513","D2691E","CD853F","DEB887","F5DEB3","FFE4B5","FFDAB9","FAEBD7","FAF0E6",
      "4169E1","6495ED","87CEEB","ADD8E6","B0E0E6","5F9EA0","4682B4","708090","778899","B0C4DE",
      "006400","228B22","2E8B57","3CB371","66CDAA","8FBC8F","90EE90","98FB98","F0FFF0","E8F5E9",
      "000000","1A1A1A","333333","555555","777777","999999","AAAAAA","CCCCCC","EEEEEE","FFFFFF",
    }

    local paletteSwatches = {}
    for i, hexStr in ipairs(PALETTE) do
      local row = math.floor((i-1) / palCols)
      local col = (i-1) % palCols
      local sx  = panelX + 4 + col * (swatchSz + swatchGap)
      local sy  = panelY + 4 + row * (swatchSz + swatchGap)
      local r2  = tonumber(hexStr:sub(1,2), 16) or 0
      local g2  = tonumber(hexStr:sub(3,4), 16) or 0
      local b2  = tonumber(hexStr:sub(5,6), 16) or 0
      local sw  = addPanelObj(draw(createRectangle(sx, sy, swatchSz, swatchSz, Color3.fromRGB(r2,g2,b2), baseZ+52, true)))
      sw.Visible = false
      table.insert(paletteSwatches, {_r=sw, _x=sx, _y=sy, _w=swatchSz, _h=swatchSz,
        _color=Color3.fromRGB(r2,g2,b2)})
    end

    local function colorToHex(c)
      return string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
    end

    local chRowH = 24
    local slPad = 4
    local lblW = 12
    local valW2 = 28
    local slTrackX = rsAreaX + slPad + lblW + valW2 + 4
    local slTrackW = rsAreaW - slPad - lblW - valW2 - 4 - slPad
    local knobW2 = 8

    local channels = {"R","G","B"}
    local channelSliders = {}
    local btnObjs = {}

    local chFillColors = {
      R = Color3.fromRGB(220, 60, 60),
      G = Color3.fromRGB(60, 200, 60),
      B = Color3.fromRGB(60, 100, 220),
    }

    local _rSlider = {_x=0,_y=0,_w=1,_h=1,_bg=nil,_fill=nil,_lbl=nil,_val=nil}
    local _gSlider = {_x=0,_y=0,_w=1,_h=1,_bg=nil,_fill=nil,_lbl=nil,_val=nil}
    local _bSlider = {_x=0,_y=0,_w=1,_h=1,_bg=nil,_fill=nil,_lbl=nil,_val=nil}

    for ci, ch in ipairs(channels) do
      local rowY = panelY + 4 + (ci-1) * chRowH

      local lbl2 = draw(createText(ch, rsAreaX + slPad, rowY + 6, 11,
        Theme.TextSecondary, baseZ+52, false, false))
      lbl2.Visible = false; addPanelObj(lbl2)

      local initV = math.floor((ch=="R" and color.R or ch=="G" and color.G or color.B) * 255)
      local valT  = draw(createText(tostring(initV),
        rsAreaX + slPad + lblW + 2, rowY + 6, 11,
        Theme.TextPrimary, baseZ+52, false, false))
      valT.Visible = false; addPanelObj(valT)

      local trackBg2 = draw(createRectangle(slTrackX, rowY + 8, slTrackW, 4,
        Theme.SliderTrack, baseZ+52, true))
      trackBg2.Visible = false; addPanelObj(trackBg2)

      local initPct  = initV / 255
      local initFillW = math.max(1, math.floor(slTrackW * initPct))
      local fillRect2 = draw(createRectangle(slTrackX, rowY + 8, initFillW, 4,
        chFillColors[ch], baseZ+53, true))
      fillRect2.Visible = false; addPanelObj(fillRect2)

      local knobX2 = slTrackX + initFillW - knobW2/2
      local knobY2 = rowY + 3
      local knob2  = draw(createRectangle(knobX2, knobY2, knobW2, 14,
        Theme.SliderKnob, baseZ+54, true))
      knob2.Visible = false; addPanelObj(knob2)

      local slInfo = {
        _lbl=lbl2, _val=valT,
        _bg=trackBg2, _fill=fillRect2,
        _minBg=trackBg2, _minTx=lbl2,
        _plusBg=trackBg2, _plusTx=valT,
        _fillRect=fillRect2, _knob=knob2,
        _trackX=slTrackX, _trackW=slTrackW,
        _knobY=knobY2, _rowY=rowY,
      }
      channelSliders[ch] = slInfo

      table.insert(btnObjs, {
        _x=slTrackX, _y=rowY+2, _w=slTrackW, _h=16,
        _ch=ch, _isSlider=true,
        _fillRect=fillRect2, _knob=knob2,
        _trackX=slTrackX, _trackW=slTrackW, _knobY=knobY2,
      })

      if ch=="R" then
        _rSlider = {_bg=trackBg2,_fill=fillRect2,_lbl=lbl2,_val=valT,
          _x=slTrackX,_y=rowY,_w=slTrackW,_h=14}
      elseif ch=="G" then
        _gSlider = {_bg=trackBg2,_fill=fillRect2,_lbl=lbl2,_val=valT,
          _x=slTrackX,_y=rowY,_w=slTrackW,_h=14}
      else
        _bSlider = {_bg=trackBg2,_fill=fillRect2,_lbl=lbl2,_val=valT,
          _x=slTrackX,_y=rowY,_w=slTrackW,_h=14}
      end
    end

    local hexLblY  = panelY + 4 + 3*chRowH + 4
    local hexLabel = addPanelObj(draw(createText(colorToHex(color), rsAreaX + slPad, hexLblY, 10,
      Theme.TextSecondary, baseZ+52, false, false)))
    hexLabel.Visible = false

    local prevPatch = addPanelObj(draw(createRectangle(rsAreaX + slPad, hexLblY + 14, rsAreaW - slPad*2, 14,
      color, baseZ+52, true)))
    prevPatch.Visible = false

    registerElem(cat, objs, rowH)

    local _elemRef = { Color = nil }

    local function refreshAll()
      local c = _elemRef.Color or color
      preview.Color   = c
      prevPatch.Color = c
      hexLabel.Text   = colorToHex(c)
      local rv = math.floor(c.R*255)
      local gv = math.floor(c.G*255)
      local bv = math.floor(c.B*255)
      local vals = {R=rv, G=gv, B=bv}
      for _, ch2 in ipairs({"R","G","B"}) do
        local s = channelSliders[ch2]
        if s then
          s._val.Text = tostring(vals[ch2])
          local pct2 = vals[ch2] / 255
          local fw2  = math.max(1, math.floor(pct2 * s._trackW))
          s._fillRect.Size = Vector2.new(fw2, 4)
          s._knob.Position = Vector2.new(s._trackX + fw2 - knobW2/2, s._knobY)
        end
      end
      if callback then pcall(callback, c) end
    end

    local elem = {
      Type="ColorPicker", _bg=bg, _draws=objs,
      _x=cx+cw-54, _y=cy, _w=54, _h=rowH,
      _arrowX=cx+cw-28, _arrowY=cy+4, _arrowW=22, _arrowH=22,
      _headerX=cx, _headerY=cy, _headerW=cw, _headerH=rowH,
      _panelBg=panelBg, _panelBorder=panelBorder,
      _panelX=panelX, _panelY=panelY, _panelW=panelW, _panelH=panelH+4,
      _panelObjs=panelObjs,
      _panelObjOffsets=panelObjOffsets,
      _buildPanelX=panelX, _buildPanelY=panelY,
      _hueRects={}, _hueCursor=panelBorder,
      _svRects={}, _svCursor=panelBorder,
      _rSlider=_rSlider, _gSlider=_gSlider, _bSlider=_bSlider,
      _hexLabel=hexLabel,
      _preview=preview, _arrowTxt=arrowTxt,
      _paletteSwatch=paletteSwatches,
      _channelSliders=channelSliders,
      _btnObjs=btnObjs,
      _prevPatch=prevPatch,
      _swatches={},
      _cpOpen=false,
      _cpDragCh=nil,
      _cpDragHue=false, _cpDragR=false, _cpDragG=false, _cpDragB=false, _cpDragSV=false,
      Color=color,
      _cpHue=0, _cpSat=1, _cpVal=1,
      _refreshSV=function() end,
      _refreshAll=refreshAll,
      _rsW=rsAreaW, _rsH=14, _rsX=rsAreaX,
      Callback=callback,
    }

    for _, sw in ipairs(paletteSwatches) do
      sw._origDX = sw._x - panelX
      sw._origDY = sw._y - panelY
    end

    for _, btn in ipairs(btnObjs) do
      btn._origDX = btn._x - panelX
      btn._origDY = btn._y - panelY
      if btn._trackX then btn._origTrackDX = btn._trackX - panelX end
      if btn._knobY then btn._origKnobDY = btn._knobY - panelY end
    end

    for _, s in pairs(channelSliders) do
      if s._trackX then s._origTrackDX = s._trackX - panelX end
      if s._knobY then s._origKnobDY = s._knobY - panelY end
      if s._rowY then s._origRowDY = s._rowY - panelY end
    end

    _elemRef.Color = nil
    _elemRef._channelSliders = channelSliders

    elem._refreshAll = function()
      _elemRef.Color = elem.Color
      refreshAll()
    end

    registerElemDesc(cat, elem)
    return elem
  end

  -- ── VALUE LABEL
  local function addValueLabel(cat, labelText, defaultValue)
    local cx  = contentX()
    local cw  = contentW()
    local cy  = contentCursorY(cat)
    local objs = {}
    local bg   = draw(createRectangle(cx, cy, cw, ELEM_H, Theme.ElementBg, baseZ+5, true))
    trackTheme("ElementBg", bg)
    local lbl  = draw(createText(labelText, cx + 8, cy + ELEM_H/2 - 7, 12, Theme.TextSecondary, baseZ+6, false, true))
    trackTheme("TextSecondary", lbl)
    local valW   = 100
    local _valX   = cx + cw - valW - 6
    local valRightEdge = cx + cw - 8
    local valCover = draw(createRectangle(cx + cw - valW - 6, cy + 1, valW + 2, ELEM_H - 2, Theme.ElementBg, baseZ+6, true))
    trackTheme("ElementBg", valCover)
    local initStr = tostring(defaultValue or "")
    local initX   = valRightEdge - math.min(#initStr * 7, valW)
    local valTxt  = draw(createText(initStr, initX, cy + ELEM_H/2 - 7, 13, Theme.AccentOn, baseZ+7, false, true))
    trackAccent(valTxt)
    table.insert(objs, bg); table.insert(objs, lbl); table.insert(objs, valCover); table.insert(objs, valTxt)
    registerElem(cat, objs, ELEM_H)
    local elem = {
      Type="ValueLabel", _bg=bg, _draws=objs,
      _x=cx, _y=cy, _w=cw, _h=ELEM_H,
      _valTxt=valTxt, _valCover=valCover, _valW=valW,
      _valRightEdge=valRightEdge,
      _labelTxt=lbl,
      Value=defaultValue or "",
      SetValue=function(self, v)
        self.Value = v
        local s = tostring(v)
        self._valTxt.Text = s
        local estimatedW = math.min(#s * 7, self._valW)
        self._valTxt.Position = Vector2.new(
          self._valRightEdge - estimatedW,
          self._valTxt.Position.Y
        )
      end,
    }
    registerElemDesc(cat, elem)
    return elem
  end

-- ── SCROLLING FRAME; visH : visible height of the frame (px). innerH auto-grows as widgets are added. Supports both text rows (AddItem) and full UI elements (AddWidget). Scrolling is controlled by dragging the scrollbar thumb or content drag. Each frame in the main loop re-positions and clips all child objects.
local function addScrollFrame(cat, innerH, callback, customVisH)
  local cx = contentX()
  local cw = contentW()
  local cy = contentCursorY(cat)
  local visH = customVisH or math.min(innerH, 80)
  local objs = {}

  local bg = draw(createRectangle(cx, cy, cw, visH, Theme.InputBg, baseZ + 5, true))
  trackTheme("InputBg", bg)

  -- clip border
  local border = draw(createRectangle(cx, cy, cw, visH, Theme.ElementBorder, baseZ + 5, false))
  trackTheme("ElementBorder", border)
  border.Filled = false
  border.Thickness = 1

  -- scrollbar track
  local sbX = cx + cw - 8
  local sbTrack = draw(createRectangle(sbX, cy, 6, visH, Theme.ScrollBar, baseZ + 6, true))
  trackTheme("ScrollBar", sbTrack)

  -- thumb (height proportional to content)
  local thumbH = math.max(20, math.floor(visH * visH / math.max(innerH, 1)))
  local thumb = draw(createRectangle(sbX, cy, 6, thumbH, Theme.ScrollThumb, baseZ + 7, true))
  trackAccent(thumb)

  table.insert(objs, bg)
  table.insert(objs, border)
  table.insert(objs, sbTrack)
  table.insert(objs, thumb)

  registerElem(cat, objs, visH)

  -- BUG 2 FIX: content width leaves room for the scrollbar so widgets never overlap it.
  -- 10 = 8px scrollbar track + 2px inner padding gap.
  local contentPadRight = 10
  local innerCW = cw - contentPadRight

  local elem = {
    Type = "ScrollFrame",
    _bg = bg,
    _draws = objs,
    _x = cx,
    _y = cy,
    _w = cw,
    _h = visH,
    _sbX = sbX,
    _thumb = thumb,
    _thumbH = thumbH,
    _innerH = innerH,
    _scrollY = 0,
    _thumbDragging = false,
    _thumbDragOffY = 0,
    _contentDragging = false,
    _contentDragStartY = 0,
    _contentDragStartScroll = 0,
    _items = {},
    _widgets = {},
    _itemH = 18,
    Callback = callback,
  }

  function elem:AddItem(text)
    local rowIdx = #self._items
    local relY = rowIdx * self._itemH + 4
    local absY = self._y + relY

    local txt = draw(createText(text, self._x + 6, absY, 12, Theme.TextPrimary, baseZ + 8, false, false))
    txt.Visible = (absY >= self._y) and (absY + self._itemH <= self._y + self._h)

    table.insert(self._items, { _txt = txt, _relY = relY })
    table.insert(objs, txt)

    local neededH = (#self._items) * self._itemH + 8
    if neededH > self._innerH then
      self._innerH = neededH
      local newThH = math.max(20, math.floor(self._h * self._h / self._innerH))
      self._thumbH = newThH
      self._thumb.Size = Vector2.new(6, newThH)
    end

    if win.ActiveCat ~= cat then txt.Visible = false end
    return txt
  end

  function elem:AddWidget(builder)
    local neededInnerH = 0

    for _, w in ipairs(self._widgets) do
      neededInnerH = neededInnerH + w._h + 2
    end

    for _, it in ipairs(self._items) do
      neededInnerH = neededInnerH + self._itemH
    end

    local relY = neededInnerH + 4

    local builtElem = builder()
    if not builtElem then return nil end

    local wh = builtElem._h or ELEM_H
    local absY = self._y + relY - self._scrollY
    local dyFix = absY - (builtElem._y or absY)

    local dxW = innerCW - (builtElem._w or cw)
    if dxW < 0 then
      if builtElem._bg then
        pcall(function()
          local s = builtElem._bg.Size
          builtElem._bg.Size = Vector2.new(s.X + dxW, s.Y)
        end)
      end
      builtElem._w = (builtElem._w or cw) + dxW
    end

    builtElem._inScrollFrame = true

    local panelObjSet = {}

    if builtElem._panelObjs then
      for _, po in ipairs(builtElem._panelObjs) do
        panelObjSet[po] = true
      end
    end

    if builtElem.Type == "Dropdown" and builtElem._itemObjs then
      for _, item in ipairs(builtElem._itemObjs) do
        if item._bg then panelObjSet[item._bg] = true end
        if item._txt then panelObjSet[item._txt] = true end
      end
    end

    local lastObjs = cat._elemObjs[#cat._elemObjs]
    local widgetObjs = {}

    if lastObjs then
      for _, o in ipairs(lastObjs) do
        table.insert(widgetObjs, o)
        table.insert(objs, o)

        if not panelObjSet[o] then
          pcall(function()
            o.Position = o.Position + Vector2.new(0, dyFix)
          end)

          local oAbsY = o.Position.Y
          o.Visible = (oAbsY >= self._y) and (oAbsY < self._y + self._h)
        end
      end

      table.remove(cat._elemObjs, #cat._elemObjs)
    end

    if builtElem._y then builtElem._y = builtElem._y + dyFix end
    if builtElem._ty then builtElem._ty = builtElem._ty + dyFix end
    if builtElem._trackY then builtElem._trackY = builtElem._trackY + dyFix end

    if builtElem.Type == "Dropdown" and builtElem._itemObjs then
      for _, item in ipairs(builtElem._itemObjs) do
        if item._y then item._y = item._y + dyFix end
      end
    end

    if builtElem.Type == "ColorPicker" then
      if builtElem._headerY then
        builtElem._headerY = builtElem._headerY + dyFix
      end

      builtElem._origHeaderY = builtElem._headerY

      for _, btn in ipairs(builtElem._btnObjs or {}) do
        if btn._y then btn._y = btn._y + dyFix end
        if btn._knobY then btn._knobY = btn._knobY + dyFix end
      end

      local cs = builtElem._channelSliders or {}
      for _, s in pairs(cs) do
        if s._knobY then s._knobY = s._knobY + dyFix end
        if s._rowY then s._rowY = s._rowY + dyFix end
      end
    end

    table.insert(self._widgets, {
      _objs = widgetObjs,
      _relY = relY,
      _h = wh,
      _elem = builtElem,
      _panelObjSet = panelObjSet
    })

    local totalH = relY + wh + 8
    if totalH > self._innerH then
      self._innerH = totalH
      local newThH = math.max(20, math.floor(self._h * self._h / self._innerH))
      self._thumbH = newThH
      self._thumb.Size = Vector2.new(6, newThH)
    end

    if win.ActiveCat ~= cat then
      for _, o in ipairs(widgetObjs) do
        pcall(function() o.Visible = false end)
      end
    end

    return builtElem
  end

  registerElemDesc(cat, elem)
  return elem
end

-- ── TOOLTIP (attached to element, shown on hover)
local function addTooltip(elem, tipText)
  local ttBg = newDraw("Square")
  ttBg.Size = Vector2.new(#tipText * 7 + 12, 20)
  ttBg.Color = Theme.TooltipBg
  ttBg.ZIndex = baseZ + 90
  ttBg.Filled = true
  ttBg.Transparency = 1
  ttBg.Visible = false

  local ttTxt = newDraw("Text")
  ttTxt.Text = tipText
  ttTxt.Size = 12
  ttTxt.Color = Theme.TextPrimary
  ttTxt.ZIndex = baseZ + 91
  ttTxt.Center = false
  ttTxt.Outline = true
  ttTxt.Font = Drawing.Fonts.Monospace
  ttTxt.Transparency = 1
  ttTxt.Visible = false

  local tip = {
    _bg = ttBg,
    _txt = ttTxt,
    _elem = elem,
    Text = tipText
  }

  table.insert(_tooltips, tip)
  return tip
end


  -- Expose public API on window

  win.AddCategory    = addCategory
  win.AddSection     = addSection
  win.AddButton      = addButton
  win.AddToggle      = addToggle
  win.AddSlider      = addSlider
  win.AddDropdown    = addDropdown
  win.AddTextInput   = addTextInput
  win.AddCheckbox    = addCheckbox
  win.AddKeybind     = addKeybind
  win.AddColorPicker = addColorPicker
  win.AddValueLabel  = addValueLabel
  win.AddScrollFrame = addScrollFrame
  win.AddTooltip     = addTooltip
  win.AddConfigPreset = function(opts)
    return MatchaUI.AddConfigPreset(win, opts)
  end

  win.Reposition     = reposition
  win.SetVisible     = setWinVisible
  win.Minimize       = minimize
  win._minBtn  = minBtn
  win._minBtnX = wx + ww - 52
  win._minBtnY = wy + 6
  win._minBtnW = 18
  win._minBtnH = 16
  win._closeBtn  = closeBtn
  win._closeBtnX = wx + ww - 26
  win._closeBtnY = wy + 6
  win._closeBtnW = 18
  win._closeBtnH = 16
  win._topBarH   = TOPBAR_H
  win._activateCategory = activateCategory

  table.insert(_windows, win)
  return win
end


-- NOTIFICATION SYSTEM
local NOTIF_W       = 240
local NOTIF_PAD     = 6
local NOTIF_DUR     = 4   -- seconds
local NOTIF_INNER_W = NOTIF_W - 16   -- 8px padding each side
-- Approximate character width at size 12 (Monospace). Used for word-wrap.
local NOTIF_CHAR_W  = 7

-- Notifications task.spawn at top-left (50, 50) and stack downward.
local NOTIF_START_X = 50
local NOTIF_START_Y = 150


local function _wrapText(text, maxChars) -- Word-wrap a string to fit within maxChars per line. Returns a table of line strings and the total line count.
  local lines = {}
  local words = {}

  for w in (text .. " "):gmatch("([^ ]*) ") do
    table.insert(words, w)
  end

  local line = ""

  for _, w in ipairs(words) do
    local candidate = line == "" and w or (line .. " " .. w)

    if #candidate <= maxChars then
      line = candidate
    else
      if line ~= "" then
        table.insert(lines, line)
      end

      -- If the single word itself exceeds maxChars, hard-break it
      while #w > maxChars do
        table.insert(lines, w:sub(1, maxChars))
        w = w:sub(maxChars + 1)
      end

      line = w
    end
  end

  if line ~= "" then table.insert(lines, line); end
  if #lines == 0 then lines = { "" }; end
  return lines
end

local function _layoutNotifs()
  local by = NOTIF_START_Y

  for i = 1, #_notifs do
    local n = _notifs[i]

    n._bg.Position = Vector2.new(NOTIF_START_X, by)
    n._title.Position = Vector2.new(NOTIF_START_X + 8, by + 6)

    -- Reposition each wrapped message line
    for li, lObj in ipairs(n._msgLines) do
      lObj.Position = Vector2.new(NOTIF_START_X + 8, by + 22 + (li - 1) * 14)
    end

    n._bar.Position = Vector2.new(NOTIF_START_X, by + n._h - 4)
    by = by + n._h + NOTIF_PAD
  end
end

function MatchaUI.Notify(title, message, duration)
  local nx = NOTIF_START_X
  local ny = NOTIF_START_Y

  -- Stack below existing notifications (actual Y set by _layoutNotifs)
  local dur = duration or NOTIF_DUR

  -- Pre-calculate wrapped lines so we know how tall the notification must be
  local maxChars = math.floor(NOTIF_INNER_W / NOTIF_CHAR_W)
  local msgLines = _wrapText(message or "", maxChars)

  -- Height: 6 (top pad) + 13 (title) + 3 (gap) + lines*14 + 6 (bottom pad) + 4 (bar)
  local NOTIF_H = 6 + 13 + 3 + (#msgLines * 14) + 6 + 4

  local bg = newDraw("Square")
  bg.Position = Vector2.new(nx, ny)
  bg.Size = Vector2.new(NOTIF_W, NOTIF_H)
  bg.Color = Theme.NotifBg
  bg.Filled = true
  bg.ZIndex = 300
  bg.Transparency = 1
  bg.Visible = true

  local tTitle = newDraw("Text")
  tTitle.Text = title or "Notice"
  tTitle.Position = Vector2.new(nx + 8, ny + 6)
  tTitle.Size = 13
  tTitle.Color = Theme.AccentOn
  tTitle.ZIndex = 302
  tTitle.Outline = true
  tTitle.Font = Drawing.Fonts.Monospace
  tTitle.Transparency = 1
  tTitle.Visible = true

  -- Create one Drawing.Text object per wrapped line
  local tMsgObjs = {}

  for li, lineStr in ipairs(msgLines) do
    local lObj = newDraw("Text")
    lObj.Text = lineStr
    lObj.Position = Vector2.new(nx + 8, ny + 22 + (li - 1) * 14)
    lObj.Size = 12
    lObj.Color = Theme.TextPrimary
    lObj.ZIndex = 302
    lObj.Outline = true
    lObj.Font = Drawing.Fonts.Monospace
    lObj.Transparency = 1
    lObj.Visible = true
    table.insert(tMsgObjs, lObj)
  end

  -- Horizontal progress bar (time remaining indicator)
  local bar = newDraw("Square")
  bar.Position = Vector2.new(nx, ny + NOTIF_H - 4)
  bar.Size = Vector2.new(NOTIF_W, 4)
  bar.Color = Theme.AccentOn
  bar.Filled = true
  bar.ZIndex = 303
  bar.Transparency = 1
  bar.Visible = true

  local notif = {
    _bg = bg,
    _title = tTitle,
    _msgLines = tMsgObjs,
    _bar = bar,
    _timer = 0,
    _duration = dur,
    _done = false,
    _h = NOTIF_H,
  }

  table.insert(_notifs, notif)
  _layoutNotifs()
  return notif
end





local DEFAULT_PRESETS = { -- DEFAULT BUILT-IN PRESETS; Used by AddConfigPreset when no presets table is supplied.
  ["Default (Lime)"] = {
    accent = Color3.fromRGB(57, 255, 20),
    Background = Color3.fromHex("#0A0A0A"),
    TopBar = Color3.fromHex("#111111"),
    LeftBar = Color3.fromHex("#141414"),
    CategoryHover = Color3.fromHex("#1F1F1F"),
    CategoryText = Color3.fromHex("#FFFFFF"),
    ContentBg = Color3.fromHex("#0A0A0A"),
    ElementBg = Color3.fromHex("#141414"),
    ElementBorder = Color3.fromHex("#2A2A2A"),
    AccentOff = Color3.fromHex("#2A2A2A"),
    TextPrimary = Color3.fromHex("#FFFFFF"),
    TextSecondary = Color3.fromHex("#AAAAAA"),
    TextDisabled = Color3.fromHex("#555555"),
    SliderTrack = Color3.fromHex("#2A2A2A"),
    SliderKnob = Color3.fromHex("#FFFFFF"),
    DropdownBg = Color3.fromHex("#111111"),
    DropdownItem = Color3.fromHex("#0A0A0A"),
    DropdownHover = Color3.fromHex("#1F1F1F"),
    InputBg = Color3.fromHex("#0D0D0D"),
    TooltipBg = Color3.fromHex("#050505"),
    NotifBg = Color3.fromHex("#111111"),
    ScrollBar = Color3.fromHex("#1A1A1A"),
    TitleText = Color3.fromHex("#FFFFFF"),
    CloseBtn = Color3.fromHex("#CC2200"),
    MinimizeBtn = Color3.fromHex("#444444"),
    SectionHeader = Color3.fromHex("#1A1A1A"),
  },
}

--[[
-- ─────────────────────────────────────────────────────────────
-- ADD CONFIG PRESET
-- ─────────────────────────────────────────────────────────────
-- Creates a self-contained "Config" category on the window that
-- handles everything: keybind, accent, font, full preset switching,
-- named custom theme save/load — all auto-saved on every change and
-- auto-loaded on call (before UiLib.Run).
--
-- ALL options are optional. Minimal usage:
--   Window.AddConfigPreset({})
--   Window.AddConfigPreset()
--
-- Options (all optional):
--   toggleKeybind   handle   external keybind widget whose .Key is kept in sync.
--                            When nil, the Config category's own keybind widget
--                            drives window show/hide automatically via an internal
--                            polling thread — no external setup needed.
--   configPath      string   override default save path (default: "MatchaUI/Config.json")
--   themesDir       string   override default themes folder (default: "MatchaUI/Themes")
--   presets         table    built-in preset table { [name]={accent,keys...} }
--                            when nil, the 5 built-in MatchaUI presets are used:
--                            "Default (Lime)", "Crimson", "Ocean", "Sunset", "Monochrome"
--
-- The category is created, populated, and the saved config is applied
-- before this function returns.  Call it before UiLib.Run().
]]

function MatchaUI.AddConfigPreset(win, opts)
  opts = opts or {}
  local CONFIG_PATH = opts.configPath or "MatchaUI/Config.json"
  local THEMES_DIR  = opts.themesDir or "MatchaUI/Themes"
  local kbHandle    = opts.toggleKeybind
  local builtinPresets = opts.presets or DEFAULT_PRESETS

  -- ── Helpers ───────────────────────────────────────────────
local function c3hex(c)
  return string.format("#%02X%02X%02X",
    math.floor(c.R * 255),
    math.floor(c.G * 255),
    math.floor(c.B * 255)
  )
end

  local function hex3c(h)
    h = (h or "000000"):gsub("#", "")
    return Color3.fromRGB(
      tonumber(h:sub(1, 2), 16) or 0,
      tonumber(h:sub(3, 4), 16) or 0,
      tonumber(h:sub(5, 6), 16) or 0
    )
  end

  local THEME_SLOT_KEYS = {
    "Background", "TopBar", "LeftBar", "CategoryHover", "CategoryText",
    "ContentBg", "ElementBg", "ElementBorder", "AccentOff",
    "TextPrimary", "TextSecondary", "TextDisabled",
    "SliderTrack", "SliderKnob", "DropdownBg", "DropdownItem",
    "DropdownHover", "InputBg", "TooltipBg", "NotifBg",
    "ScrollBar", "TitleText", "CloseBtn", "MinimizeBtn", "SectionHeader",
  }

  -- ── Defaults ──────────────────────────────────────────────
  local DEFAULT = {
    ToggleKeybindVK = kbHandle and kbHandle.Key or 0x2D,
    AccentHex       = "#39FF14",
    Font            = "Monospace",
    ThemePreset     = "Default (Lime)",
    ThemeColors     = {},
  }

  -- ── Live state ────────────────────────────────────────────
  local _cfg = {
    ToggleKeybindVK = DEFAULT.ToggleKeybindVK,
    AccentHex       = DEFAULT.AccentHex,
    Font            = DEFAULT.Font,
    ThemePreset     = DEFAULT.ThemePreset,
    ThemeColors     = {},
  }

  -- ── Persist ───────────────────────────────────────────────
  local function saveConfig()
    pcall(function()
      local HttpService = game:GetService("HttpService")
      writefile(CONFIG_PATH, HttpService:JSONEncode(_cfg))
    end)
  end

  local function readConfig()
    if isfile(CONFIG_PATH) then
      local ok, data = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(readfile(CONFIG_PATH))
      end)
      if ok and data then return data end
    end
    return DEFAULT
  end

  -- ── Theme files ───────────────────────────────────────────
  local function listCustomThemes()
    local names = {}

    if isfolder(THEMES_DIR) then
      local ok, files = pcall(listfiles, THEMES_DIR)

      if ok then
        for _, path in ipairs(files) do
          local name = path:match("([^/\\]+)%.json$")
          if name then table.insert(names, name) end
        end
      end
    end

    return names
  end

  local function saveCustomTheme(name, accentHex, themeColors)
    if not isfolder(THEMES_DIR) then pcall(makefolder, THEMES_DIR); end

    local out = { accentHex = accentHex }

    for _, k in ipairs(THEME_SLOT_KEYS) do
      if themeColors and themeColors[k] then
        out[k] = themeColors[k]
      else
        local liveColor = Theme and Theme[k]
        out[k] = liveColor and c3hex(liveColor) or "#000000"
      end
    end

    pcall(function()
      local HttpService = game:GetService("HttpService")
      writefile(THEMES_DIR .. "/" .. name .. ".json", HttpService:JSONEncode(out))
    end)
  end

  local function loadCustomTheme(name)
    local path = THEMES_DIR .. "/" .. name .. ".json"

    if isfile(path) then
      local ok, data = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(readfile(path))
      end)

      if ok and data then return data end
    end

    return nil
  end


  
    -- ── Apply a custom theme data table to the live UI ─────────
    local function applyCustomData(data)
        local accent = hex3c(data.accentHex or "#39FF14")
        MatchaUI.SetAccentColor(accent)
        for _, k in ipairs(THEME_SLOT_KEYS) do
            if data[k] then
                MatchaUI.SetThemeColor(k, hex3c(data[k]))
            end
        end
    end

    -- ── Apply a built-in preset ────────────────────────────────
    local function applyBuiltinPreset(name)
        local p = builtinPresets[name]
        if not p then return false end
        MatchaUI.SetAccentColor(p.accent or hex3c("#39FF14"))
        for _, k in ipairs(THEME_SLOT_KEYS) do
            if p[k] then MatchaUI.SetThemeColor(k, p[k]) end
        end
        return true
    end

    -- Widget handles populated after the category is built — used by applyConfig.
    -- Forward-declared so applyConfig can reference them whether called early or late.
    local kbWidget   = nil   -- Keybind widget in Config cat
    local cpAccent   = nil   -- Accent ColorPicker widget in Config cat
    local ddFont     = nil   -- Font dropdown widget in Config cat
    local ddPreset   = nil   -- Preset dropdown widget in Config cat
    local cpThemeKey = nil   -- Theme Key ColorPicker widget in Config cat
    local ddThemeKey = nil   -- Theme Key dropdown widget in Config cat

    -- ── Load saved config and push to live UI ──────────────────
    -- Also syncs all Config-category widget display states so the
    -- UI looks correct immediately on startup without user interaction.
    local function applyConfig(cfg)
        -- 1. Preset / custom theme
        local pname = cfg.ThemePreset or DEFAULT.ThemePreset
        if not applyBuiltinPreset(pname) then
            local data = loadCustomTheme(pname)
            if data then applyCustomData(data) end
        end
        -- 2. Per-slot ThemeColors (individual overrides saved by the Theme Key picker).
        --    These are applied ON TOP of the preset so manual edits persist across restarts.
        local tc = cfg.ThemeColors or {}
        for _, k in ipairs(THEME_SLOT_KEYS) do
            if tc[k] then
                MatchaUI.SetThemeColor(k, hex3c(tc[k]))
            end
        end
        -- 3. Accent (overrides preset accent)
        if cfg.AccentHex then
            MatchaUI.SetAccentColor(hex3c(cfg.AccentHex))
        end
        -- 4. Font
        if cfg.Font then
            MatchaUI.SetFont(cfg.Font)
        end
        -- 5. Keybind handle + display text (external handle passed via opts)
        if cfg.ToggleKeybindVK and kbHandle then
            kbHandle.Key = cfg.ToggleKeybindVK
            local kname = KeyNames[cfg.ToggleKeybindVK]
                or ("VK"..tostring(cfg.ToggleKeybindVK))
            if kbHandle._kbTxt then
                kbHandle._kbTxt.Text = "[ "..kname.." ]"
            end
        end
        -- 6. Sync Config-category widget visuals so they reflect the loaded state.
        --    These widgets are nil during the first applyConfig call (before the category
        --    is built), so guard each access. A second call from ── Auto-load ── below
        --    fires after the widgets exist and restores all display states.
        -- 6a. Keybind widget text
        if kbWidget and cfg.ToggleKeybindVK then
            local kname = KeyNames[cfg.ToggleKeybindVK]
                or ("VK"..tostring(cfg.ToggleKeybindVK))
            if kbWidget._kbTxt then
                kbWidget._kbTxt.Text = "[ "..kname.." ]"
            end
            kbWidget.Key = cfg.ToggleKeybindVK
        end
        -- 6b. Accent ColorPicker preview swatch
        if cpAccent and cfg.AccentHex then
            cpAccent.Color   = hex3c(cfg.AccentHex)
            cpAccent._preview.Color = cpAccent.Color
            if cpAccent._prevPatch then cpAccent._prevPatch.Color = cpAccent.Color end
        end
        -- 6c. Font dropdown selected text
        if ddFont and cfg.Font then
            ddFont.Selected   = cfg.Font
            if ddFont._selTxt then ddFont._selTxt.Text = cfg.Font end
        end
        -- 6d. Preset dropdown selected text
        if ddPreset and cfg.ThemePreset then
            ddPreset.Selected = cfg.ThemePreset
            if ddPreset._selTxt then ddPreset._selTxt.Text = cfg.ThemePreset end
        end
        -- 6e. Theme Key ColorPicker: update its preview to match the currently selected key's color.
        --     The actual color is whatever the live Theme table has after step 2+3 above.
        if cpThemeKey and ddThemeKey then
            local selKey = ddThemeKey.Selected or THEME_SLOT_KEYS[1]
            local liveColor = Theme and Theme[selKey]
            if liveColor then
              cpThemeKey.Color = liveColor
                if cpThemeKey._preview  then cpThemeKey._preview.Color  = liveColor end
                if cpThemeKey._prevPatch then cpThemeKey._prevPatch.Color = liveColor end
            end
        end
    end

    -- ── Build preset list ──────────────────────────────────────
    local function buildPresetList()
        local list = {}
        for name in pairs(builtinPresets) do table.insert(list, name) end
        table.sort(list)
        for _, name in ipairs(listCustomThemes()) do
            table.insert(list, name)
        end
        return list
    end

    -- ── Create category ────────────────────────────────────────
    local cat = win.AddCategory("Config")

    -- Section: Toggle Keybind
    win.AddSection(cat, "Toggle UI Keybind")
    kbWidget = win.AddKeybind(cat, "Toggle Keybind",
        _cfg.ToggleKeybindVK, function(key, name)
            if kbHandle then
                kbHandle.Key = key
                if kbHandle._kbTxt then
                    kbHandle._kbTxt.Text = "[ "..name.." ]"
                end
            end
            _cfg.ToggleKeybindVK = key
            saveConfig()
        end)
    win.AddTooltip(kbWidget, "Auto-saved. Also syncs the live Toggle keybind.")

    -- Section: Accent Color
    win.AddSection(cat, "Accent Color")
    cpAccent = win.AddColorPicker(cat, "Accent Color",
        hex3c(_cfg.AccentHex), function(color)
            MatchaUI.SetAccentColor(color)
            _cfg.AccentHex = c3hex(color)
            saveConfig()
        end)
    win.AddTooltip(cpAccent, "Auto-saved. Applied on top of the active preset.")

    -- Section: Theme Key
    -- Mirrors the ExampleUsage Theme Editor workflow: pick a Theme slot from the
    -- dropdown, then open the ColorPicker to change that slot's color live.
    -- Every change is persisted in _cfg.ThemeColors so it survives a restart.
    win.AddSection(cat, "Theme Key Color")
    local _selectedThemeKey = THEME_SLOT_KEYS[1]
    ddThemeKey = win.AddDropdown(cat, "Theme Key",
        THEME_SLOT_KEYS,
        THEME_SLOT_KEYS[1],
        function(sel)
            _selectedThemeKey = sel
            -- Update the color picker preview to reflect the live color of this slot
            local liveColor = Theme and Theme[sel]
            if liveColor and cpThemeKey then
                cpThemeKey.Color = liveColor
                if cpThemeKey._preview  then cpThemeKey._preview.Color  = liveColor end
                if cpThemeKey._prevPatch then cpThemeKey._prevPatch.Color = liveColor end
                -- Sync the channel sliders if the panel is currently open
                if cpThemeKey._cpOpen then
                    cpThemeKey._refreshAll()
                end
            end
        end)
    win.AddTooltip(ddThemeKey, "Choose which Theme color slot to edit, then pick a color below.")

    cpThemeKey = win.AddColorPicker(cat, "New Color",
        hex3c(_cfg.ThemeColors[THEME_SLOT_KEYS[1]] or "#141414"),
        function(color)
            MatchaUI.SetThemeColor(_selectedThemeKey, color)
            _cfg.ThemeColors[_selectedThemeKey] = c3hex(color)
            saveConfig()
            MatchaUI.Notify("Theme: ".._selectedThemeKey,
                string.format("RGB(%d,%d,%d)",
                    math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)), 2)
        end)
    win.AddTooltip(cpThemeKey, "Opens the color picker. Chosen color is applied to the selected Theme key instantly and auto-saved.")

    -- Section: Font
    win.AddSection(cat, "Font")
    local FONT_LIST = {"UI","System","SystemBold","Minecraft","Monospace","Pixel","Fortnite"}
    ddFont = win.AddDropdown(cat, "Global Font",
        FONT_LIST, _cfg.Font or "Monospace", function(sel)
            MatchaUI.SetFont(sel)
            _cfg.Font = sel
            saveConfig()
        end)
    win.AddTooltip(ddFont, "Auto-saved. Changes all text in the UI immediately.")

    -- Section: Preset
    win.AddSection(cat, "Preset")
    local presetList = buildPresetList()
    ddPreset = win.AddDropdown(cat, "Load Preset",
        #presetList > 0 and presetList or {"(none)"},
        _cfg.ThemePreset or (presetList[1] or "(none)"),
        function(sel)
            -- Clear all individual ThemeKey overrides so the preset applies to ALL keys cleanly.
            -- If the user wants per-slot edits after loading a preset, they can use the ThemeKey
            -- picker again — those edits will be saved fresh.
            _cfg.ThemeColors = {}

            if builtinPresets[sel] then
                applyBuiltinPreset(sel)
                -- Sync accent from preset into _cfg
                local p = builtinPresets[sel]
                if p.accent then _cfg.AccentHex = c3hex(p.accent) end
            else
                local data = loadCustomTheme(sel)
                if data then
                    applyCustomData(data)
                    if data.accentHex then _cfg.AccentHex = data.accentHex end
                    MatchaUI.Notify("Theme", sel.." loaded", 3)
                else
                    MatchaUI.Notify("Theme", sel.." not found", 3)
                end
            end

            _cfg.ThemePreset = sel
            saveConfig()

            -- Sync widget previews to reflect the newly loaded preset
            if cpAccent then
                local newAccent = hex3c(_cfg.AccentHex)
                cpAccent.Color = newAccent
                if cpAccent._preview   then cpAccent._preview.Color   = newAccent end
                if cpAccent._prevPatch then cpAccent._prevPatch.Color  = newAccent end
            end
            if cpThemeKey and ddThemeKey then
                local selKey = ddThemeKey.Selected or THEME_SLOT_KEYS[1]
                local liveColor = Theme and Theme[selKey]
                if liveColor then
                    cpThemeKey.Color = liveColor
                    if cpThemeKey._preview   then cpThemeKey._preview.Color   = liveColor end
                    if cpThemeKey._prevPatch then cpThemeKey._prevPatch.Color  = liveColor end
                end
            end
        end)
    win.AddTooltip(ddPreset, "Built-in presets + any saved custom themes. Auto-saved.")

    -- Section: Save custom theme
    win.AddSection(cat, "Save custom theme")
    local _themeName = ""
    local inputName = win.AddTextInput(cat, "Theme name", "Enter name...", function(text)
        _themeName = text
    end)
    win.AddTooltip(inputName, "Type a name, then press Save Theme below.")

    local btnSave = win.AddButton(cat, "Save Theme", function()
        local name = _themeName:gsub("[/\\\"'%s]", "_")
        if name == "" then
            MatchaUI.Notify("Save Theme", "Enter a name first.", 2)
            return
        end
        -- Save a complete snapshot: accent + all individual ThemeColor overrides
        saveCustomTheme(name, _cfg.AccentHex, _cfg.ThemeColors)
        MatchaUI.Notify("Theme saved", name..".json in "..THEMES_DIR, 3)
    end)
    win.AddTooltip(btnSave,
        "Saves current accent + all Theme Key edits as a reloadable theme file.")

    -- ── Auto-load from disk right now ─────────────────────────
    -- All Config-category widgets are now built, so applyConfig can sync their displays.
    local saved = readConfig()
    for k, v in pairs(saved) do _cfg[k] = v end
    -- Ensure ThemeColors sub-table is always present (old config files may lack it)
    if type(_cfg.ThemeColors) ~= "table" then _cfg.ThemeColors = {} end
    applyConfig(_cfg)

    -- ── Internal toggle polling (only when no external handle was supplied) ──
    -- When the caller does not pass toggleKeybind, the Config-category keybind
    -- widget (kbWidget) IS the toggle.  A background thread polls it and
    -- shows/hides the window — identical to what ExampleUsage does externally.
    if not opts.toggleKeybind then
        task.spawn(function()
            local lastDown = false
            while true do
                task.wait(0.05)
                if isrbxactive() and kbWidget then
                    local down = iskeypressed(kbWidget.Key)
                    if down and not lastDown then
                        win.SetVisible(not win.Visible)
                        MatchaUI.Notify(
                            win.Visible and "UI Shown" or "UI Hidden",
                            "Bound to VK " .. tostring(kbWidget.Key),
                            2
                        )
                    end
                    lastDown = down
                end
            end
        end)
    end

    return cat
end


function MatchaUI.SetAccentColor(color)
  AccentColor = color
  Theme.CategoryActive = color
  Theme.AccentOn = color
  Theme.SliderFill = color
  Theme.InputBorder = color
  Theme.NotifBorder = color
  Theme.ScrollThumb = color
  Theme.SectionText = color

  -- Repaint all registered accent-colored objects
  for _, obj in ipairs(_accentObjects) do
    pcall(function() obj.Color = color end)
  end

  -- Repaint toggle tracks that are currently ON
  for _, win in ipairs(_windows) do
    for _, elem in ipairs(win._elements) do
      if elem.Type == "Toggle" and elem.State and elem._track then
        pcall(function() elem._track.Color = color end)
      end
    end

    -- Active category bg
    if win.ActiveCat and win.ActiveCat._bg then
      pcall(function() win.ActiveCat._bg.Color = color end)
    end
  end

  -- Repaint notification accent bars currently on screen
  for _, n in ipairs(_notifs) do
    pcall(function() n._bar.Color = color end)
    pcall(function() n._title.Color = color end)
  end
end


-- ─────────────────────────────────────────────────────────────
-- SET THEME COLOR
-- ─────────────────────────────────────────────────────────────
-- Change any Theme key (Background, TopBar, LeftBar, TextPrimary, etc.)
-- and repaint all currently-visible Drawing objects that use that color.
-- For accent-linked keys (AccentOn, SliderFill, etc.) prefer SetAccentColor.
-- @param key    string   — Theme table key (e.g. "Background", "TopBar")
-- @param color  Color3   — new color value

function MatchaUI.SetThemeColor(key, color)
  if Theme[key] == nil then
    warn("MatchaUI.SetThemeColor: unknown theme key '" .. tostring(key) .. "'")
    return
  end

  Theme[key] = color

  -- Repaint all objects registered under this exact theme key.
  -- No color-comparison needed — each object is directly tagged to its key.
  local list = _themeObjects[key]
  if list then
    for _, obj in ipairs(list) do
      pcall(function() obj.Color = color end)
    end
  end
end



function MatchaUI.SetFont(fontName)
  local fontMap = {
    UI = Drawing.Fonts.UI,
    System = Drawing.Fonts.System,
    SystemBold = Drawing.Fonts.SystemBold,
    Minecraft = Drawing.Fonts.Minecraft,
    Monospace = Drawing.Fonts.Monospace,
    Pixel = Drawing.Fonts.Pixel,
    Fortnite = Drawing.Fonts.Fortnite,
  }

  local font = fontMap[fontName]

  if not font then
    warn("MatchaUI.SetFont: unknown font '" .. tostring(fontName) ..". Valid options: UI, System, SystemBold, Minecraft, Monospace, Pixel, Fortnite")
    return
  end

  _currentFont = font


  for _, obj in ipairs(_textObjects) do
    pcall(function() obj.Font = font end)
  end
end

local VALID_CHARS = {}
do
  local s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-_@#%&*()[]<>:;'/\\"
  for i = 1, #s do
    VALID_CHARS[s:sub(i, i)] = true
  end
end

MatchaUI.CreateWindow()





















local _sliderDrag = nil  -- currently dragged slider elem
local _cursorBlink = 0
local _prevHeldKeys   = {}  -- VK keys held last frame (for edge detection in text input)
local _keyRepeatTimer = {}  -- per-key hold timer (seconds)
local _keyRepeatFired = {}  -- whether the key generated at least one character

local RunService = game:GetService("RunService")

--#endregion
function MatchaUI.Run()
  RunService.RenderStepped:Connect(function()
    if not isrbxactive() then
      _lastMouse1 = false
      _mouseJustDown = false
      _mouseJustUp   = false
    else
      local mouse1   = ismouse1pressed()
      local mPos     = Vector2.new(Mouse.X, Mouse.Y)
      _mouseJustDown = mouse1 and not _lastMouse1
      _mouseJustUp   = not mouse1 and _lastMouse1

      -- ── Cursor blink for focused inputs
      _cursorBlink = _cursorBlink + 0.016
      if _focusedInput and _focusedInput._cursor then
        _focusedInput._cursor.Visible = (_cursorBlink % 1) < 0.5
      end

      -- ── Notifications: tick down and shrink bar
      local i = 1
      while i <= #_notifs do
        local n = _notifs[i]
        n._timer = n._timer + 0.016
        local pct = 1 - (n._timer / n._duration)
        n._bar.Size = Vector2.new(math.max(0, NOTIF_W * pct), 4)

        if n._timer >= n._duration then
          n._bg:Remove()
          n._title:Remove()
          for _, lObj in ipairs(n._msgLines) do
            lObj:Remove()
          end
          n._bar:Remove()
          table.remove(_notifs, i)
          _layoutNotifs()
        else
          i = i + 1
        end
      end

      -- ── Tooltip handling
      for _, tip in ipairs(_tooltips) do
        local e = tip._elem
        if e and e._x then
          local catActive = false

          if e._cat then
            for _, w in ipairs(_windows) do
              if w.Visible and not w.Minimized and w.ActiveCat == e._cat then
                catActive = true
                break
              end
            end
          else
            catActive = true
          end

          local hover = catActive and isInBoxBounds(
            mPos.X, mPos.Y,
            e._x, e._y, e._w, e._h
          )

          tip._bg.Visible  = hover
          tip._txt.Visible = hover

          if hover then
            tip._bg.Position  = Vector2.new(mPos.X + 12, mPos.Y - 24)
            tip._txt.Position = Vector2.new(mPos.X + 18, mPos.Y - 20)
          end
        end
      end

      -- ── Per-window processing
      local _choosingThisFrame = MatchaUI.Choosing

      for _, win in ipairs(_windows) do
        if not win.Visible then
          continue
        end

        -- Drag window (topbar)
        if _mouseJustDown and isInBoxBounds(
          mPos.X, mPos.Y,
          win.X, win.Y, win.W, win._topBarH
        ) then

          local onMin = isInBoxBounds(
            mPos.X, mPos.Y,
            win._minBtnX, win._minBtnY,
            win._minBtnW, win._minBtnH
          )

          local onClose = isInBoxBounds(
            mPos.X, mPos.Y,
            win._closeBtnX, win._closeBtnY,
            win._closeBtnW, win._closeBtnH
          )

          if not onMin and not onClose then
            win.Dragging = true
            win.DragOffX = mPos.X - win.X
            win.DragOffY = mPos.Y - win.Y
          end
        end

        if _mouseJustUp then
          win.Dragging = false
        end

        if win.Dragging and mouse1 then
          local nx = mPos.X - win.DragOffX
          local ny = mPos.Y - win.DragOffY

          win.Reposition(nx, ny)

          win._minBtnX   = nx + win.W - 52
          win._minBtnY   = ny + 6
          win._closeBtnX = nx + win.W - 26
          win._closeBtnY = ny + 6
        end

        -- Minimize / Close
        if _mouseJustDown then
          if isInBoxBounds(
            mPos.X, mPos.Y,
            win._minBtnX, win._minBtnY,
            win._minBtnW, win._minBtnH
          ) then
            win.Minimize()
          end

          if isInBoxBounds(
            mPos.X, mPos.Y,
            win._closeBtnX, win._closeBtnY,
            win._closeBtnW, win._closeBtnH
          ) then
            win.SetVisible(false)
          end
        end

        if win.Minimized then
          continue
        end

        -- Category selection
        if _mouseJustDown then
          for _, cat in ipairs(win.Categories) do
            if isInBoxBounds(
              mPos.X, mPos.Y,
              cat._bg.Position.X, cat._bg.Position.Y,
              cat._bg.Size.X, cat._bg.Size.Y
            ) then
              win._activateCategory(cat)
            end
          end
        end

        -- Element interactions
        for _, elem in ipairs(win._elements) do
          if elem._cat ~= win.ActiveCat then
            continue
          end

          if not elem._inScrollFrame then
            if not elem._bg or not elem._bg.Visible then
              continue
            end
          else
            local inFrame = false

            for _, wElemWrap in ipairs(win._elements) do
              if wElemWrap.Type == "ScrollFrame" then
                for _, widget in ipairs(wElemWrap._widgets) do
                  if widget._elem == elem then
                    local insideFrame = isInBoxBounds(
                      mPos.X, mPos.Y,
                      wElemWrap._x, wElemWrap._y,
                      wElemWrap._w - 8, wElemWrap._h
                    )

                    local insidePanel = false

                    if elem.Type == "ColorPicker" and elem._cpOpen then
                      insidePanel = isInBoxBounds(
                        mPos.X, mPos.Y,
                        elem._panelX, elem._panelY,
                        elem._panelW, elem._panelH
                      )
                    end

                    inFrame = insideFrame or insidePanel
                    break
                  end
                end

                if inFrame ~= false then
                  break
                end
              end
            end

            if not inFrame then
              continue
            end
          end
                    -- BUTTON (disabled while a dropdown is open)
          if elem.Type == "Button" and _mouseJustDown and not _choosingThisFrame then
            if isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w, elem._h) then
              if elem.Callback then pcall(elem.Callback) end
            end
          end

          -- TOGGLE (disabled while a dropdown is open)
          if elem.Type == "Toggle" and _mouseJustDown and not _choosingThisFrame then
            if isInBoxBounds(mPos.X, mPos.Y, elem._tx, elem._ty, elem._trackW, elem._trackH) then
              elem.State = not elem.State
              elem._track.Color = elem.State and Theme.AccentOn or Theme.AccentOff
              local kx = elem.State
                and (elem._tx + elem._trackW - elem._knobSz - 2)
                or  (elem._tx + 2)
              elem._knob.Position = Vector2.new(kx, elem._ty + 2)
              if elem.Callback then pcall(elem.Callback, elem.State) end
            end
          end

          -- CHECKBOX (disabled while a dropdown is open)
          if elem.Type == "Checkbox" and _mouseJustDown and not _choosingThisFrame then
            if isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w, elem._h) then
              elem.State = not elem.State
              elem._check.Visible = elem.State
              if elem.Callback then pcall(elem.Callback, elem.State) end
            end
          end

          -- SLIDER drag start (disabled while a dropdown is open)
          if elem.Type == "Slider" and _mouseJustDown and _sliderDrag == nil and not _choosingThisFrame then
            if isInBoxBounds(mPos.X, mPos.Y, elem._trackX, elem._trackY - 6, elem._trackW, 16) then
              _sliderDrag = elem
            end
          end

          -- DROPDOWN
          if elem.Type == "Dropdown" and _mouseJustDown then
            if isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w, elem._h) then
              elem._isOpen = not elem._isOpen

              if elem._isOpen then
                MatchaUI.Choosing = true

                local bgPos = elem._bg.Position
                local boxLeft = bgPos.X + elem._bg.Size.X - elem._w
                local boxTop  = bgPos.Y + elem._h

                for _, item in ipairs(elem._itemObjs) do
                  local iy = boxTop + (item._idx - 1) * 22

                  item._bg.Position  = Vector2.new(boxLeft, iy)
                  item._txt.Position = Vector2.new(boxLeft + 4, iy + 4)

                  item._x = boxLeft
                  item._y = iy

                  item._bg.Visible  = true
                  item._txt.Visible = true
                end

              else
                MatchaUI.Choosing = false

                for _, item in ipairs(elem._itemObjs) do
                  item._bg.Visible  = false
                  item._txt.Visible = false
                end
              end

              elem._arrow.Text = elem._isOpen and "^" or "v"

            elseif elem._isOpen then
              local _hit = false

              for _, item in ipairs(elem._itemObjs) do
                if isInBoxBounds(mPos.X, mPos.Y, item._x, item._y, elem._w, 22) then
                  elem.Selected     = item._value
                  elem._selTxt.Text = item._value
                  _hit = true

                  if elem.Callback then
                    pcall(elem.Callback, item._value)
                  end
                end
              end

              elem._isOpen = false
              MatchaUI.Choosing = false
              elem._arrow.Text = "v"

              for _, item in ipairs(elem._itemObjs) do
                item._bg.Visible  = false
                item._txt.Visible = false
              end
            end
          end

          -- KEYBIND
          if elem.Type == "Keybind" then
            if _mouseJustDown and not _choosingThisFrame and isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w, elem._h) then
              elem._pendingListen = true
              elem.Listening = false
              elem._kbTxt.Text  = "..."
              elem._kbTxt.Color = Theme.AccentOn
            end

            if elem._pendingListen and _mouseJustUp then
              elem._pendingListen = false
              elem.Listening = true
            end

            if elem.Listening then
              for k, _ in pairs(VALID_KEYBIND_KEYS) do
                if iskeypressed(k) then
                  elem.Key = k
                  elem.Listening = false

                  local name = KeyNames[k] or "?"
                  elem._kbTxt.Text  = "[ " .. name .. " ]"
                  elem._kbTxt.Color = Theme.TextPrimary

                  if elem.Callback then
                    pcall(elem.Callback, k, name)
                  end

                  break
                end
              end
            end
          end

          -- TEXT INPUT / SEARCH BAR
          if elem.Type == "TextInput" then
            if _mouseJustDown and not _choosingThisFrame then
              if isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w, elem._h) then
                if _focusedInput ~= elem then
                  if _focusedInput then
                    _focusedInput.Focused = false
                    if _focusedInput._cursor then
                      _focusedInput._cursor.Visible = false
                    end
                  end

                  _focusedInput = elem
                  elem.Focused = true
                  _cursorBlink = 0

                  if elem._inputBg then
                    elem._inputBg.Color = Theme.InputBg
                  end
                end

              elseif elem == _focusedInput then
                _focusedInput = nil
                elem.Focused = false

                if elem._cursor then
                  elem._cursor.Visible = false
                end

                setrobloxinput(true)
              end
            end

            if _mouseJustUp and elem == _focusedInput then
              setrobloxinput(false)
            end
          end

          -- COLOR PICKER
          if elem.Type == "ColorPicker" then
            local function setPanelVis(state)
              elem._panelBg.Visible     = state
              elem._panelBorder.Visible = state

              for _, sw in ipairs(elem._paletteSwatch or {}) do
                pcall(function()
                  sw._r.Visible = state
                end)
              end

              local cs = elem._channelSliders or {}
              for _, ch in ipairs({"R","G","B"}) do
                local s = cs[ch]
                if s then
                  s._lbl.Visible = state
                  s._val.Visible = state
                  s._bg.Visible  = state
                  s._fill.Visible = state
                  s._knob.Visible = state
                end
              end

              elem._hexLabel.Visible  = state
              elem._prevPatch.Visible = state
            end

            if _mouseJustDown and isInBoxBounds(mPos.X, mPos.Y, elem._headerX, elem._headerY, elem._headerW, elem._headerH) then
              elem._cpOpen = not elem._cpOpen
              elem._arrowTxt.Text = elem._cpOpen and "<" or ">"

              if elem._cpOpen then
                local bgPos = elem._bg.Position
                local newPanelX = win.X + win.W + 4
                local newPanelY = bgPos.Y

                pcall(function()
                  elem._panelBg.Position     = Vector2.new(newPanelX, newPanelY)
                  elem._panelBorder.Position = Vector2.new(newPanelX, newPanelY)
                end)

                local offsets = elem._panelObjOffsets or {}
                for _, po in ipairs(elem._panelObjs or {}) do
                  local off = offsets[i]
                  if off then
                    pcall(function()
                      po.Position = Vector2.new(newPanelX + off.dx, newPanelY + off.dy)
                    end)
                  end
                end

                for _, sw in ipairs(elem._paletteSwatch or {}) do
                  if sw._origDX then
                    sw._x = newPanelX + sw._origDX
                    sw._y = newPanelY + sw._origDY
                  end
                end

                local cs = elem._channelSliders or {}
                for _, s in pairs(cs) do
                  if s._origTrackDX then s._trackX = newPanelX + s._origTrackDX end
                  if s._origKnobDY  then s._knobY  = newPanelY + s._origKnobDY  end
                  if s._origRowDY   then s._rowY   = newPanelY + s._origRowDY   end
                end

                for _, btn in ipairs(elem._btnObjs or {}) do
                  if btn._origDX then btn._x = newPanelX + btn._origDX end
                  if btn._origDY then btn._y = newPanelY + btn._origDY end
                  if btn._origTrackDX then btn._trackX = newPanelX + btn._origTrackDX end
                  if btn._origKnobDY then btn._knobY = newPanelY + btn._origKnobDY end
                end

                elem._panelX = newPanelX
                elem._panelY = newPanelY

                setPanelVis(true)

              else
                setPanelVis(false)
              end
            end

            if elem._cpOpen then
              if _mouseJustDown then
                local inHeader = isInBoxBounds(mPos.X, mPos.Y, elem._headerX, elem._headerY, elem._headerW, elem._headerH)
                local inPanel  = isInBoxBounds(mPos.X, mPos.Y, elem._panelX, elem._panelY, elem._panelW, elem._panelH)

                if not inHeader and not inPanel then
                  elem._cpOpen = false
                  elem._arrowTxt.Text = ">"
                  setPanelVis(false)
                end
              end

              if _mouseJustDown then
                for _, sw in ipairs(elem._paletteSwatch or {}) do
                  if isInBoxBounds(mPos.X, mPos.Y, sw._x, sw._y, sw._w, sw._h) then
                    elem.Color = sw._color
                    elem._refreshAll()
                    break
                  end
                end
              end

              if _mouseJustDown and elem._cpDragCh == nil then
                for _, btn in ipairs(elem._btnObjs or {}) do
                  if btn._isSlider and isInBoxBounds(mPos.X, mPos.Y, btn._x, btn._y, btn._w, btn._h) then
                    elem._cpDragCh  = btn._ch
                    elem._cpDragBtn = btn
                    break
                  end
                end
              end

              if elem._cpDragCh and mouse1 then
                local btn2 = elem._cpDragBtn
                local relX = math.max(0, math.min(mPos.X - btn2._trackX, btn2._trackW))
                local pct2 = relX / btn2._trackW
                local newV = math.floor(pct2 * 255)

                local c = elem.Color
                local rv = math.floor(c.R * 255)
                local gv = math.floor(c.G * 255)
                local bv = math.floor(c.B * 255)

                if elem._cpDragCh == "R" then rv = newV
                elseif elem._cpDragCh == "G" then gv = newV
                else bv = newV end

                elem.Color = Color3.fromRGB(rv, gv, bv)
                elem._refreshAll()

              elseif not mouse1 then
                elem._cpDragCh  = nil
                elem._cpDragBtn = nil
              end
            end
          end
          -- SCROLL FRAME: content drag (anywhere in frame) + scrollbar thumb drag
          if elem.Type == "ScrollFrame" then
            local sbX = elem._sbX
            local sbW = 8

            if _mouseJustDown then
              if isInBoxBounds(mPos.X, mPos.Y, sbX, elem._y, sbW, elem._h) then
                elem._thumbDragging   = true
                elem._contentDragging = false

                local maxScroll = math.max(1, elem._innerH - elem._h)
                local thumbMaxY = math.max(1, elem._h - elem._thumbH)
                local thumbTopY = elem._y + (elem._scrollY / maxScroll) * thumbMaxY

                elem._thumbDragOffY = mPos.Y - thumbTopY

              elseif isInBoxBounds(mPos.X, mPos.Y, elem._x, elem._y, elem._w - sbW, elem._h) then
                local onColorPickerHeader = false

                for _, widget in ipairs(elem._widgets) do
                  local wElem = widget._elem

                  if wElem.Type == "ColorPicker" and wElem._headerX then
                    if isInBoxBounds(
                      mPos.X, mPos.Y,
                      wElem._headerX, wElem._headerY,
                      wElem._headerW, wElem._headerH
                    ) then
                      onColorPickerHeader = true
                      break
                    end
                  end
                end

                if not onColorPickerHeader then
                  elem._contentDragging = true
                  elem._thumbDragging   = false
                  elem._contentDragStartY      = mPos.Y
                  elem._contentDragStartScroll = elem._scrollY
                end
              end
            end

            if _mouseJustUp then
              elem._thumbDragging   = false
              elem._contentDragging = false
            end

            if elem._thumbDragging and mouse1 then
              local maxScroll = math.max(1, elem._innerH - elem._h)
              local thumbMaxY = math.max(1, elem._h - elem._thumbH)

              local rawY     = mPos.Y - elem._thumbDragOffY
              local clampedY = math.max(elem._y, math.min(elem._y + thumbMaxY, rawY))

              elem._thumb.Position = Vector2.new(sbX, clampedY)

              local pct = (clampedY - elem._y) / thumbMaxY
              elem._scrollY = pct * maxScroll

              if elem.Callback then
                pcall(elem.Callback, elem._scrollY)
              end
            end

            if elem._contentDragging and mouse1 then
              local maxScroll = math.max(0, elem._innerH - elem._h)
              local dy = mPos.Y - elem._contentDragStartY

              local newScroll = math.max(
                0,
                math.min(maxScroll, elem._contentDragStartScroll - dy)
              )

              elem._scrollY = newScroll

              local thumbMaxY = math.max(1, elem._h - elem._thumbH)
              local pct = maxScroll > 0 and newScroll / maxScroll or 0

              elem._thumb.Position = Vector2.new(
                sbX,
                elem._y + pct * thumbMaxY
              )

              if elem.Callback then
                pcall(elem.Callback, elem._scrollY)
              end
            end

            if elem._items then
              for _, item in ipairs(elem._items) do
                local absY = elem._y + item._relY - elem._scrollY

                item._txt.Position = Vector2.new(elem._x + 6, absY)

                local itemH = elem._itemH or 18
                item._txt.Visible =
                  (absY >= elem._y) and
                  (absY + itemH <= elem._y + elem._h)
              end
            end

            if elem._widgets then
              for _, widget in ipairs(elem._widgets) do
                local baseAbsY = elem._y + widget._relY - elem._scrollY
                local wElem    = widget._elem
                local wHeight  = widget._h or ELEM_H

                local dy = baseAbsY - (wElem._y or baseAbsY)

                if wElem._y then wElem._y = wElem._y + dy end
                if wElem._ty then wElem._ty = wElem._ty + dy end
                if wElem._trackY then wElem._trackY = wElem._trackY + dy end

                if wElem.Type == "Dropdown" and wElem._itemObjs then
                  for _, item in ipairs(wElem._itemObjs) do
                    if item._y then
                      item._y = item._y + dy
                    end
                  end
                end

                if wElem.Type == "ColorPicker" and wElem._origHeaderY then
                  local absHeaderY = baseAbsY

                  wElem._headerY = absHeaderY
                  wElem._y = absHeaderY

                  local origBase = wElem._origHeaderY

                  for _, btn in ipairs(wElem._btnObjs or {}) do
                    if btn._origDY then btn._y = baseAbsY + btn._origDY end
                    if btn._origKnobDY then btn._knobY = baseAbsY + btn._origKnobDY end
                  end

                  local cs2 = wElem._channelSliders or {}
                  for _, s2 in pairs(cs2) do
                    if s2._origKnobDY then s2._knobY = baseAbsY + s2._origKnobDY end
                    if s2._origRowDY then s2._rowY = baseAbsY + s2._origRowDY end
                  end
                end

                local pSet = widget._panelObjSet or {}

                for _, obj in ipairs(widget._objs) do
                  if pSet[obj] then continue end

                  pcall(function()
                    obj.Position = obj.Position + Vector2.new(0, dy)

                    local oY = obj.Position.Y
                    obj.Visible =
                      (oY >= elem._y) and
                      (oY + wHeight <= elem._y + elem._h)
                  end)
                end

                if wElem.Type == "Checkbox" and wElem._check then
                  if wElem._check.Visible then
                    wElem._check.Visible = wElem.State
                  end
                end

                if wElem.Type == "TextInput" and wElem._cursor then
                  if wElem._cursor.Visible and not wElem.Focused then
                    wElem._cursor.Visible = false
                  end
                end

                if wElem.Type == "ColorPicker" and not wElem._cpOpen then
                  for _, po in ipairs(wElem._panelObjs or {}) do
                    pcall(function()
                      po.Visible = false
                    end)
                  end

                elseif wElem.Type == "ColorPicker" and wElem._cpOpen then
                  for _, po in ipairs(wElem._panelObjs or {}) do
                    pcall(function()
                      po.Visible = true
                    end)
                  end
                end
              end
            end
          end

          -- SLIDER drag update (global, disabled while a dropdown is open)
          if _sliderDrag and not MatchaUI.Choosing then
            if mouse1 then
              local e    = _sliderDrag
              local relX = math.max(0, math.min(mPos.X - e._trackX, e._trackW))
              local pct  = relX / e._trackW
              local val  = e.Min + (e.Max - e.Min) * pct

              e.Value = val
              e._valLbl.Text = tostring(math.floor(val))
              e._fillRect.Size = Vector2.new(math.max(1, relX), 4)
              e._knob.Position = Vector2.new(
                e._trackX + relX - e._knobW / 2,
                e._trackY - 5
              )

              if e.Callback then
                pcall(e.Callback, val)
              end
            else
              _sliderDrag = nil
            end
          end

          -- Text input character handling
          if _focusedInput then
            local elem = _focusedInput

            local function refreshInputDisplay()
              local displayText = elem.Text == "" and elem._placeholder or elem.Text
              elem._inputTxt.Text = displayText
              elem._inputTxt.Color =
                elem.Text == "" and Theme.TextDisabled or Theme.TextPrimary

              if elem._cursor then
                local inputLeft  = elem._x + 4
                local inputRight = elem._x + elem._w - 6
                local cursorX = math.min(inputLeft + (#elem.Text * 7), inputRight)

                elem._cursor.Position =
                  Vector2.new(cursorX, elem._cursor.Position.Y)
              end

              if elem.Callback then
                pcall(elem.Callback, elem.Text)
              end
            end

            local SCAN_KEYS = {
              8,13,16,32,
              48,49,50,51,52,53,54,55,56,57,
              65,66,67,68,69,70,71,72,73,74,75,76,77,
              78,79,80,81,82,83,84,85,86,87,88,89,90,
              96,97,98,99,100,101,102,103,104,105,
              107,109,110,186,187,188,189,190,191,192,219,220,221,222
            }

            local heldSet = {}

            for _, k in ipairs(SCAN_KEYS) do
              if iskeypressed(k) then
                heldSet[k] = true
              end
            end

            local shift = heldSet[16]

            for k, _ in pairs(heldSet) do
              if not _prevHeldKeys[k] then
                _keyRepeatTimer[k] = 0
                _keyRepeatFired[k] = false

                local handled = false

                if k == 8 then
                  if #elem.Text > 0 then
                    elem.Text = elem.Text:sub(1, -2)
                    refreshInputDisplay()
                  end
                  handled = true

                elseif k == 13 then
                  elem.Focused = false
                  if elem._cursor then elem._cursor.Visible = false end
                  _focusedInput = nil
                  setrobloxinput(true)

                  if elem.Callback then
                    pcall(elem.Callback, elem.Text)
                  end
                  handled = true

                else
                  local char = nil

                  if k >= 65 and k <= 90 then
                    char = shift and string.char(k) or string.char(k + 32)

                  elseif k >= 48 and k <= 57 then
                    local digits = "0123456789"
                    local shifted = ")!@#$%^&*("
                    char = shift and shifted:sub(k - 47, k - 47)
                      or digits:sub(k - 47, k - 47)

                  elseif k == 32 then char = " "
                  elseif k == 190 or k == 110 then char = shift and ">" or "."
                  elseif k == 188 then char = shift and "<" or ","
                  elseif k == 189 or k == 109 then char = shift and "_" or "-"
                  elseif k == 191 then char = shift and "?" or "/"
                  elseif k == 186 then char = shift and ":" or ";"
                  elseif k == 222 then char = shift and '"' or "'"
                  elseif k == 219 then char = shift and "{" or "["
                  elseif k == 221 then char = shift and "}" or "]"
                  elseif k == 220 then char = shift and "|" or "\\"
                  elseif k == 187 or k == 107 then char = shift and "+" or "="
                  elseif k == 192 then char = shift and "~" or "`"

                  elseif k >= 96 and k <= 105 then
                    char = tostring(k - 96)
                  end

                  if char and VALID_CHARS[char] then
                    elem.Text = elem.Text .. char
                    refreshInputDisplay()
                    handled = true
                  end
                end

                _keyRepeatFired[k] = handled

              else
                if _keyRepeatFired[k] then
                  _keyRepeatTimer[k] = (_keyRepeatTimer[k] or 0) + 0.016
                  local delay = _keyRepeatTimer[k] < 0.5 and 0.5 or 0.05

                  if _keyRepeatTimer[k] >= delay then
                    _keyRepeatTimer[k] =
                      _keyRepeatTimer[k] < 0.5 and 0.5 or 0

                    if k == 8 and #elem.Text > 0 then
                      elem.Text = elem.Text:sub(1, -2)
                      refreshInputDisplay()
                    end
                  end
                end
              end
            end

            for k, _ in pairs(_prevHeldKeys) do
              if not heldSet[k] then
                _keyRepeatTimer[k] = nil
                _keyRepeatFired[k] = nil
              end
            end

            _prevHeldKeys = heldSet

          else
            _prevHeldKeys = {}
          end

          _lastMouse1 = mouse1
        end
      end
    end
  end)
end


function MatchaUI.Destroy()
  for _, obj in ipairs(_objects) do
    pcall(function() 
      obj:Remove() 
    end)
  end

  _objects  = {}
  _windows  = {}
  _notifs   = {}
  _tooltips = {}
end

_G.MatchaUI = MatchaUI
return MatchaUI
