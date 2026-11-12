-- 开发者菜单主文件：游戏内 NPC 编辑器。通过插件密语（"CDEV"）与 worldserver 模块 mod-ilusixn-devmenu 通信。
-- 输入 /dev 打开。仅限 GM 账号（服务器会校验）。
-- 原作者：ilusixn    汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local PFX = "CDEV"
local WHITE = "Interface\\Buttons\\WHITE8X8"
local FONT = "Fonts\\FRIZQT__.TTF"

IlusixnDevMenuDB = IlusixnDevMenuDB or {}

local C = {
    bg      = { 0.045, 0.05, 0.065, 0.97 },
    head    = { 0.07, 0.075, 0.095, 1 },
    panel   = { 0.085, 0.09, 0.11, 1 },
    panel2  = { 0.115, 0.12, 0.145, 1 },
    hover   = { 0.16, 0.17, 0.2, 1 },
    border  = { 0.2, 0.21, 0.25, 1 },
    accent  = { 1, 0.76, 0.22, 1 },
    accentD = { 0.35, 0.26, 0.06, 1 },
    danger  = { 0.85, 0.25, 0.25, 1 },
    dangerD = { 0.3, 0.07, 0.07, 1 },
    text    = { 0.93, 0.93, 0.96, 1 },
    dim     = { 0.58, 0.6, 0.67, 1 },
    good    = { 0.35, 0.85, 0.45, 1 },
    H = { 0.95, 0.32, 0.3, 1 }, F = { 0.35, 0.85, 0.45, 1 }, N = { 0.95, 0.83, 0.3, 1 }, C = { 0.68, 0.68, 0.7, 1 },
}
local REACT_NAME = { H = "敌对", F = "友好", N = "中立", C = "小动物" }

-- ------------------------------------------------------------------ widgets
local function Shown(f, v) if v then f:Show() else f:Hide() end end
local function Skin(f, bg, border)
    f:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    f:SetBackdropColor(unpack(bg or C.panel))
    f:SetBackdropBorderColor(unpack(border or C.border))
end

local function Text(parent, size, col, flags)
    local t = parent:CreateFontString(nil, "OVERLAY")
    t:SetFont(FONT, size or 12, flags or "")
    t:SetTextColor(unpack(col or C.text))
    t:SetJustifyH("LEFT")
    return t
end

local function Tip(f, title, line)
    f:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title, 1, 0.82, 0.2)
        if line then GameTooltip:AddLine(line, 0.85, 0.85, 0.9, true) end
        GameTooltip:Show()
    end)
    f:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

-- style: nil | "accent" | "danger" | "chip"
local function Button(parent, label, w, h, style, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h or 24)
    b.style = style
    local function paint()
        if b.disabled then
            Skin(b, C.panel, C.border); b.label:SetTextColor(0.4, 0.4, 0.45)
        elseif b.active then
            Skin(b, C.accentD, C.accent); b.label:SetTextColor(unpack(C.accent))
        elseif style == "accent" then
            Skin(b, b.hover and { 1, 0.82, 0.35, 1 } or C.accent, C.accent); b.label:SetTextColor(0.08, 0.06, 0.02)
        elseif style == "danger" then
            Skin(b, b.hover and C.danger or C.dangerD, C.danger); b.label:SetTextColor(1, 0.85, 0.85)
        else
            Skin(b, b.hover and C.hover or C.panel2, b.hover and C.accent or C.border); b.label:SetTextColor(unpack(C.text))
        end
    end
    b.label = Text(b, 11)
    b.label:SetPoint("CENTER")
    b.label:SetJustifyH("CENTER")
    b.label:SetText(label)
    b:SetScript("OnEnter", function() b.hover = true; paint() end)
    b:SetScript("OnLeave", function() b.hover = false; paint() end)
    b:SetScript("OnMouseDown", function() if not b.disabled then b.label:SetPoint("CENTER", 1, -1) end end)
    b:SetScript("OnMouseUp", function() b.label:SetPoint("CENTER") end)
    b:SetScript("OnClick", function(self, btn) if not b.disabled and onClick then onClick(self, btn) end end)
    function b:SetActive(on) b.active = on; paint() end
    function b:SetEnabledState(on) b.disabled = not on; paint() end
    function b:SetLabel(t) b.label:SetText(t) end
    paint()
    return b
end

local function Edit(parent, w, h, numeric, onEnter)
    local e = CreateFrame("EditBox", nil, parent)
    e:SetSize(w, h or 24)
    Skin(e, { 0.03, 0.035, 0.045, 1 }, C.border)
    e:SetFont(FONT, 12, "")
    e:SetTextColor(unpack(C.text))
    e:SetTextInsets(7, 7, 0, 0)
    e:SetAutoFocus(false)
    if numeric then e:SetNumeric(false) end
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus(); if onEnter then onEnter(self) end end)
    e:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(C.accent)) end)
    e:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(C.border)) end)
    e.ph = Text(e, 11, C.dim)
    e.ph:SetPoint("LEFT", 8, 0)
    e:SetScript("OnTextChanged", function(self) Shown(self.ph, self:GetText() == "") end)
    function e:SetPlaceholder(t) self.ph:SetText(t) end
    return e
end

local function Check(parent, label, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(16, 16)
    Skin(b, { 0.03, 0.035, 0.045, 1 }, C.border)
    b.mark = b:CreateTexture(nil, "OVERLAY")
    b.mark:SetTexture(WHITE)
    b.mark:SetVertexColor(unpack(C.accent))
    b.mark:SetPoint("TOPLEFT", 3, -3)
    b.mark:SetPoint("BOTTOMRIGHT", -3, 3)
    b.text = Text(b, 11, C.dim)
    b.text:SetPoint("LEFT", b, "RIGHT", 6, 0)
    b.text:SetText(label)
    function b:Set(v) self.value = v; Shown(self.mark, v) end
    b:SetScript("OnClick", function(self) self:Set(not self.value); if onClick then onClick(self.value) end end)
    b:SetHitRectInsets(0, -(b.text:GetStringWidth() + 8), 0, 0)
    b:Set(false)
    return b
end

local function Header(parent, text)
    local t = Text(parent, 12, C.accent)
    t:SetText(text:upper())
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture(WHITE)
    line:SetVertexColor(C.border[1], C.border[2], C.border[3], 1)
    line:SetHeight(1)
    line:SetPoint("LEFT", t, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -14, 0)
    return t
end

local function Card(parent)
    local f = CreateFrame("Frame", nil, parent)
    Skin(f, C.panel, C.border)
    return f
end

-- ------------------------------------------------------------------ 通信
-- 按 UTF-8 字符边界切分，避免中文字符被截断成乱码
local function Utf8Chunks(s, maxBytes)
    local out, start, bytes = {}, 1, 0
    local i = 1
    while i <= #s do
        local c = s:byte(i)
        local n = c < 0x80 and 1 or (c < 0xE0 and 2 or (c < 0xF0 and 3 or 4))
        if bytes + n > maxBytes and i > start then
            out[#out + 1] = s:sub(start, i - 1)
            start, bytes = i, 0
        end
        bytes = bytes + n
        i = i + n
    end
    if i > start then out[#out + 1] = s:sub(start) end
    return out
end
local function CutUtf8(s, maxBytes)
    local parts = Utf8Chunks(s, maxBytes)
    return parts[1] or ""
end
local function Send(...)
    local t = { ... }
    for i = 1, #t do t[i] = (tostring(t[i]):gsub("[~|\t\n]", " ")) end
    local msg = "Q~" .. table.concat(t, "~")
    if #msg > 240 then msg = CutUtf8(msg, 240) end
    SendAddonMessage(PFX, msg, "WHISPER", UnitName("player"))
end

-- ------------------------------------------------------------------ main frame
local M = CreateFrame("Frame", "CoADevMenuFrame", UIParent)
M:SetSize(900, 660)
M:SetPoint("CENTER")
M:SetFrameStrata("HIGH")
M:SetToplevel(true)
M:SetMovable(true)
M:EnableMouse(true)
M:SetClampedToScreen(true)
Skin(M, C.bg, { 0, 0, 0, 1 })
M:Hide()
tinsert(UISpecialFrames, "CoADevMenuFrame")

local head = CreateFrame("Frame", nil, M)
head:SetPoint("TOPLEFT", 1, -1)
head:SetPoint("TOPRIGHT", -1, -1)
head:SetHeight(40)
Skin(head, C.head, C.head)
head:EnableMouse(true)
head:RegisterForDrag("LeftButton")
head:SetScript("OnDragStart", function() M:StartMoving() end)
head:SetScript("OnDragStop", function()
    M:StopMovingOrSizing()
    local p, _, rp, x, y = M:GetPoint()
    IlusixnDevMenuDB.pos = { p, rp, x, y }
end)
local accentBar = head:CreateTexture(nil, "OVERLAY")
accentBar:SetTexture(WHITE)
accentBar:SetVertexColor(unpack(C.accent))
accentBar:SetPoint("BOTTOMLEFT")
accentBar:SetPoint("BOTTOMRIGHT")
accentBar:SetHeight(2)
local icon = head:CreateTexture(nil, "OVERLAY")
icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
icon:SetSize(24, 24)
icon:SetPoint("LEFT", 12, 1)
local title = Text(head, 15, C.text)
title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
title:SetText("开发者菜单")
local subtitle = Text(head, 11, C.dim)
subtitle:SetPoint("LEFT", title, "RIGHT", 8, -1)
subtitle:SetText("（作者：ilusixn）")
local closeB = Button(head, "X", 26, 26, nil, function() M:Hide() end)
closeB:SetPoint("RIGHT", -8, 0)
local followChk = Check(head, "跟随我的目标", function(v) IlusixnDevMenuDB.follow = v end)
followChk:SetPoint("RIGHT", closeB, "LEFT", -130, 0)

-- status bar
local status = CreateFrame("Frame", nil, M)
status:SetPoint("BOTTOMLEFT", 1, 1)
status:SetPoint("BOTTOMRIGHT", -1, 1)
status:SetHeight(24)
Skin(status, C.head, C.head)
local statusText = Text(status, 11, C.dim)
statusText:SetPoint("LEFT", 12, 0)
statusText:SetText("就绪")
local credit = Text(status, 11, C.accent)
credit:SetPoint("LEFT", 112, 0)
credit:SetText("作者：ilusixn")
local statusHint = Text(status, 10, C.dim)
statusHint:SetPoint("RIGHT", -24, 0)
statusHint:SetText("右键名称：菜单   -   Ctrl+点击：3D 预览   -   /dev point：添加路径点")
local function Toast(msg, kind)
    statusText:SetText(msg)
    if statusText:GetStringWidth() > 96 then credit:Hide() else credit:Show() end   -- long messages take the credit's place
    statusText:SetTextColor(unpack(kind == "err" and C.H or (kind == "ok" and C.good or C.dim)))
    if kind == "err" then DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[Dev]|r " .. msg) end
end

-- left navigation
local nav = CreateFrame("Frame", nil, M)
nav:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, 0)
nav:SetPoint("BOTTOMLEFT", status, "TOPLEFT", 0, 0)
nav:SetWidth(170)
Skin(nav, C.head, C.head)

local content = CreateFrame("Frame", nil, M)
content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 0, 0)
content:SetPoint("BOTTOMRIGHT", status, "TOPRIGHT", 0, 0)

local pages, navButtons = {}, {}
local function ShowPage(key)
    for k, p in pairs(pages) do Shown(p, k == key) end
    for k, b in pairs(navButtons) do b:SetActive(k == key) end
    IlusixnDevMenuDB.page = key
    if pages[key].OnShowPage then pages[key]:OnShowPage() end
end
local NAV = {
    { "browse", "浏览 NPC", "Interface\\Icons\\INV_Misc_Spyglass_03" },
    { "cats", "分类", "Interface\\Icons\\INV_Misc_Book_09" },
    { "selected", "选中 NPC", "Interface\\Icons\\Ability_Hunter_SniperShot" },
    { "path", "路径编辑器", "Interface\\Icons\\Ability_Tracking" },
    { "nearby", "附近刷新", "Interface\\Icons\\INV_Misc_Map_01" },
    { "quests", "任务", "Interface\\Icons\\INV_Misc_Note_06" },
    { "objects", "物件与模型", "Interface\\Icons\\INV_Crate_04" },
    { "create", "创建 NPC", "Interface\\Icons\\INV_Misc_Head_Human_01" },
    { "items", "创建物品", "Interface\\Icons\\INV_Hammer_20" },
    { "me", "你的角色", "Interface\\Icons\\Achievement_Character_Human_Male" },
    { "morph", "变形", "Interface\\Icons\\Spell_Nature_Polymorph" },
    { "server", "服务器", "Interface\\Icons\\INV_Misc_Gear_01" },
    { "share", "导出 SQL", "Interface\\Icons\\INV_Scroll_03" },
    { "help", "帮助", "Interface\\Icons\\INV_Misc_QuestionMark" },
}
for i, n in ipairs(NAV) do
    local key, label, tex = n[1], n[2], n[3]
    local b = Button(nav, "", 154, 30, nil, function() ShowPage(key) end)
    b:SetPoint("TOPLEFT", 8, -8 - (i - 1) * 32)
    local ic = b:CreateTexture(nil, "OVERLAY")
    ic:SetTexture(tex)
    ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    ic:SetSize(20, 20)
    ic:SetPoint("LEFT", 8, 0)
    b.label:ClearAllPoints()
    b.label:SetPoint("LEFT", ic, "RIGHT", 8, 0)
    b.label:SetJustifyH("LEFT")
    b.label:SetText(label)
    navButtons[key] = b
    local p = CreateFrame("Frame", nil, content)
    p:SetAllPoints()
    p:Hide()
    pages[key] = p
end
local navInfo = Text(nav, 10, C.dim)
navInfo:SetPoint("BOTTOMLEFT", 12, 12)
navInfo:SetWidth(150)
navInfo:SetText("所有修改都会立即保存。可在“导出 SQL”页把它们分享出去。")

-- size & transparency (saved). Size scales the whole window so the layout never breaks.
local P_ -- preview frame, set later
local function ApplyLook()
    local sc = IlusixnDevMenuDB.scale or 1
    local al = IlusixnDevMenuDB.alpha or 1
    M:SetScale(sc); M:SetAlpha(al)
    if P_ then P_:SetScale(sc); P_:SetAlpha(al) end
end
local function MakeSlider(label, minV, maxV, step, get, set, y)
    local t = Text(nav, 10, C.dim)
    t:SetPoint("BOTTOMLEFT", 12, y + 16)
    local v = Text(nav, 10, C.text)
    v:SetPoint("BOTTOMRIGHT", -12, y + 16)
    local sl = CreateFrame("Slider", nil, nav)
    sl:SetOrientation("HORIZONTAL")
    sl:SetSize(146, 10)
    sl:SetPoint("BOTTOMLEFT", 12, y)
    Skin(sl, { 0.03, 0.035, 0.045, 1 }, C.border)
    sl:SetThumbTexture(WHITE)
    local th = sl:GetThumbTexture()
    th:SetVertexColor(unpack(C.accent))
    th:SetSize(10, 14)
    sl:SetMinMaxValues(minV, maxV)
    sl:SetValueStep(step)
    sl:SetValue(get())
    local function show(x) v:SetText(math.floor(x * 100 + 0.5) .. "%") end
    show(get())
    t:SetText(label)
    sl:SetScript("OnValueChanged", function(self, x) set(x); show(x); if not self.drag then ApplyLook() end end)
    -- the window scales around the slider: apply the new size only when the mouse is released, or the slider jumps under the cursor
    sl:HookScript("OnMouseDown", function(self) self.drag = true end)
    sl:HookScript("OnMouseUp", function(self) self.drag = false; ApplyLook() end)
    sl:EnableMouseWheel(true)
    sl:SetScript("OnMouseWheel", function(self, d) self:SetValue(math.max(minV, math.min(maxV, self:GetValue() + d * step))) end)
    return sl
end
navInfo:ClearAllPoints()
navInfo:SetPoint("BOTTOMLEFT", 12, 96)
local sizeSlider = MakeSlider("大小", 0.6, 1.5, 0.05, function() return IlusixnDevMenuDB.scale or 1 end, function(x) IlusixnDevMenuDB.scale = x end, 52)
local alphaSlider = MakeSlider("不透明度", 0.25, 1, 0.05, function() return IlusixnDevMenuDB.alpha or 1 end, function(x) IlusixnDevMenuDB.alpha = x end, 14)

-- corner grip: drag to resize (changes the size the same way as the slider)
local grip = CreateFrame("Button", nil, M)
grip:SetSize(16, 16)
grip:SetPoint("BOTTOMRIGHT", -2, 2)
grip:SetFrameLevel(status:GetFrameLevel() + 5)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:SetScript("OnMouseDown", function(self)
    self.x0 = GetCursorPosition()
    self.s0 = M:GetScale()
    self.w0 = M:GetWidth() * M:GetEffectiveScale()
    self:SetScript("OnUpdate", function(g)
        local x = GetCursorPosition()
        local ns = math.max(0.6, math.min(1.5, g.s0 * (1 + (x - g.x0) / g.w0)))
        sizeSlider:SetValue(math.floor(ns / 0.05 + 0.5) * 0.05)
    end)
end)
grip:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
Tip(grip, "调整大小", "拖动可放大或缩小窗口。")


-- ------------------------------------------------------------------ 3D preview
local P = CreateFrame("Frame", "CoADevMenuPreview", UIParent)
P:SetSize(320, 420)
P:SetPoint("LEFT", M, "RIGHT", 8, 0)
P:SetFrameStrata("DIALOG")
P:SetMovable(true)
P:EnableMouse(true)
P:SetClampedToScreen(true)
Skin(P, C.bg, { 0, 0, 0, 1 })
P:Hide()
tinsert(UISpecialFrames, "CoADevMenuPreview")
P_ = P
ApplyLook()
local pHead = CreateFrame("Frame", nil, P)
pHead:SetPoint("TOPLEFT", 1, -1)
pHead:SetPoint("TOPRIGHT", -1, -1)
pHead:SetHeight(46)
Skin(pHead, C.head, C.head)
pHead:EnableMouse(true)
pHead:RegisterForDrag("LeftButton")
pHead:SetScript("OnDragStart", function() P:StartMoving() end)
pHead:SetScript("OnDragStop", function() P:StopMovingOrSizing() end)
local pName = Text(pHead, 13, C.text)
pName:SetPoint("TOPLEFT", 10, -8)
pName:SetWidth(260)
local pSub = Text(pHead, 10, C.dim)
pSub:SetPoint("TOPLEFT", pName, "BOTTOMLEFT", 0, -3)
pSub:SetWidth(260)
local pClose = Button(pHead, "X", 22, 22, nil, function() P:Hide() end)
pClose:SetPoint("TOPRIGHT", -8, -8)
local model = CreateFrame("PlayerModel", nil, P)
model:SetPoint("TOPLEFT", 8, -54)
model:SetPoint("BOTTOMRIGHT", -8, 44)
local pBg = P:CreateTexture(nil, "BACKGROUND", nil, 1)
pBg:SetTexture(WHITE)
pBg:SetPoint("TOPLEFT", model)
pBg:SetPoint("BOTTOMRIGHT", model)
pBg:SetGradientAlpha("VERTICAL", 0.02, 0.02, 0.03, 1, 0.12, 0.12, 0.16, 1)
local pHint = Text(P, 10, C.dim)
pHint:SetPoint("BOTTOMLEFT", 10, 26)
pHint:SetText("拖动：旋转   滚轮：缩放")
local pSpawn = Button(P, "在此刷新", 145, 22, "accent")
pSpawn:SetPoint("BOTTOMLEFT", 8, 6)
local pTemp = Button(P, "预览刷新", 145, 22)
pTemp:SetPoint("BOTTOMRIGHT", -8, 6)
local mFacing, mZoom, mDrag, mLastX = 0, 0, false, 0
model:EnableMouse(true)
model:EnableMouseWheel(true)
model:SetScript("OnMouseDown", function() mDrag = true; mLastX = GetCursorPosition() end)
model:SetScript("OnMouseUp", function() mDrag = false end)
model:SetScript("OnUpdate", function(self)
    if mDrag then
        local x = GetCursorPosition()
        mFacing = mFacing + (x - mLastX) * 0.02
        mLastX = x
        self:SetFacing(mFacing)
    end
end)
model:SetScript("OnMouseWheel", function(self, d)
    mZoom = math.max(-2, math.min(6, mZoom + d * 0.4))
    self:SetPosition(mZoom, 0, 0)
end)
local previewEntry
local retry = CreateFrame("Frame")
retry:Hide()
retry:SetScript("OnUpdate", function(self, el)
    self.t = (self.t or 0) + el
    if self.t > 0.4 then
        self.t = 0; self.n = (self.n or 0) + 1
        if previewEntry then model:SetCreature(previewEntry) end
        if self.n >= 3 then self:Hide() end
    end
end)
local previewObj -- { entry=, display= } while previewing an object
local function Preview(entry, name, sub)
    previewObj = nil
    pTemp:SetEnabledState(true)
    pHint:SetText("拖动：旋转   滚轮：缩放")
    previewEntry = tonumber(entry)
    pName:SetText(name or ("NPC " .. entry))
    pSub:SetText((sub and sub ~= "" and ("<" .. sub .. ">   ") or "") .. "编号 " .. entry)
    mFacing, mZoom = 0, 0
    P:Show()
    model:ClearModel()
    model:SetCreature(previewEntry)
    model:SetFacing(0)
    model:SetPosition(0, 0, 0)
    model:SetLight(1, 0, 0, -0.6, -0.6, 0.45, 1, 1, 1, 0.55, 1, 0.97, 0.9)
    retry.n, retry.t = 0, 0
    retry:Show()
end
pSpawn:SetScript("OnClick", function()
    if previewObj then Send("GSPAWN", previewObj.entry or 0, previewObj.entry and 0 or previewObj.display)
    elseif previewEntry then Send("SPAWN", previewEntry, 1) end
end)
pTemp:SetScript("OnClick", function() if previewEntry and not previewObj then Send("SPAWN", previewEntry, 0) end end)
local function PreviewModel(path, name, sub, obj)
    previewObj = obj
    previewEntry = nil
    pName:SetText(name or "模型")
    pSub:SetText(sub or "")
    mFacing, mZoom = 0, 0
    P:Show()
    model:ClearModel()
    pTemp:SetEnabledState(false)
    if path and path ~= "" and not path:lower():find("%.wmo$") then
        model:SetModel((path:gsub("%.[mM][dD][xXlL]$", ".m2")))
        model:SetFacing(0); model:SetPosition(0, 0, 0)
        model:SetLight(1, 0, 0, -0.6, -0.6, 0.45, 1, 1, 1, 0.55, 1, 0.97, 0.9)
        pHint:SetText("拖动：旋转   滚轮：缩放")
    else
        pHint:SetText("建筑（WMO）没有预览：请先刷新，再在游戏中查看")
    end
end

-- ------------------------------------------------------------------ list helper
local function MakeList(parent, rows, rowH, columns, onClick)
    local L = CreateFrame("Frame", nil, parent)
    Skin(L, C.panel, C.border)
    L.rows, L.data, L.offset = {}, {}, 0
    for i = 1, rows do
        local r = CreateFrame("Button", nil, L)
        r:SetHeight(rowH)
        r:SetPoint("TOPLEFT", 1, -1 - (i - 1) * rowH)
        r:SetPoint("TOPRIGHT", -12, -1 - (i - 1) * rowH)
        r.bg = r:CreateTexture(nil, "BACKGROUND")
        r.bg:SetAllPoints()
        r.bg:SetTexture(WHITE)
        r.bg:SetVertexColor(1, 1, 1, (i % 2 == 0) and 0.025 or 0)
        r.hl = r:CreateTexture(nil, "HIGHLIGHT")
        r.hl:SetAllPoints()
        r.hl:SetTexture(WHITE)
        r.hl:SetVertexColor(1, 0.8, 0.3, 0.08)
        r.sel = r:CreateTexture(nil, "ARTWORK")
        r.sel:SetPoint("TOPLEFT")
        r.sel:SetPoint("BOTTOMLEFT")
        r.sel:SetWidth(3)
        r.sel:SetTexture(WHITE)
        r.sel:SetVertexColor(unpack(C.accent))
        r.sel:Hide()
        r.dot = r:CreateTexture(nil, "OVERLAY")
        r.dot:SetTexture(WHITE)
        r.dot:SetSize(6, 6)
        r.dot:SetPoint("LEFT", 9, 0)
        r.cols = {}
        local x = 22
        for c, col in ipairs(columns) do
            local t = Text(r, col.size or 12, col.color or C.text)
            t:SetPoint("LEFT", x, 0)
            t:SetWidth(col.w)
            t:SetJustifyH(col.right and "RIGHT" or "LEFT")
            r.cols[c] = t
            x = x + col.w + 8
        end
        r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        r:SetScript("OnClick", function(self, btn)
            local d = L.data[L.offset + i]
            if d then onClick(d, btn, IsControlKeyDown()) end
        end)
        r:SetScript("OnDoubleClick", function()
            local d = L.data[L.offset + i]
            if d and L.onDouble then L.onDouble(d) end
        end)
        L.rows[i] = r
    end
    -- scrollbar: a list that has more pages on the server loads them as you scroll down
    local sb = CreateFrame("Slider", nil, L)
    sb:SetOrientation("VERTICAL"); sb:SetWidth(8)
    sb:SetPoint("TOPRIGHT", -2, -2); sb:SetPoint("BOTTOMRIGHT", -2, 2)
    sb:SetThumbTexture(WHITE); sb:GetThumbTexture():SetVertexColor(unpack(C.accent)); sb:GetThumbTexture():SetSize(8, 22)
    sb:SetMinMaxValues(0, 0); sb:SetValueStep(1)
    sb:SetScript("OnValueChanged", function(self, v)
        if L.syncing then return end
        L.offset = math.floor(v + 0.5); L:Refresh()
    end)
    L.sb = sb
    L.page = 0
    function L:More()
        if self.hasMore and not self.loading and self.fetch then
            self.loading = true; self.page = self.page + 1; self.fetch(self.page)
        end
    end
    function L:Search(fn) self.page = 0; self.fetch = fn; self.hasMore = false; self.loading = true; fn(0) end
    function L:Begin(pages) if self.page == 0 then self.data = {}; self.offset = 0 end; self.pages = tonumber(pages) or 1 end
    function L:Done() self.loading = false; self.hasMore = self.page + 1 < (self.pages or 1); self:Refresh() end
    L:EnableMouseWheel(true)
    L:SetScript("OnMouseWheel", function(self, d)
        self.offset = math.max(0, math.min(#self.data - rows, self.offset - d * 3))
        self:Refresh()
    end)
    function L:Refresh()
        local maxOff = math.max(0, #self.data - rows)
        if self.offset > maxOff then self.offset = maxOff end
        self.syncing = true
        sb:SetMinMaxValues(0, maxOff); sb:SetValue(self.offset)
        self.syncing = false
        Shown(sb, maxOff > 0)
        if self.hasMore and self.offset + rows >= #self.data - 3 then self:More() end
        for i, r in ipairs(self.rows) do
            local d = self.data[self.offset + i]
            if d then
                r:Show()
                local texts = self.format(d)
                for c, t in ipairs(r.cols) do t:SetText(texts[c] or "") end
                r.dot:SetVertexColor(unpack(C[d.react] or C.dim))
                Shown(r.sel, self.isSelected and self.isSelected(d))
            else
                r:Hide()
            end
        end
    end
    return L
end

-- ------------------------------------------------------------------ state
local S = { selected = nil, results = {}, near = {}, pathCount = 0 }
local Inspector, ShowMenu -- forward

-- ================================================================== BROWSE
do
    local p = pages.browse
    local h = Header(p, "查找 NPC")
    h:SetPoint("TOPLEFT", 16, -16)
    local search = Edit(p, 420, 28, false)
    search:SetPoint("TOPLEFT", 16, -40)
    search:SetPlaceholder("名称、称号或编号（回车搜索）")
    local filter = 0
    local list
    local function DoSearch()
        list:Search(function(pg) Send("SEARCH", search:GetText(), pg, filter) end)
    end
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); DoSearch(0) end)
    local go = Button(p, "搜索", 90, 28, "accent", function() DoSearch(0) end)
    go:SetPoint("LEFT", search, "RIGHT", 8, 0)
    local countText = Text(p, 11, C.dim)
    countText:SetPoint("LEFT", go, "RIGHT", 12, 0)

    local FILTERS = { { 0, "全部" }, { 1, "友好" }, { 2, "敌对" }, { 3, "中立" }, { 4, "小动物" }, { 5, "服务" }, { 6, "自定义 (CoA)" } }
    local chips = {}
    for i, f in ipairs(FILTERS) do
        local b = Button(p, f[2], 88, 22, "chip", function()
            filter = f[1]
            for _, c in ipairs(chips) do c:SetActive(c.fid == filter) end
            DoSearch(0)
        end)
        b.fid = f[1]
        b:SetPoint("TOPLEFT", 16 + (i - 1) * 94, -76)
        chips[i] = b
    end
    chips[1]:SetActive(true)

    list = MakeList(p, 11, 24, {
        { w = 330 }, { w = 70, color = C.dim, size = 11 }, { w = 70, color = C.dim, size = 11, right = true }, { w = 80, color = C.dim, size = 11 },
    }, function(d, btn, ctrl)
        if btn == "RightButton" then S.pick = d; p.list:Refresh(); p:ShowPick(); return ShowMenu(d) end
        if ctrl then Preview(d.entry, d.name, d.sub) return end
        S.pick = d
        p.list:Refresh()
        p:ShowPick()
    end)
    list:SetPoint("TOPLEFT", 16, -108)
    list:SetPoint("RIGHT", p, "RIGHT", -16, 0)
    list:SetHeight(11 * 24 + 2)
    list.format = function(d)
        local lvl = (d.minl == d.maxl) and d.minl or (d.minl .. "-" .. d.maxl)
        local name = d.name .. (d.sub ~= "" and ("  |cff8a8f9c<" .. d.sub .. ">|r") or "")
        return { name, "等级 " .. lvl, "#" .. d.entry, REACT_NAME[d.react] or "" }
    end
    list.isSelected = function(d) return S.pick and S.pick.entry == d.entry end
    list.onDouble = function(d) Preview(d.entry, d.name, d.sub) end
    p.list = list

    -- action card for the picked entry
    local card = Card(p)
    card:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -36)
    card:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -16, 12)
    local cName = Text(card, 13, C.text)
    cName:SetPoint("TOPLEFT", 12, -10)
    local cInfo = Text(card, 10, C.dim)
    cInfo:SetPoint("TOPLEFT", cName, "BOTTOMLEFT", 0, -4)
    local bSpawn = Button(card, "在此刷新并保存", 150, 26, "accent", function() if S.pick then Send("SPAWN", S.pick.entry, 1) end end)
    bSpawn:SetPoint("BOTTOMLEFT", 12, 10)
    Tip(bSpawn, "在此刷新并保存", "在你当前的位置和朝向创建一个永久刷新，并选中它。")
    local bTemp = Button(card, "预览刷新", 120, 26, nil, function() if S.pick then Send("SPAWN", S.pick.entry, 0) end end)
    bTemp:SetPoint("LEFT", bSpawn, "RIGHT", 8, 0)
    Tip(bTemp, "预览刷新", "临时副本，持续 5 分钟，不会保存。")
    local b3d = Button(card, "3D 预览", 100, 26, nil, function() if S.pick then Preview(S.pick.entry, S.pick.name, S.pick.sub) end end)
    b3d:SetPoint("LEFT", bTemp, "RIGHT", 8, 0)
    local bSwap = Button(card, "把选中 NPC 变成这个", 200, 26, nil, function()
        if S.pick and S.selected then Send("ENTRY", S.selected.guid, S.pick.entry) else Toast("请先选中一个已刷新的 NPC（选中 NPC 页）", "err") end
    end)
    bSwap:SetPoint("LEFT", b3d, "RIGHT", 8, 0)
    Tip(bSwap, "把选中 NPC 变成这个", "保留选中刷新的位置、路径和动作，只改变它是哪个 NPC。")
    local dupName = Edit(card, 230, 24)
    dupName:SetPoint("TOPLEFT", 12, -46)
    dupName:SetPlaceholder("新 NPC 名称")
    local dupSub = Edit(card, 170, 24)
    dupSub:SetPoint("LEFT", dupName, "RIGHT", 6, 0)
    dupSub:SetPlaceholder("<称号>（可选）")
    local bDup = Button(card, "复制为新 NPC", 170, 24, "accent", function()
        if not S.pick then return Toast("请先选择一个要复制的 NPC", "err") end
        Send("DUP", S.pick.entry, dupName:GetText(), dupSub:GetText())
        dupName:SetText(""); dupSub:SetText("")
    end)
    bDup:SetPoint("LEFT", dupSub, "RIGHT", 6, 0)
    Tip(bDup, "复制为新 NPC", "以选中的 NPC 为模板创建一个全新的 NPC 类型（模型、等级、阵营、掉落、商店）。给它起名、刷新，然后随意编辑：绝不会影响其它 NPC。")
    function p:ShowPick()
        local d = S.pick
        if not d then cName:SetText("在列表中选择一个 NPC"); cInfo:SetText("点击：选择   Ctrl+点击 或双击：3D 预览"); return end
        cName:SetText(d.name .. (d.sub ~= "" and ("  <" .. d.sub .. ">") or ""))
        cInfo:SetText(("编号 %s   等级 %s-%s   %s   模型 %s"):format(d.entry, d.minl, d.maxl, REACT_NAME[d.react] or "?", d.display))
    end
    p:ShowPick()

    function p:OnResults()
        list:Done()
        countText:SetText("找到 " .. (S.total or 0) .. " 个 NPC（滚动加载更多）")
    end
    function p:OnShowPage() if #S.results == 0 then DoSearch(0) end end
end

-- ================================================================== SELECTED
do
    local p = pages.selected
    local card = Card(p)
    card:SetPoint("TOPLEFT", 16, -16)
    card:SetPoint("TOPRIGHT", -16, -16)
    card:SetHeight(92)
    local dot = card:CreateTexture(nil, "OVERLAY")
    dot:SetTexture(WHITE)
    dot:SetSize(8, 8)
    dot:SetPoint("TOPLEFT", 14, -17)
    local nm = Text(card, 15, C.text)
    nm:SetPoint("TOPLEFT", 30, -12)
    nm:SetWidth(430)
    local l1 = Text(card, 11, C.dim)
    l1:SetPoint("TOPLEFT", 14, -38)
    l1:SetWidth(470)
    local l2 = Text(card, 11, C.dim)
    l2:SetPoint("TOPLEFT", 14, -56)
    l2:SetWidth(470)
    local l3 = Text(card, 10, C.dim)
    l3:SetPoint("TOPLEFT", 14, -73)
    l3:SetWidth(470)
    local bTarget = Button(card, "使用我的目标", 116, 24, "accent", function() Send("SEL", 0) end)
    bTarget:SetPoint("TOPRIGHT", -10, -10)
    local b3d = Button(card, "3D", 40, 24, nil, function() if S.selected then Preview(S.selected.entry, S.selected.name, S.selected.sub) end end)
    b3d:SetPoint("RIGHT", bTarget, "LEFT", -6, 0)
    local bGo = Button(card, "前往", 70, 24, nil, function() if S.selected then Send("GOTO", S.selected.guid) end end)
    bGo:SetPoint("TOPRIGHT", -10, -40)
    local bRes = Button(card, "重新刷新", 80, 24, nil, function() if S.selected then Send("RESPAWN", S.selected.guid) end end)
    bRes:SetPoint("RIGHT", bGo, "LEFT", -6, 0)
    local bDel = Button(card, "删除", 70, 24, "danger", function()
        if S.selected then StaticPopup_Show("COA_DEVMENU_DELETE", S.selected.name .. " (GUID " .. S.selected.guid .. ")") end
    end)
    bDel:SetPoint("TOPRIGHT", -10, -66)
    local bRep = Button(card, "替换", 80, 24, nil, function() if S.selected and S.OpenReplace then S.OpenReplace() end end)
    bRep:SetPoint("RIGHT", bDel, "LEFT", -6, 0)
    Tip(bRep, "替换", "把这个刷新变成任意其它 NPC（可搜索全部、你创建的、收藏和分类）。位置保持不变。")
    StaticPopupDialogs["COA_DEVMENU_DELETE"] = {
        text = "要从世界数据库中删除这个刷新吗？\n\n%s",
        button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
        OnAccept = function() if S.selected then Send("DEL", S.selected.guid) end end,
    }

    -- sub tabs
    local subs, subBtns = {}, {}
    S.subs = subs
    local SUB = { { "place", "放置" }, { "act", "动作" }, { "role", "职责与阵营" }, { "id", "身份" }, { "svc", "服务" }, { "combat", "战斗" }, { "adv", "高级" } }
    local function ShowSub(k)
        for key, f in pairs(subs) do Shown(f, key == k) end
        for key, b in pairs(subBtns) do b:SetActive(key == k) end
        IlusixnDevMenuDB.sub = k
        if (k == "adv" or k == "svc") and S.selected then Send("TGET", S.selected.guid) end
        if k == "svc" and S.OnServices then S.OnServices() end
    end
    for i, s in ipairs(SUB) do
        local b = Button(p, s[2], 98, 26, nil, function() ShowSub(s[1]) end)
        b:SetPoint("TOPLEFT", 16 + (i - 1) * 102, -116)
        subBtns[s[1]] = b
        local f = Card(p)
        f:SetPoint("TOPLEFT", 16, -148)
        f:SetPoint("BOTTOMRIGHT", -16, 12)
        f:Hide()
        subs[s[1]] = f
    end
    local empty = Text(p, 13, C.dim)
    empty:SetPoint("CENTER", 0, -40)
    empty:SetText("未选中 NPC。\n\n选中一个已刷新的 NPC 并点击“使用我的目标”，\n或在“附近刷新”中选择一个。")
    empty:SetJustifyH("CENTER")

    local function G() return S.selected and S.selected.guid end
    local uniq = {}   -- "only this spawn" checkboxes, kept in sync

    -- ---------------- placement
    do
        local f = subs.place
        local h1 = Header(f, "位置")
        h1:SetPoint("TOPLEFT", 14, -14)
        local bMove = Button(f, "移动到我这里", 140, 30, "accent", function() if G() then Send("MOVE", G()) end end)
        bMove:SetPoint("TOPLEFT", 14, -38)
        Tip(bMove, "移动到我这里", "把 NPC 放到你站立的位置，并面朝你的朝向。会保存。")
        local bFace = Button(f, "面朝我", 110, 30, nil, function() if G() then Send("FACE", G()) end end)
        bFace:SetPoint("LEFT", bMove, "RIGHT", 8, 0)

        local h2 = Header(f, "微调（方向相对于你自己面朝的方向）")
        h2:SetPoint("TOPLEFT", 14, -86)
        local step, turn = 1, 15
        S.step, S.turn = 1, 15
        local stepChips, turnChips = {}, {}
        local st = Text(f, 11, C.dim)
        st:SetPoint("TOPLEFT", 14, -114)
        st:SetText("步长")
        for i, v in ipairs({ 0.1, 0.25, 0.5, 1, 2, 5 }) do
            local b = Button(f, v .. " 码", 56, 22, "chip", function()
                step = v; S.step = v
                for _, c in ipairs(stepChips) do c:SetActive(c.v == v) end
            end)
            b.v = v
            b:SetPoint("TOPLEFT", 60 + (i - 1) * 60, -110)
            b:SetActive(v == 1)
            stepChips[i] = b
        end
        local tt = Text(f, 11, C.dim)
        tt:SetPoint("TOPLEFT", 14, -142)
        tt:SetText("转向")
        for i, v in ipairs({ 5, 15, 45, 90, 180 }) do
            local b = Button(f, v .. "°", 56, 22, "chip", function()
                turn = v; S.turn = v
                for _, c in ipairs(turnChips) do c:SetActive(c.v == v) end
            end)
            b.v = v
            b:SetPoint("TOPLEFT", 60 + (i - 1) * 60, -138)
            b:SetActive(v == 15)
            turnChips[i] = b
        end
        S.placePane = f
        local note = Text(f, 10, C.dim)
        note:SetPoint("BOTTOMLEFT", 14, 12)
        note:SetWidth(640)
        note:SetText("提示：站在你希望 NPC 所在的位置，面朝它应该看向的方向，点击“移动到我这里”。阳台和狭窄位置可用方向键盘微调。")
    end

    -- ---------------- movement & actions
    local moveChips, emoteChips = {}, {}
    local wanderEdit
    do
        local f = subs.act
        local h1 = Header(f, "移动方式")
        h1:SetPoint("TOPLEFT", 14, -14)
        local MOVES = { { 0, "原地站立" }, { 1, "游荡" }, { 2, "沿路径行走" } }
        for i, m in ipairs(MOVES) do
            local b = Button(f, m[2], 120, 26, "chip", function()
                if not G() then return end
                Send("MOVETYPE", G(), m[1], tonumber(wanderEdit:GetText()) or 5)
            end)
            b.v = m[1]
            b:SetPoint("TOPLEFT", 14 + (i - 1) * 126, -38)
            moveChips[i] = b
        end
        local wl = Text(f, 11, C.dim)
        wl:SetPoint("TOPLEFT", 400, -44)
        wl:SetText("游荡半径")
        wanderEdit = Edit(f, 60, 24, true, function(self) if G() then Send("MOVETYPE", G(), 1, tonumber(self:GetText()) or 5) end end)
        wanderEdit:SetPoint("LEFT", wl, "RIGHT", 8, 0)
        local wy = Text(f, 11, C.dim)
        wy:SetPoint("LEFT", wanderEdit, "RIGHT", 6, 0)
        wy:SetText("码")

        local h2 = Header(f, "循环动作（站立时做什么）")
        h2:SetPoint("TOPLEFT", 14, -82)
        local STATES = {
            { 0, "无" }, { 173, "工作 / 打铁" }, { 233, "采矿" }, { 234, "劈柴" }, { 69, "使用（修理）" }, { 133, "使用（持武器）" },
            { 378, "交谈" }, { 10, "跳舞" }, { 13, "坐下" }, { 12, "睡觉" }, { 68, "单膝跪地" }, { 313, "稍息" },
            { 333, "备战（单手）" }, { 375, "备战（双手）" }, { 376, "备战（弓）" }, { 214, "备战（步枪）" }, { 27, "备战（徒手）" }, { 379, "钓鱼" },
            { 64, "昏迷" }, { 65, "死亡" }, { 253, "鼓掌" }, { 392, "大笑" }, { 391, "咆哮" }, { 193, "引导法术" },
        }
        for i, e in ipairs(STATES) do
            local col, row = (i - 1) % 6, math.floor((i - 1) / 6)
            local b = Button(f, e[2], 106, 24, "chip", function() if G() then Send("EMOTE", G(), e[1]) end end)
            b.v = e[1]
            b:SetPoint("TOPLEFT", 14 + col * 111, -106 - row * 28)
            emoteChips[i] = b
        end
        local cl = Text(f, 11, C.dim)
        cl:SetPoint("TOPLEFT", 14, -226)
        cl:SetText("其它表情编号")
        local ce = Edit(f, 70, 24, true)
        ce:SetPoint("LEFT", cl, "RIGHT", 8, 0)
        local cb = Button(f, "设置", 50, 24, nil, function() if G() then Send("EMOTE", G(), tonumber(ce:GetText()) or 0) end end)
        cb:SetPoint("LEFT", ce, "RIGHT", 6, 0)
        local all = Button(f, "全部表情（搜索）...", 170, 24, "accent", function() if S.EmotePicker then S.EmotePicker() end end)
        all:SetPoint("LEFT", cb, "RIGHT", 16, 0)
        Tip(all, "全部表情", "搜索游戏已知的全部 " .. #CoADevEmotes .. " 个表情。点击：设为循环动作。右键：播放一次。")

        local h3 = Header(f, "播放一次（测试，不保存）")
        h3:SetPoint("TOPLEFT", 14, -262)
        local ONCE = { { 1, "交谈" }, { 2, "鞠躬" }, { 3, "挥手" }, { 4, "欢呼" }, { 11, "大笑" }, { 25, "指点" }, { 66, "敬礼" }, { 21, "鼓掌" },
            { 15, "咆哮" }, { 22, "喊叫" }, { 273, "是" }, { 274, "否" }, { 23, "展示肌肉" }, { 7, "进食" }, { 36, "攻击" }, { 51, "施法" } }
        for i, e in ipairs(ONCE) do
            local col, row = (i - 1) % 8, math.floor((i - 1) / 8)
            local b = Button(f, e[2], 78, 22, nil, function() if G() then Send("PLAY", G(), e[1]) end end)
            b:SetPoint("TOPLEFT", 14 + col * 83, -286 - row * 26)
        end
    end

    -- ---------------- role & faction
    local roleChecks = {}
    local guardChk
    do
        local f = subs.role
        local h1 = Header(f, "服务（勾选后点击“应用”）")
        h1:SetPoint("TOPLEFT", 14, -14)
        local ROLES = {
            { 1, "对话 / 交谈" }, { 2, "任务发布者" }, { 128, "商人" }, { 4096, "修理" }, { 16, "训练师" }, { 65536, "旅店老板" },
            { 131072, "银行职员" }, { 2097152, "拍卖师" }, { 8192, "飞行管理员" }, { 4194304, "兽栏管理员" }, { 16384, "灵魂医者" },
            { 524288, "战袍设计师" }, { 1048576, "战场指挥官" }, { 8388608, "公会银行" }, { 262144, "公会徽章" },
        }
        for i, r in ipairs(ROLES) do
            local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
            local c = Check(f, r[2])
            c.flag = r[1]
            c:SetPoint("TOPLEFT", 16 + col * 200, -42 - row * 24)
            roleChecks[i] = c
        end
        local apply = Button(f, "应用服务", 130, 26, "accent", function()
            if not G() then return end
            local flags = 0
            for _, c in ipairs(roleChecks) do if c.value then flags = flags + c.flag end end
            if flags > 1 and flags % 2 == 0 then flags = flags + 1 end   -- services need the gossip flag
            Send("ROLE", G(), flags)
        end)
        apply:SetPoint("TOPLEFT", 14, -168)
        Tip(apply, "应用服务", "只保存在这个刷新上。商人需要物品：在下方添加。")
        local clear = Button(f, "清除服务", 110, 26, nil, function() if G() then Send("ROLE", G(), 0) end end)
        clear:SetPoint("LEFT", apply, "RIGHT", 8, 0)

        local il = Text(f, 11, C.dim)
        il:SetPoint("LEFT", clear, "RIGHT", 20, 0)
        il:SetText("商店物品编号")
        local ie = Edit(f, 80, 24, true)
        ie:SetPoint("LEFT", il, "RIGHT", 8, 0)
        local ib = Button(f, "加入商店", 100, 24, nil, function() if G() then Send("VENDORADD", G(), tonumber(ie:GetText()) or 0) end end)
        ib:SetPoint("LEFT", ie, "RIGHT", 6, 0)

        local h2 = Header(f, "行为与阵营（这些会改变 NPC 类型）")
        h2:SetPoint("TOPLEFT", 14, -210)
        guardChk = Check(f, "守卫：攻击附近的敌对怪物和敌人")
        guardChk:SetPoint("TOPLEFT", 16, -236)
        local gb = Button(f, "应用", 70, 22, nil, function() if G() then Send("GUARD", G(), guardChk.value and 1 or 0, uniq.role.value and 1 or 0) end end)
        gb:SetPoint("TOPLEFT", 380, -233)
        local FACT = { { 35, "对所有人友好" }, { 7, "中立" }, { 14, "敌对" }, { 31, "小动物（被动）" }, { 11, "联盟（暴风城）" }, { 85, "部落（奥格瑞玛）" } }
        for i, fc in ipairs(FACT) do
            local b = Button(f, fc[2], 120, 24, nil, function() if G() then Send("FACTION", G(), fc[1], uniq.role.value and 1 or 0) end end)
            b:SetPoint("TOPLEFT", 14 + ((i - 1) % 3) * 126, -266 - math.floor((i - 1) / 3) * 30)
        end
        local fl = Text(f, 11, C.dim)
        fl:SetPoint("TOPLEFT", 400, -272)
        fl:SetText("阵营编号")
        local fe = Edit(f, 70, 24, true)
        fe:SetPoint("LEFT", fl, "RIGHT", 8, 0)
        local fb = Button(f, "设置", 50, 24, nil, function() if G() then Send("FACTION", G(), tonumber(fe:GetText()) or 35, uniq.role.value and 1 or 0) end end)
        fb:SetPoint("LEFT", fe, "RIGHT", 6, 0)
        uniq.role = Check(f, "仅此刷新（先把它设为独立的 NPC 类型）")
        uniq.role:SetPoint("TOPLEFT", 16, -336)
    end

    -- ---------------- identity
    local nameEdit, subEdit, minEdit, maxEdit, dispEdit, entryEdit
    do
        local f = subs.id
        local h1 = Header(f, "名称")
        h1:SetPoint("TOPLEFT", 14, -14)
        nameEdit = Edit(f, 300, 26)
        nameEdit:SetPoint("TOPLEFT", 14, -38)
        nameEdit:SetPlaceholder("名称")
        subEdit = Edit(f, 220, 26)
        subEdit:SetPoint("LEFT", nameEdit, "RIGHT", 8, 0)
        subEdit:SetPlaceholder("<称号>（可选）")
        local nb = Button(f, "保存名称", 100, 26, "accent", function()
            if G() then Send("RENAME", G(), nameEdit:GetText(), subEdit:GetText(), uniq.id.value and 1 or 0) end
        end)
        nb:SetPoint("LEFT", subEdit, "RIGHT", 8, 0)

        local h2 = Header(f, "等级")
        h2:SetPoint("TOPLEFT", 14, -80)
        minEdit = Edit(f, 60, 26, true)
        minEdit:SetPoint("TOPLEFT", 14, -104)
        local dash = Text(f, 12, C.dim)
        dash:SetPoint("LEFT", minEdit, "RIGHT", 6, 0)
        dash:SetText("到")
        maxEdit = Edit(f, 60, 26, true)
        maxEdit:SetPoint("LEFT", dash, "RIGHT", 6, 0)
        local lb = Button(f, "保存等级", 100, 26, nil, function()
            if G() then Send("LEVEL", G(), tonumber(minEdit:GetText()) or 1, tonumber(maxEdit:GetText()) or 1, uniq.id.value and 1 or 0) end
        end)
        lb:SetPoint("LEFT", maxEdit, "RIGHT", 8, 0)

        local h3 = Header(f, "外观")
        h3:SetPoint("TOPLEFT", 14, -146)
        local dl = Text(f, 11, C.dim)
        dl:SetPoint("TOPLEFT", 14, -176)
        dl:SetText("模型编号")
        dispEdit = Edit(f, 90, 26, true)
        dispEdit:SetPoint("LEFT", dl, "RIGHT", 8, 0)
        local db = Button(f, "设置模型", 100, 26, nil, function()
            if G() then Send("MODEL", G(), tonumber(dispEdit:GetText()) or 0, uniq.id.value and 1 or 0) end
        end)
        db:SetPoint("LEFT", dispEdit, "RIGHT", 8, 0)

        local h4 = Header(f, "更改此刷新对应的 NPC")
        h4:SetPoint("TOPLEFT", 14, -216)
        local el = Text(f, 11, C.dim)
        el:SetPoint("TOPLEFT", 14, -246)
        el:SetText("NPC 编号")
        entryEdit = Edit(f, 90, 26, true)
        entryEdit:SetPoint("LEFT", el, "RIGHT", 8, 0)
        local eb = Button(f, "交换", 70, 26, nil, function() if G() then Send("ENTRY", G(), tonumber(entryEdit:GetText()) or 0) end end)
        eb:SetPoint("LEFT", entryEdit, "RIGHT", 8, 0)
        local pick = Button(f, "从浏览页选择...", 150, 26, nil, function() ShowPage("browse") end)
        pick:SetPoint("LEFT", eb, "RIGHT", 8, 0)
        Tip(pick, "从浏览页选择", "在那里找到 NPC，然后点击“把选中 NPC 变成这个”。")

        uniq.id = Check(f, "仅此刷新：先复制 NPC 类型，其它刷新才能保留各自的名称/等级/外观")
        uniq.id:SetPoint("TOPLEFT", 16, -294)
        uniq.id:Set(true)
        local ub = Button(f, "立即将此刷新设为唯一", 200, 26, nil, function() if G() then Send("UNIQUE", G()) end end)
        ub:SetPoint("TOPLEFT", 14, -322)
        local note = Text(f, 10, C.dim)
        note:SetPoint("TOPLEFT", 14, -356)
        note:SetWidth(660)
        note:SetText("名称、等级、外观、阵营和守卫都保存在 NPC 类型上（该类型的所有刷新共享）。保持勾选“仅此刷新”就只会修改当前这一个。")
    end

    -- ---------------- advanced (every NPC property)
    do
        local f = subs.adv
        local h1 = Header(f, "属性与参数（回车或点“设置”保存）")
        h1:SetPoint("TOPLEFT", 14, -12)
        local FIELDS = {
            { "minlevel", "最低等级" }, { "maxlevel", "最高等级" }, { "faction", "阵营编号" }, { "rank", "稀有等级（1 精英，2 稀有精英，3 首领，4 稀有）" },
            { "health", "生命值倍率" }, { "damage", "伤害倍率" }, { "armor", "护甲倍率" }, { "mana", "法力倍率" },
            { "xp", "经验倍率" }, { "spawntime", "刷新时间（秒，仅此刷新）" }, { "aggro", "仇恨范围（码）" },
            { "walk", "行走速度" }, { "run", "奔跑速度" }, { "attacktime", "攻击速度（毫秒）" }, { "mingold", "最少金币（铜币）" },
            { "maxgold", "最多金币（铜币）" }, { "lootid", "掉落表编号" }, { "gossip", "对话菜单编号" }, { "type", "生物类型编号" },
            { "family", "野兽科系编号" }, { "unit_class", "职业（1 战士，2 圣骑士，4 盗贼，8 法师）" }, { "hover", "悬浮高度" },
        }
        S.advEdits = {}
        for i, fd in ipairs(FIELDS) do
            local col, row = math.floor((i - 1) / 11), (i - 1) % 11
            local x, y = 14 + col * 350, -34 - row * 24
            local l = Text(f, 11, C.dim)
            l:SetPoint("TOPLEFT", x, y - 5)
            l:SetWidth(200)
            l:SetText(fd[2])
            local function save(e) if S.selected then Send("TSET", S.selected.guid, fd[1], e:GetText(), (uniq.adv.value and fd[1] ~= "spawntime") and 1 or 0) end end
            local e = Edit(f, 76, 22, true, save)
            e:SetPoint("TOPLEFT", x + 204, y)
            local b = Button(f, "设置", 40, 22, nil, function() save(e) end)
            b:SetPoint("LEFT", e, "RIGHT", 4, 0)
            S.advEdits[fd[1]] = e
        end
        local h2 = Header(f, "标志（点击切换，立即保存）")
        h2:SetPoint("TOPLEFT", 14, -304)
        local FLAGS = {
            { "unit_flags", 0x1000, "PvP 标记" }, { "unit_flags", 0x100, "玩家无法攻击" }, { "unit_flags", 0x200, "忽略 NPC" },
            { "unit_flags", 0x2000000, "不可选中" }, { "unit_flags", 0x20000, "被安抚" }, { "unit_flags", 0x4, "定身" },
            { "flags_extra", 0x2, "平民（不主动攻击）" }, { "flags_extra", 0x40, "不提供经验" }, { "regen", 1, "恢复生命值" },
        }
        S.advFlags = {}
        for i, fl in ipairs(FLAGS) do
            local c = Check(f, fl[3], function(v)
                if not S.selected or not S.adv then return end
                local cur = tonumber(S.adv[fl[1]]) or 0
                local has = bit.band(cur, fl[2]) ~= 0
                local nv = cur
                if v and not has then nv = cur + fl[2] elseif (not v) and has then nv = cur - fl[2] end
                if fl[1] == "regen" then nv = v and 1 or 0 end
                Send("TSET", S.selected.guid, fl[1], nv, uniq.adv.value and 1 or 0)
            end)
            c:SetPoint("TOPLEFT", 16 + ((i - 1) % 5) * 140, -328 - math.floor((i - 1) / 5) * 22)
            c.fl = fl
            S.advFlags[i] = c
        end
        local h3 = Header(f, "击杀给予的声望")
        h3:SetPoint("TOPLEFT", 14, -380)
        local rl = Text(f, 11, C.dim)
        rl:SetPoint("TOPLEFT", 14, -404)
        rl:SetText("阵营")
        local rf = Edit(f, 60, 22, true)
        rf:SetPoint("LEFT", rl, "RIGHT", 6, 0)
        local vl = Text(f, 11, C.dim)
        vl:SetPoint("LEFT", rf, "RIGHT", 10, 0)
        vl:SetText("数值")
        local rv = Edit(f, 60, 22, true)
        rv:SetPoint("LEFT", vl, "RIGHT", 6, 0)
        local ml = Text(f, 11, C.dim)
        ml:SetPoint("LEFT", rv, "RIGHT", 10, 0)
        ml:SetText("上限（0 仇恨 .. 7 崇拜）")
        local rm = Edit(f, 34, 22, true)
        rm:SetPoint("LEFT", ml, "RIGHT", 6, 0)
        local rs = Button(f, "设置", 44, 22, nil, function()
            if S.selected then Send("REP", S.selected.guid, tonumber(rf:GetText()) or 0, tonumber(rv:GetText()) or 0, tonumber(rm:GetText()) or 7, uniq.adv.value and 1 or 0) end
        end)
        rs:SetPoint("LEFT", rm, "RIGHT", 6, 0)
        local rx = Button(f, "无", 50, 22, nil, function() if S.selected then Send("REP", S.selected.guid, 0, 0, 0, 0) end end)
        rx:SetPoint("LEFT", rs, "RIGHT", 4, 0)
        uniq.adv = Check(f, "仅此刷新（先复制 NPC 类型）")
        uniq.adv:SetPoint("TOPRIGHT", -250, -12)
        function S.RefreshAdvanced()
            local a = S.adv or {}
            for k, e in pairs(S.advEdits) do if not e:HasFocus() then e:SetText(a[k] or "") end end
            for _, c in ipairs(S.advFlags) do
                local cur = tonumber(a[c.fl[1]]) or 0
                c:Set(c.fl[1] == "regen" and cur ~= 0 or bit.band(cur, c.fl[2]) ~= 0)
            end
            local r = a.rep or { "0", "0", "7" }
            if not rf:HasFocus() then rf:SetText(r[1] ~= "0" and r[1] or "") end
            if not rv:HasFocus() then rv:SetText(r[1] ~= "0" and r[2] or "") end
            if not rm:HasFocus() then rm:SetText(r[3] or "7") end
        end
    end

    function Inspector()
        local d = S.selected
        local has = d ~= nil
        Shown(empty, not has)
        Shown(card, true)
        for _, b in pairs(subBtns) do Shown(b, has) end
        local cur = IlusixnDevMenuDB.sub or "place"
        for k, f in pairs(subs) do Shown(f, has and k == cur) end
        for k, b in pairs(subBtns) do b:SetActive(k == cur) end
        if not has then
            nm:SetText("未选中任何目标"); dot:SetVertexColor(unpack(C.dim))
            l1:SetText(""); l2:SetText(""); l3:SetText("")
            return
        end
        dot:SetVertexColor(unpack(C[d.react] or C.dim))
        nm:SetText(d.name .. (d.sub ~= "" and ("  |cff8a8f9c<" .. d.sub .. ">|r") or ""))
        local lvl = (d.minl == d.maxl) and d.minl or (d.minl .. "-" .. d.maxl)
        l1:SetText(("GUID %s   编号 %s   等级 %s   %s（阵营 %s）%s"):format(d.guid, d.entry, lvl, REACT_NAME[d.react] or "?", d.faction, d.guard == "1" and "   |cffffc840守卫|r" or ""))
        l2:SetText(("x %.2f   y %.2f   z %.2f   朝向 %.0f°"):format(tonumber(d.x), tonumber(d.y), tonumber(d.z), math.deg(tonumber(d.o))))
        local mv = ({ ["0"] = "原地站立", ["1"] = "游荡 " .. d.wander .. " 码", ["2"] = "沿路径行走 " .. d.path .. "（" .. d.pts .. " 个点）" })[d.move] or d.move
        l3:SetText(("移动：%s   动作：%s   模型 %s   %s 个刷新使用此 NPC 类型"):format(mv, d.emote, d.display, d.count))
        for _, c in ipairs(moveChips) do c:SetActive(tostring(c.v) == d.move) end
        for _, c in ipairs(emoteChips) do c:SetActive(tostring(c.v) == d.emote) end
        if not wanderEdit:HasFocus() then wanderEdit:SetText(d.wander ~= "0.00" and d.wander or "5") end
        local flags = tonumber(d.npcflag) or 0
        for _, c in ipairs(roleChecks) do c:Set(bit.band(flags, c.flag) ~= 0) end
        guardChk:Set(d.guard == "1")
        if not nameEdit:HasFocus() then nameEdit:SetText(d.name) end
        if not subEdit:HasFocus() then subEdit:SetText(d.sub) end
        if not minEdit:HasFocus() then minEdit:SetText(d.minl) end
        if not maxEdit:HasFocus() then maxEdit:SetText(d.maxl) end
        if not dispEdit:HasFocus() then dispEdit:SetText(d.display) end
        if not entryEdit:HasFocus() then entryEdit:SetText(d.entry) end
        uniq.role:Set(tonumber(d.count) and tonumber(d.count) > 1)
        uniq.id:Set(tonumber(d.count) and tonumber(d.count) > 1)
        uniq.adv:Set(tonumber(d.count) and tonumber(d.count) > 1)
        if subs.adv:IsShown() and S.advFor ~= d.guid then S.advFor = d.guid; Send("TGET", d.guid) end
    end
    function p:OnShowPage() Inspector() end
    ShowSub(IlusixnDevMenuDB.sub or "place")
end

-- ================================================================== PATH
do
    local p = pages.path
    local h = Header(p, "为选中的 NPC 录制行走路径")
    h:SetPoint("TOPLEFT", 16, -16)
    local steps = Text(p, 12, C.text)
    steps:SetPoint("TOPLEFT", 16, -44)
    steps:SetWidth(680)
    steps:SetText("1.  选中 NPC（选中 NPC 页）。\n2.  走到它应当经过的每个位置，按“在此添加路径点”（或输入 /dev point），或者开启“每步一点”后直接行走。\n3.  选择循环或往返，然后点“保存路径”。录制时每个点都会有标记。")
    local selText = Text(p, 12, C.accent)
    selText:SetPoint("TOPLEFT", 16, -104)
    local add = Button(p, "在此添加路径点", 180, 40, "accent", function() Send("PADD") end)
    add:SetPoint("TOPLEFT", 16, -130)
    local undo = Button(p, "撤销上一个", 110, 40, nil, function() Send("PUNDO") end)
    undo:SetPoint("LEFT", add, "RIGHT", 8, 0)
    local clr = Button(p, "清空", 90, 40, nil, function() Send("PCLEAR") end)
    clr:SetPoint("LEFT", undo, "RIGHT", 8, 0)
    -- Every step: while on, drops a point every 0.6 s you are moving (about one per stride at walk speed)
    local every, since = false, 0
    local stepF = CreateFrame("Frame")
    stepF:Hide()
    stepF:SetScript("OnUpdate", function(_, e)
        since = since + e
        if since >= 0.6 and GetUnitSpeed("player") > 0 then since = 0; Send("PADD") end
    end)
    local ev
    ev = Button(p, "每步一点", 120, 40, "chip", function()
        every = not every; since = 0
        ev:SetActive(every)
        if every then stepF:Show() else stepF:Hide() end
    end)
    ev:SetPoint("LEFT", clr, "RIGHT", 8, 0)
    local cnt = Text(p, 20, C.text)
    cnt:SetPoint("LEFT", ev, "RIGHT", 20, 0)
    p.cnt = cnt

    local oh = Header(p, "选项")
    oh:SetPoint("TOPLEFT", 16, -196)
    local mode, run = 0, 0
    local modeChips, runChips = {}, {}
    for i, m in ipairs({ { 0, "循环 (A>B>C>A)" }, { 1, "往返" } }) do
        local b = Button(p, m[2], 150, 26, "chip", function()
            mode = m[1]; for _, c in ipairs(modeChips) do c:SetActive(c.v == mode) end
        end)
        b.v = m[1]
        b:SetPoint("TOPLEFT", 16 + (i - 1) * 156, -220)
        b:SetActive(m[1] == 0)
        modeChips[i] = b
    end
    for i, m in ipairs({ { 0, "行走" }, { 1, "奔跑" } }) do
        local b = Button(p, m[2], 80, 26, "chip", function()
            run = m[1]; for _, c in ipairs(runChips) do c:SetActive(c.v == run) end
        end)
        b.v = m[1]
        b:SetPoint("TOPLEFT", 350 + (i - 1) * 86, -220)
        b:SetActive(m[1] == 0)
        runChips[i] = b
    end
    local dl = Text(p, 11, C.dim)
    dl:SetPoint("TOPLEFT", 16, -262)
    dl:SetText("端点等待时间（秒）")
    local de = Edit(p, 60, 24, true)
    de:SetPoint("LEFT", dl, "RIGHT", 8, 0)
    de:SetText("5")

    local save = Button(p, "保存路径到选中 NPC", 230, 36, "accent", function()
        if not S.selected then return Toast("请先选中一个 NPC", "err") end
        Send("PSAVE", S.selected.guid, mode, tonumber(de:GetText()) or 0, run)
    end)
    save:SetPoint("TOPLEFT", 16, -300)
    local eh = Header(p, "现有路径")
    eh:SetPoint("TOPLEFT", 16, -356)
    local function NeedSel(op) if not S.selected then return Toast("请先选中一个 NPC", "err") end; Send(op, S.selected.guid) end
    local show = Button(p, "显示路径", 120, 28, nil, function() NeedSel("PSHOW") end)
    show:SetPoint("TOPLEFT", 16, -380)
    local edit = Button(p, "编辑路径", 120, 28, nil, function() NeedSel("PEDIT") end)
    edit:SetPoint("LEFT", show, "RIGHT", 8, 0)
    Tip(edit, "编辑路径", "把已保存的点载入为当前录制：可撤销/添加点，然后再次保存路径。")
    local del = Button(p, "删除路径", 120, 28, "danger", function() NeedSel("PDEL") end)
    del:SetPoint("LEFT", edit, "RIGHT", 8, 0)
    -- the path map window mirrors these controls (it clicks them and copies their state)
    p.btn = { add = add, undo = undo, clr = clr, ev = ev, loop = modeChips[1], bf = modeChips[2], walk = runChips[1], run = runChips[2],
        save = save, show = show, edit = edit, del = del }
    p.de = de
    function p:OnShowPage()
        selText:SetText(S.selected and ("已选中：" .. S.selected.name .. "  (GUID " .. S.selected.guid .. ")") or "未选中 NPC")
        cnt:SetText(S.pathCount .. " 个点")
    end
end

-- ================================================================== NEARBY
do
    local p = pages.nearby
    local h = Header(p, "你周围已保存的刷新")
    h:SetPoint("TOPLEFT", 16, -16)
    local rl = Text(p, 11, C.dim)
    rl:SetPoint("TOPLEFT", 16, -46)
    rl:SetText("半径")
    local re = Edit(p, 60, 24, true, function() Send("NEAR", tonumber(p.re:GetText()) or 30) end)
    re:SetPoint("LEFT", rl, "RIGHT", 8, 0)
    re:SetText("30")
    p.re = re
    local rb = Button(p, "刷新", 90, 24, "accent", function() Send("NEAR", tonumber(re:GetText()) or 30) end)
    rb:SetPoint("LEFT", re, "RIGHT", 8, 0)
    local hint = Text(p, 10, C.dim)
    hint:SetPoint("LEFT", rb, "RIGHT", 12, 0)
    hint:SetText("点击：选择   双击：打开   Ctrl+点击：3D 预览")
    local list = MakeList(p, 17, 24, { { w = 380 }, { w = 80, color = C.dim, size = 11, right = true }, { w = 110, color = C.dim, size = 11, right = true } },
        function(d, btn, ctrl)
            if btn == "RightButton" then return ShowMenu(d) end
            if ctrl then Preview(d.entry, d.name, "") return end
            Send("SEL", d.guid)
        end)
    list:SetPoint("TOPLEFT", 16, -78)
    list:SetPoint("RIGHT", p, "RIGHT", -16, 0)
    list:SetHeight(17 * 24 + 2)
    list.format = function(d) return { d.name, ("%.1f 码"):format(tonumber(d.dist) or 0), "GUID " .. d.guid } end
    list.isSelected = function(d) return S.selected and S.selected.guid == d.guid end
    list.onDouble = function(d) Send("SEL", d.guid); ShowPage("selected") end
    p.list = list
    function p:OnShowPage() Send("NEAR", tonumber(re:GetText()) or 30) end
end

-- ================================================================== CATEGORIES + RIGHT-CLICK MENU
-- Categories live in IlusixnDevMenuDB.cats (account-wide SavedVariables). cats[1] is Favourites (fixed).
local function Cats()
    IlusixnDevMenuDB.cats = IlusixnDevMenuDB.cats or { { name = "收藏夹", fav = true, items = {} } }
    return IlusixnDevMenuDB.cats
end
local function Slim(d)
    return { entry = tostring(d.entry), name = d.name or "", sub = d.sub or "", minl = d.minl or "?", maxl = d.maxl or "?", react = d.react or "N", display = d.display or "0" }
end
local function InCat(cat, entry) return cat.items[tostring(entry)] ~= nil end
local RefreshCats -- forward

-- ---------------- flat popup menu (supports one submenu level)
local blocker = CreateFrame("Button", nil, UIParent)
blocker:SetAllPoints(UIParent)
blocker:SetFrameStrata("FULLSCREEN")
blocker:RegisterForClicks("AnyUp")
blocker:Hide()
local function NewMenu()
    local m = CreateFrame("Frame", nil, UIParent)
    m:SetFrameStrata("FULLSCREEN_DIALOG")
    Skin(m, C.head, C.accentD)
    m:Hide()
    m.items = {}
    return m
end
local menu, sub = NewMenu(), NewMenu()
local function CloseMenus() menu:Hide(); sub:Hide(); blocker:Hide() end
blocker:SetScript("OnClick", CloseMenus)

local function Fill(m, entries, width)
    for _, it in ipairs(m.items) do it:Hide() end
    local y = -4
    for i, e in ipairs(entries) do
        local it = m.items[i]
        if not it then
            it = CreateFrame("Button", nil, m)
            it:SetHeight(22)
            it.hl = it:CreateTexture(nil, "HIGHLIGHT")
            it.hl:SetAllPoints()
            it.hl:SetTexture(WHITE)
            it.hl:SetVertexColor(1, 0.8, 0.3, 0.12)
            it.t = Text(it, 11)
            it.t:SetPoint("LEFT", 10, 0)
            it.arrow = Text(it, 11, C.dim)
            it.arrow:SetPoint("RIGHT", -8, 0)
            it.arrow:SetText(">")
            it.line = it:CreateTexture(nil, "ARTWORK")
            it.line:SetTexture(WHITE)
            it.line:SetVertexColor(unpack(C.border))
            it.line:SetHeight(1)
            it.line:SetPoint("LEFT", 6, 0)
            it.line:SetPoint("RIGHT", -6, 0)
            m.items[i] = it
        end
        it:ClearAllPoints()
        it:SetPoint("TOPLEFT", 1, y)
        it:SetPoint("TOPRIGHT", -1, y)
        if e.sep then
            it:SetHeight(9); it.t:SetText(""); Shown(it.arrow, false); Shown(it.line, true); it:EnableMouse(false)
            y = y - 9
        else
            it:SetHeight(22); Shown(it.line, false); it:EnableMouse(true)
            it.t:SetText(e.text)
            it.t:SetTextColor(unpack(e.title and C.accent or (e.danger and C.H or (e.disabled and C.dim or C.text))))
            Shown(it.arrow, e.submenu ~= nil)
            it:SetScript("OnClick", function()
                if e.disabled or e.title then return end
                if e.submenu then return end
                CloseMenus()
                if e.func then e.func() end
            end)
            it:SetScript("OnEnter", function()
                if m == menu then
                    if e.submenu then
                        Fill(sub, e.submenu(), 200)
                        sub:ClearAllPoints()
                        sub:SetPoint("TOPLEFT", it, "TOPRIGHT", 2, 4)
                        sub:Show()
                    else
                        sub:Hide()
                    end
                end
            end)
            y = y - 22
        end
        it:Show()
    end
    m:SetSize(width or 220, -y + 4)
end

-- d: npc row data; spawn: true when the row is a placed spawn (has guid)
local Prompt -- forward
function ShowMenu(d)
    local cats = Cats()
    local fav = cats[1]
    local isFav = InCat(fav, d.entry)
    local e = {}
    table.insert(e, { text = (d.name ~= "" and d.name or ("NPC " .. d.entry)) .. "  #" .. d.entry, title = true })
    table.insert(e, { text = "3D 预览", func = function() Preview(d.entry, d.name, d.sub) end })
    table.insert(e, { text = "在此刷新并保存", func = function() Send("SPAWN", d.entry, 1) end })
    table.insert(e, { text = "预览刷新（5 分钟）", func = function() Send("SPAWN", d.entry, 0) end })
    table.insert(e, { sep = true })
    table.insert(e, { text = isFav and "从收藏夹移除" or "加入收藏夹", func = function()
        fav.items[tostring(d.entry)] = (not isFav) and Slim(d) or nil
        Toast(isFav and "已从收藏夹移除" or "已加入收藏夹", "ok")
        RefreshCats()
    end })
    table.insert(e, { text = "保存到分类", submenu = function()
        local s = {}
        for i = 2, #cats do
            local c = cats[i]
            local has = InCat(c, d.entry)
            table.insert(s, { text = (has and "|cff59d973[x]|r  " or "[  ]  ") .. c.name, func = function()
                c.items[tostring(d.entry)] = (not has) and Slim(d) or nil
                Toast((has and "已从 " or "已保存到 ") .. c.name, "ok")
                RefreshCats()
            end })
        end
        if #s > 0 then table.insert(s, { sep = true }) end
        table.insert(s, { text = "+ 新建分类...", func = function()
            Prompt("新分类名称", "", function(name)
                if name == "" then return end
                local c = { name = name, items = {} }
                c.items[tostring(d.entry)] = Slim(d)
                table.insert(cats, c)
                Toast("已保存到新分类 " .. name, "ok")
                RefreshCats()
            end)
        end })
        return s
    end })
    table.insert(e, { sep = true })
    table.insert(e, { text = "复制为新 NPC...", func = function()
        Prompt("新 NPC 的名称（复制自 " .. d.name .. "）", d.name, function(name) Send("DUP", d.entry, name, d.sub or "") end)
    end })
    table.insert(e, { text = "重命名此 NPC 类型...", func = function()
        Prompt("为 #" .. d.entry .. " 的所有刷新设置新名称", d.name, function(name) if name ~= "" then Send("RENAMET", d.entry, name, d.sub or "") end end)
    end })
    table.insert(e, { text = "复制编号到聊天框", func = function()
        ChatFrame_OpenChat(tostring(d.entry))
        Toast("编号已在聊天框中：Ctrl+A、Ctrl+C 复制", "ok")
    end })
    table.insert(e, { text = "把选中刷新变成这个", disabled = (S.selected == nil), func = function() Send("ENTRY", S.selected.guid, d.entry) end })
    if d.guid then
        table.insert(e, { sep = true })
        table.insert(e, { text = "刷新  (GUID " .. d.guid .. ")", title = true })
        table.insert(e, { text = "选择 / 编辑", func = function() Send("SEL", d.guid); ShowPage("selected") end })
        table.insert(e, { text = "传送到那里", func = function() Send("GOTO", d.guid) end })
        table.insert(e, { text = "移动到我这里", func = function() Send("MOVE", d.guid) end })
        table.insert(e, { text = "将此刷新设为唯一", func = function() Send("UNIQUE", d.guid) end })
        table.insert(e, { text = "删除刷新", danger = true, func = function()
            S.selected = S.selected or nil
            StaticPopup_Show("COA_DEVMENU_DELETE_GUID", d.name .. " (GUID " .. d.guid .. ")", nil, d.guid)
        end })
    end
    if d.catIndex then
        table.insert(e, { sep = true })
        table.insert(e, { text = "从此分类移除", danger = true, func = function()
            Cats()[d.catIndex].items[tostring(d.entry)] = nil
            RefreshCats()
        end })
    end
    Fill(menu, e, 230)
    local x, y = GetCursorPosition()
    local sc = UIParent:GetEffectiveScale()
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / sc + 2, y / sc - 2)
    sub:Hide()
    blocker:Show()
    menu:Show()
end
StaticPopupDialogs["COA_DEVMENU_DELETE_GUID"] = {
    text = "要从世界数据库中删除这个刷新吗？\n\n%s",
    button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self, guid) Send("DEL", guid) end,
}

-- one-line text prompt
local function PopupEdit(dialog) return _G[dialog:GetName() .. "EditBox"] end
StaticPopupDialogs["COA_DEVMENU_PROMPT"] = {
    text = "%s", button1 = OKAY, button2 = CANCEL, hasEditBox = 1, maxLetters = 90, timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnShow = function(self) local e = PopupEdit(self); e:SetText((self.data and self.data.default) or ""); e:HighlightText(); e:SetFocus() end,
    OnAccept = function(self, data) data.cb((PopupEdit(self):GetText():gsub("[~|]", ""))) end,
    EditBoxOnEnterPressed = function(self)
        local dialog = self:GetParent()
        if dialog.data then dialog.data.cb((self:GetText():gsub("[~|]", ""))) end
        dialog:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}
function Prompt(label, default, cb)
    StaticPopup_Show("COA_DEVMENU_PROMPT", label, nil, { default = default, cb = cb })
end

-- ---------------- Categories page
do
    local p = pages.cats
    local h = Header(p, "你的分类")
    h:SetPoint("TOPLEFT", 16, -16)
    local catIdx = 1
    local side = Card(p)
    side:SetPoint("TOPLEFT", 16, -40)
    side:SetSize(200, 400)
    local catBtns = {}
    local list = MakeList(p, 15, 24, { { w = 300 }, { w = 70, color = C.dim, size = 11 }, { w = 70, color = C.dim, size = 11, right = true } },
        function(d, btn, ctrl)
            if btn == "RightButton" then return ShowMenu(d) end
            if ctrl then return Preview(d.entry, d.name, d.sub) end
            S.pick = d
            p.list:Refresh()
        end)
    list:SetPoint("TOPLEFT", side, "TOPRIGHT", 10, 0)
    list:SetPoint("RIGHT", p, "RIGHT", -16, 0)
    list:SetHeight(15 * 24 + 2)
    list.format = function(d)
        local lvl = (d.minl == d.maxl) and d.minl or (d.minl .. "-" .. d.maxl)
        return { d.name .. (d.sub ~= "" and ("  |cff8a8f9c<" .. d.sub .. ">|r") or ""), "等级 " .. lvl, "#" .. d.entry }
    end
    list.isSelected = function(d) return S.pick and S.pick.entry == d.entry end
    list.onDouble = function(d) Preview(d.entry, d.name, d.sub) end
    p.list = list
    local emptyT = Text(p, 12, C.dim)
    emptyT:SetPoint("TOP", list, "TOP", 0, -60)
    emptyT:SetWidth(380)
    emptyT:SetJustifyH("CENTER")
    emptyT:SetText("此分类为空。\n\n在“浏览”或“附近刷新”中右键任意 NPC，选择\n“加入收藏夹”或“保存到分类”。")
    local hint = Text(p, 10, C.dim)
    hint:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -8)
    hint:SetText("右键：菜单   Ctrl+点击 / 双击：3D 预览")

    local bNew = Button(p, "+ 新建", 64, 24, "accent", function()
        Prompt("新分类名称", "", function(name)
            if name == "" then return end
            table.insert(Cats(), { name = name, items = {} })
            catIdx = #Cats()
            RefreshCats()
        end)
    end)
    bNew:SetPoint("TOPLEFT", side, "BOTTOMLEFT", 0, -8)
    local bRen = Button(p, "重命名", 64, 24, nil, function()
        local c = Cats()[catIdx]
        if c.fav then return Toast("收藏夹不能重命名", "err") end
        Prompt("重命名分类", c.name, function(name) if name ~= "" then c.name = name; RefreshCats() end end)
    end)
    bRen:SetPoint("LEFT", bNew, "RIGHT", 4, 0)
    local bDel = Button(p, "删除", 64, 24, "danger", function()
        local c = Cats()[catIdx]
        if c.fav then return Toast("收藏夹不能删除", "err") end
        StaticPopup_Show("COA_DEVMENU_DELCAT", c.name, nil, catIdx)
    end)
    bDel:SetPoint("LEFT", bRen, "RIGHT", 4, 0)
    StaticPopupDialogs["COA_DEVMENU_DELCAT"] = {
        text = "要删除分类“%s”吗？\n（NPC 本身不会被删除。）",
        button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
        OnAccept = function(self, idx) table.remove(Cats(), idx); catIdx = 1; RefreshCats() end,
    }

    function RefreshCats()
        local cats = Cats()
        if catIdx > #cats then catIdx = 1 end
        for i, c in ipairs(cats) do
            local b = catBtns[i]
            if not b then
                b = Button(side, "", 186, 26, nil, function() catIdx = i; RefreshCats() end)
                b:SetPoint("TOPLEFT", 7, -7 - (i - 1) * 30)
                b.label:ClearAllPoints()
                b.label:SetPoint("LEFT", 10, 0)
                b.label:SetJustifyH("LEFT")
                b.count = Text(b, 10, C.dim)
                b.count:SetPoint("RIGHT", -8, 0)
                catBtns[i] = b
            end
            local n = 0
            for _ in pairs(c.items) do n = n + 1 end
            b:SetLabel((c.fav and "* " or "") .. c.name)
            b.count:SetText(n)
            b:SetActive(i == catIdx)
            b:Show()
        end
        for i = #cats + 1, #catBtns do catBtns[i]:Hide() end
        local data = {}
        for _, d in pairs(cats[catIdx].items) do
            local r = {}
            for k, v in pairs(d) do r[k] = v end
            r.catIndex = catIdx
            table.insert(data, r)
        end
        table.sort(data, function(a, b) return a.name < b.name end)
        list.data = data
        list.offset = 0
        list:Refresh()
        Shown(emptyT, #data == 0)
    end
    function p:OnShowPage() RefreshCats() end
end

-- ------------------------------------------------------------------ incoming
local H = {}
H.HI = function(a)
    S.ok = true
    subtitle:SetText("已连接   -   GM 等级 " .. (a[2] or "?"))
    subtitle:SetTextColor(unpack(C.good))
end
H.OK = function(a) Toast(a[2] or "完成", "ok") end
H.ER = function(a) Toast(a[2] or "错误", "err") end
H.SB = function(a) S.total = tonumber(a[2]); pages.browse.list:Begin(a[4]); S.results = pages.browse.list.data end
H.SR = function(a)
    table.insert(S.results, { entry = a[2], name = a[3] or "", sub = a[4] or "", minl = a[5], maxl = a[6], react = a[7], npcflag = a[8], rank = a[9], type = a[10], display = a[11] or "0" })
end
H.SE = function() pages.browse:OnResults() end
H.DP = function(a)
    local d = { entry = a[2], name = a[3] or "", sub = a[4] or "", minl = a[5], maxl = a[6], react = a[7], npcflag = a[8], rank = a[9], type = a[10], display = a[11] or "0" }
    table.insert(S.results, 1, d)
    S.pick = d
    local l = pages.browse.list
    l.data = S.results; l.offset = 0; l:Refresh()
    pages.browse:ShowPick()
    Preview(d.entry, d.name, d.sub)
end
H.NB = function() S.near = {} end
H.NR = function(a) table.insert(S.near, { guid = a[2], entry = a[3], name = a[4] or "", sub = "", dist = a[5], react = a[6] }) end
H.NE = function()
    local l = pages.nearby.list
    l.data = S.near; l.offset = 0; l:Refresh()
    Toast("附近有 " .. #S.near .. " 个刷新", "ok")
end
H.IN = function(a)
    S.selected = {
        guid = a[2], entry = a[3], name = a[4] or "", sub = a[5] or "", x = a[6], y = a[7], z = a[8], o = a[9], move = a[10], wander = a[11],
        emote = a[12], npcflag = a[13], faction = a[14], path = a[15], pts = a[16], minl = a[17], maxl = a[18], display = a[19],
        spawntime = a[20], react = a[21], guard = a[22], count = a[23], tplflag = a[24],
    }
    Inspector()
    if pages.path:IsShown() then pages.path:OnShowPage() end
    if pages.nearby:IsShown() then pages.nearby.list:Refresh() end
    if not M:IsShown() then M:Show() end
    if pages.browse:IsShown() then ShowPage("selected") end
end
H.RT = function(a)
    local e, nm, sb = a[2], a[3] or "", a[4] or ""
    for _, d in ipairs(S.results) do if d.entry == e then d.name, d.sub = nm, sb end end
    for _, d in ipairs(S.near) do if d.entry == e then d.name = nm end end
    for _, c in ipairs(IlusixnDevMenuDB.cats or {}) do local d = c.items[e]; if d then d.name, d.sub = nm, sb end end
    if S.selected and S.selected.entry == e then S.selected.name, S.selected.sub = nm, sb; Inspector() end
    pages.browse.list:Refresh(); pages.nearby.list:Refresh()
    if pages.cats:IsShown() then pages.cats:OnShowPage() end
end
H.TB = function() S.adv = {} end
H.TV = function(a) S.adv = S.adv or {}; S.adv[a[2]] = a[3] end
H.RP = function(a) S.adv = S.adv or {}; S.adv.rep = { a[2], a[3], a[4] } end
H.TE = function() if S.RefreshAdvanced then S.RefreshAdvanced() end end
H.DL = function(a)
    if S.selected and S.selected.guid == a[2] then S.selected = nil; Inspector() end
end
H.PP = function(a) S.pathCount = tonumber(a[2]) or 0; pages.path.cnt:SetText(S.pathCount .. " 个点"); Toast(("已添加第 %d 个点"):format(S.pathCount), "ok") end
H.PC = function(a) S.pathCount = tonumber(a[2]) or 0; pages.path.cnt:SetText(S.pathCount .. " 个点") end

CoADev = {
    C = C, WHITE = WHITE, FONT = FONT, Shown = Shown, Skin = Skin, Text = Text, Tip = Tip, Button = Button, Edit = Edit, Check = Check,
    Header = Header, Card = Card, MakeList = MakeList, Send = Send, Toast = Toast, pages = pages, S = S, H = H, M = M,
    Chunks = Utf8Chunks, Cut = CutUtf8,
    Preview = Preview, PreviewModel = PreviewModel, ShowPage = ShowPage,
}

local ev = CreateFrame("Frame")
ev:RegisterEvent("CHAT_MSG_ADDON")
ev:RegisterEvent("PLAYER_TARGET_CHANGED")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(self, e, prefix, msg)
    if e == "ADDON_LOADED" then
        if prefix ~= "DevMenu" then return end
        local pos = IlusixnDevMenuDB.pos
        if pos then M:ClearAllPoints(); M:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) end
        followChk:Set(IlusixnDevMenuDB.follow and true or false)
        sizeSlider:SetValue(IlusixnDevMenuDB.scale or 1); alphaSlider:SetValue(IlusixnDevMenuDB.alpha or 1); ApplyLook()
        return
    end
    if e == "PLAYER_TARGET_CHANGED" then
        if M:IsShown() and IlusixnDevMenuDB.follow and UnitExists("target") and not UnitIsPlayer("target") then Send("SEL", 0) end
        return
    end
    if prefix ~= PFX or not msg or msg:sub(1, 2) == "Q~" then return end
    local a = { strsplit("~", msg) }
    local fn = H[a[1]]
    if fn then fn(a) end
end)

M:SetScript("OnShow", function()
    if not S.ok then Send("HELLO") end
    ShowPage(IlusixnDevMenuDB.page or "browse")
end)

SLASH_COADEVMENU1 = "/dev"
SLASH_COADEVMENU2 = "/devmenu"
SlashCmdList.COADEVMENU = function(arg)
    arg = (arg or ""):lower()
    if arg == "point" or arg == "p" then Send("PADD") return end
    if arg == "undo" then Send("PUNDO") return end
    if arg == "target" or arg == "t" then M:Show(); Send("SEL", 0) return end
    if M:IsShown() then M:Hide() else M:Show() end
end
