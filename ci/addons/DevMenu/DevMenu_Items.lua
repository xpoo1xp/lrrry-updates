-- Dev Menu，第 6 部分：创建物品。从零制作一件物品（外观、类型、属性、价格、法术），在自己身上预览，制作属性随等级成长的传家宝，
-- 并编辑你之前制作的内容。物品位于开发编号段，并可通过“导出 SQL”分享。
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local D = CoADev
local C, Text, Header, Button, Edit, Check, Tip, MakeList, Send, Toast, p, H = D.C, D.Text, D.Header, D.Button, D.Edit, D.Check, D.Tip, D.MakeList, D.Send, D.Toast, D.pages.items, D.H
local Skin, Shown = D.Skin, D.Shown

local QC = { [0] = { 0.6, 0.6, 0.6 }, { 1, 1, 1 }, { 0.12, 1, 0 }, { 0, 0.44, 0.87 }, { 0.64, 0.21, 0.93 }, { 1, 0.5, 0 }, { 0.9, 0.8, 0.5 }, { 0.9, 0.8, 0.5 } }
local scan = CreateFrame("GameTooltip", "CoADevItemMakeScan", UIParent, "GameTooltipTemplate")
scan:SetOwner(UIParent, "ANCHOR_NONE")
local function Fetch(id) if id and id > 0 and not GetItemInfo(id) then scan:SetOwner(UIParent, "ANCHOR_NONE"); scan:SetHyperlink("item:" .. id); scan:Hide() end end

local KINDS = { { "armor", "护甲" }, { "weapon", "武器" }, { "cons", "消耗品" }, { "other", "其它" } }
local QUAL = { { 0, "粗糙" }, { 1, "普通" }, { 2, "优秀" }, { 3, "精良" }, { 4, "史诗" }, { 5, "传说" }, { 7, "传家宝" } }
local BOND = { { 0, "不绑定" }, { 1, "拾取后绑定" }, { 2, "装备后绑定" }, { 3, "使用后绑定" } }
local ASLOT = { { 1, "头部" }, { 3, "肩部" }, { 5, "胸部" }, { 6, "腰部" }, { 7, "腿部" }, { 8, "脚部" }, { 9, "手腕" }, { 10, "手部" }, { 16, "披风" },
    { 4, "衬衣" }, { 19, "战袍" }, { 2, "颈部" }, { 11, "手指" }, { 12, "饰品" }, { 14, "盾牌" }, { 23, "副手物品" } }
local MAT = { { 1, "布甲" }, { 2, "皮甲" }, { 3, "锁甲" }, { 4, "板甲" } }
local WTYPE = { { 7, 13, "单手剑" }, { 8, 17, "双手剑" }, { 0, 13, "单手斧" }, { 1, 17, "双手斧" }, { 4, 13, "单手锤" }, { 5, 17, "双手锤" },
    { 15, 13, "匕首" }, { 13, 13, "拳套" }, { 6, 17, "长柄武器" }, { 10, 17, "法杖" }, { 2, 15, "弓" }, { 3, 26, "枪" }, { 18, 26, "弩" },
    { 19, 26, "魔杖" }, { 16, 25, "投掷武器" } }
local STAT = { { 0, "- 无 -" }, { 7, "耐力" }, { 4, "力量" }, { 3, "敏捷" }, { 5, "智力" }, { 6, "精神" }, { 45, "法术强度" }, { 38, "攻击强度" },
    { 32, "暴击等级" }, { 36, "急速等级" }, { 31, "命中等级" }, { 37, "精准等级" }, { 35, "韧性等级" }, { 12, "防御等级" },
    { 13, "躲闪等级" }, { 14, "招架等级" }, { 15, "格挡等级" }, { 44, "护甲穿透" }, { 43, "每 5 秒法力" }, { 46, "每 5 秒生命" },
    { 1, "生命值" }, { 39, "远程攻击强度" }, { 47, "法术穿透" } }
local TRIG = { { 1, "装备时" }, { 0, "使用时" }, { 2, "命中时几率触发" } }

local cur = { kind = "armor", q = 4, bond = 0, aslot = 1, mat = 4, wtype = 1, trig = 1, bound = false, heir = false }
local edits, cycles = {}, {}

-- ------------------------------------------------------------------ 小工具
local function Lbl(t, x, y) local l = Text(p, 10, C.dim); l:SetPoint("TOPLEFT", x, y); l:SetText(t); return l end
local function Field(key, label, x, y, w, numeric, default)
    Lbl(label, x, y)
    local e = Edit(p, w, 22, numeric)
    e:SetPoint("TOPLEFT", x, y - 12)
    if default then e:SetText(default) end
    edits[key] = e
    return e
end
-- 左键 = 下一个，右键 = 上一个
local function Cycle(key, x, y, w, list, labelOf, onChange)
    local b = Button(p, "", w, 22, nil, nil)
    b:SetPoint("TOPLEFT", x, y)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local function idx() for i, it in ipairs(list) do if it[1] == cur[key] then return i end end return 1 end
    function b:Paint()
        local it = list[idx()]
        self:SetLabel(labelOf and labelOf(it) or it[#it])
        if key == "q" then local c = QC[cur.q] or QC[1]; self.label:SetTextColor(c[1], c[2], c[3]) end
    end
    b:SetScript("OnClick", function(self, btn)
        local i = idx() + (btn == "RightButton" and -1 or 1)
        if i < 1 then i = #list elseif i > #list then i = 1 end
        cur[key] = list[i][1]
        self:Paint()
        if onChange then onChange() end
    end)
    cycles[key] = b
    b:Paint()
    return b
end
local function Num(key, def) local v = tonumber(edits[key] and edits[key]:GetText()); return v or def end

-- ------------------------------------------------------------------ 布局
local h = Header(p, "创建物品"); h:SetPoint("TOPLEFT", 16, -14)
local nameE = Edit(p, 330, 24); nameE:SetPoint("TOPLEFT", 16, -42); nameE:SetPlaceholder("物品名称"); edits.name = nameE

Lbl("类别", 16, -74)
local kindB
local typeB, slotB, matB
local function Layout()
    local k = cur.kind
    if k == "armor" then
        slotB:Show(); matB:Show(); typeB:Hide()
    elseif k == "weapon" then
        slotB:Hide(); matB:Hide(); typeB:Show()
    else
        slotB:Hide(); matB:Hide(); typeB:Hide()
    end
    local armor, weapon = k == "armor", k == "weapon"
    Shown(edits.armor, armor); Shown(edits.blk, armor and cur.aslot == 14)
    for _, key in ipairs({ "dmin", "dmax", "dspd" }) do Shown(edits[key], weapon) end
    for _, l in ipairs(p.labels or {}) do
        if l.only == "armor" then Shown(l, armor) elseif l.only == "weapon" then Shown(l, weapon) end
    end
    if p.updateHeir then p.updateHeir() end
end
kindB = Cycle("kind", 16, -88, 110, KINDS, nil, Layout)
slotB = Cycle("aslot", 132, -88, 130, ASLOT, nil, Layout)
matB = Cycle("mat", 268, -88, 78, MAT)
typeB = Cycle("wtype", 132, -88, 130, WTYPE, function(it) return it[3] end, Layout)
-- 武器类型以索引保存；保存时再映射回 sub/inv
cur.wtype = 7
do
    local b = typeB
    local list = WTYPE
    b:SetScript("OnClick", function(self, btn)
        local i = (cur.widx or 1) + (btn == "RightButton" and -1 or 1)
        if i < 1 then i = #list elseif i > #list then i = 1 end
        cur.widx = i; cur.wtype = list[i][1]
        self:SetLabel(list[i][3])
    end)
    cur.widx = 1; b:SetLabel(list[1][3])
end

p.labels = {}
local function OnlyLbl(t, x, y, only) local l = Lbl(t, x, y); l.only = only; table.insert(p.labels, l); return l end

Lbl("品质", 16, -118); Cycle("q", 16, -132, 110, QUAL)
Lbl("绑定方式", 132, -118); Cycle("bond", 132, -132, 130, BOND)
Field("ilvl", "物品等级", 268, -118, 78, true, "60")
Field("rlvl", "需求等级", 16, -160, 78, true, "1")
OnlyLbl("护甲", 100, -160, "armor"); local ae = Edit(p, 78, 22, true); ae:SetPoint("TOPLEFT", 100, -172); ae:SetText("0"); edits.armor = ae
OnlyLbl("格挡", 184, -160, "armor"); local be = Edit(p, 78, 22, true); be:SetPoint("TOPLEFT", 184, -172); be:SetText("0"); edits.blk = be
OnlyLbl("最小伤害", 100, -160, "weapon"); local dn = Edit(p, 78, 22, true); dn:SetPoint("TOPLEFT", 100, -172); dn:SetText("10"); edits.dmin = dn
OnlyLbl("最大伤害", 184, -160, "weapon"); local dx = Edit(p, 78, 22, true); dx:SetPoint("TOPLEFT", 184, -172); dx:SetText("20"); edits.dmax = dx
OnlyLbl("速度（秒）", 268, -160, "weapon"); local ds = Edit(p, 78, 22); ds:SetPoint("TOPLEFT", 268, -172); ds:SetText("2.0"); edits.dspd = ds
Field("sell", "出售价格（金币）", 16, -202, 78, false, "0")
Field("buy", "购买价格（金币）", 100, -202, 78, false, "0")
Field("stack", "堆叠数量", 184, -202, 78, true, "1")
Field("dur", "耐久度", 268, -202, 78, true, "0")

Lbl("属性（点击属性切换，右键返回上一项）", 16, -236)
local statB, statE = {}, {}
for i = 1, 6 do
    local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
    local x, y = 16 + col * 176, -250 - row * 26
    cur["st" .. i] = 0
    statB[i] = Cycle("st" .. i, x, y, 112, STAT)
    local e = Edit(p, 54, 22, false); e:SetPoint("TOPLEFT", x + 116, y); e:SetText("0"); statE[i] = e
end

local spLbl = Lbl("法术（点击“查找”按名称搜索）", 16, -334)
local spE = Edit(p, 78, 22, true); spE:SetPoint("TOPLEFT", 16, -346); edits.sp = spE
Cycle("trig", 100, -346, 130, TRIG)
function p.updateSpell()
    local id = tonumber(spE:GetText())
    if id and id > 0 then spLbl:SetText("法术：" .. (GetSpellInfo(id) or ("编号 " .. id))) else spLbl:SetText("法术（点击“查找”按名称搜索）") end
end
spE:HookScript("OnTextChanged", function() p.updateSpell() end)

-- 法术选择器（覆盖表单）：按名称搜索，点击即用
local spp = CreateFrame("Frame", nil, p)
Skin(spp, { 0.05, 0.055, 0.07, 0.98 }, C.border)
spp:SetPoint("TOPLEFT", 16, -42); spp:SetSize(698, 470); spp:SetFrameLevel(p:GetFrameLevel() + 30); spp:Hide()
local sph = Header(spp, "查找法术（点击即可用于物品）"); sph:SetPoint("TOPLEFT", 12, -12)
local spS = Edit(spp, 300, 24); spS:SetPoint("TOPLEFT", 12, -40); spS:SetPlaceholder("法术名称或编号（回车）")
local spTotal, spWait = 0, false
local spList
local function SpRun() spList:Search(function(pg) spWait = true; Send("SPSEARCH", spS:GetText(), pg) end) end
spS:SetScript("OnEnterPressed", function(self) self:ClearFocus(); SpRun() end)
local spGo = Button(spp, "搜索", 80, 24, "accent", function() SpRun() end); spGo:SetPoint("LEFT", spS, "RIGHT", 8, 0)
spList = MakeList(spp, 15, 22, { { w = 70, color = C.dim }, { w = 400 }, { w = 100, color = C.dim, right = true } }, function(d)
    spE:SetText(tostring(d.id)); spp:Hide(); p.updateSpell()
end)
spList:SetPoint("TOPLEFT", 12, -74); spList:SetSize(672, 340)
spList.format = function(d) return { tostring(d.id), d.name, d.cast > 0 and (d.cast / 1000 .. " 秒施法") or "瞬发" } end
spList.data = {}
local spPg = Text(spp, 10, C.dim); spPg:SetPoint("TOPLEFT", 12, -424)
local spX = Button(spp, "关闭", 80, 24, nil, function() spp:Hide() end); spX:SetPoint("BOTTOMRIGHT", -12, 12)
local spNone = Button(spp, "不要法术", 90, 24, "danger", function() spE:SetText(""); spp:Hide(); p.updateSpell() end); spNone:SetPoint("RIGHT", spX, "LEFT", -8, 0)
local oSPB, oSP, oSPE = H.SPB, H.SP, H.SPE
H.SPB = function(a) if spWait then spList:Begin(1) elseif oSPB then oSPB(a) end end
H.SP = function(a) if spWait then table.insert(spList.data, { id = tonumber(a[2]), name = a[3] or "", cast = tonumber(a[4]) or 0 }) elseif oSP then oSP(a) end end
H.SPE = function(a)
    if spWait then
        spWait = false; spTotal = tonumber(a[2]) or 0; spList.pages = math.ceil(spTotal / 30); spList:Done()
        spPg:SetText(spTotal .. " 个法术（滚动加载更多）")
    elseif oSPE then oSPE(a) end
end
local spFind = Button(p, "查找", 62, 22, nil, function() spp:Show(); if #spList.data == 0 then SpRun() end end)
spFind:SetPoint("TOPLEFT", 236, -346)
Tip(spFind, "查找法术", "按名称搜索服务器上的所有法术，并为物品选择一个。")
Lbl("描述", 16, -376); local descE = Edit(p, 330, 22); descE:SetPoint("TOPLEFT", 16, -390); edits.desc = descE
local boundC = Check(p, "账号绑定", function(v) cur.bound = v end); boundC:SetPoint("TOPLEFT", 306, -350)

-- ------------------------------------------------------------------ 传家宝
local hh = Text(p, 12, C.accent); hh:SetPoint("TOPLEFT", 16, -422); hh:SetText("传家宝")
local heirC = Check(p, "属性随等级成长", function(v) cur.heir = v; if p.updateHeir then p.updateHeir() end end)
heirC:SetPoint("LEFT", hh, "RIGHT", 12, 0)
Tip(heirC, "传家宝", "制作传家宝：品质 7，账号绑定。你可以选择每项属性每级增加多少点（支持小数，0.5 = 每 2 级 1 点）。装备时加成会按你的等级实时生效，直到最高等级。提示描述中会写明。")
local hrows = {}
for i = 1, 3 do
    cur["hs" .. i] = 0
    local x, y = 16 + (i - 1) * 118, -442
    local b = Cycle("hs" .. i, x, y, 112, STAT)
    local e = Edit(p, 54, 22, false); e:SetPoint("TOPLEFT", x, y - 26); e:SetText("0")
    local t = Text(p, 10, C.dim); t:SetPoint("LEFT", e, "RIGHT", 6, 0); t:SetText("每级")
    hrows[i] = { b = b, e = e, t = t }
end
local hmaxL = Lbl("最高等级", 372 - 14, -448)
local hmax = Edit(p, 50, 22, true); hmax:SetPoint("TOPLEFT", 358, -464); hmax:SetText("80"); edits.hmax = hmax
local hpreview = Text(p, 10, C.text); hpreview:SetPoint("TOPLEFT", 16, -498); hpreview:SetWidth(400); hpreview:SetJustifyH("LEFT")
function p.updateHeir()
    local on = cur.heir
    for _, r in ipairs(hrows) do Shown(r.b, on); Shown(r.e, on); Shown(r.t, on) end
    Shown(hmax, on); Shown(hmaxL, on); Shown(hpreview, on)
    if on then
        local lv = UnitLevel("player")
        local parts = {}
        for i, r in ipairs(hrows) do
            local per = tonumber(r.e:GetText()) or 0
            local st = cur["hs" .. i]
            if per > 0 and (st ~= 0 or i == 1) then
                for _, s in ipairs(STAT) do if s[1] == st then table.insert(parts, ("+%d %s"):format(math.floor(per * math.min(lv, tonumber(hmax:GetText()) or 80)), s[2])) end end
            end
        end
        hpreview:SetText(#parts > 0 and ("你当前等级（" .. lv .. "）：" .. table.concat(parts, "，")) or "选择一项属性以及它每级增加多少。")
    end
end
for _, r in ipairs(hrows) do r.e:SetScript("OnTextChanged", function() p.updateHeir() end) end
hmax:SetScript("OnTextChanged", function() p.updateHeir() end)

-- ------------------------------------------------------------------ 外观（右侧）
local lookH = Header(p, "外观"); lookH:SetPoint("TOPLEFT", 372 + 70, -14)
local dispE = Edit(p, 70, 22, true); dispE:SetPoint("TOPLEFT", 372 + 70, -42); edits.disp = dispE; dispE:SetPlaceholder("模型编号")
local lookName = Text(p, 10, C.dim); lookName:SetPoint("LEFT", dispE, "RIGHT", 8, 0); lookName:SetWidth(120); lookName:SetJustifyH("LEFT"); lookName:SetText("或在下方选择物品")
local lookIcon = p:CreateTexture(nil, "ARTWORK"); lookIcon:SetSize(34, 34); lookIcon:SetPoint("TOPRIGHT", p, "TOPRIGHT", -20, -36)
lookIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark"); lookIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
local lookIconL = Text(p, 9, C.dim); lookIconL:SetPoint("TOP", lookIcon, "BOTTOM", 0, -1); lookIconL:SetText("图标")
local function IconOf(id)
    if not id or id <= 0 then return nil end
    local tex = select(10, GetItemInfo(id))
    if not tex then Fetch(id) end
    return tex
end
-- 列表行中的图标（放在行右侧）；客户端加载物品期间会刷新几次
local iconLists = {}
local iconPoll = CreateFrame("Frame"); iconPoll:Hide()
iconPoll:SetScript("OnUpdate", function(self, el)
    self.t = (self.t or 0) + el
    if self.t < 0.7 then return end
    self.t = 0; self.n = (self.n or 0) + 1
    for _, L in ipairs(iconLists) do if L:IsVisible() then L:Refresh() end end
    if self.n >= 5 then self:Hide() end
end)
local function RowIcons(L, getId, x, extra)
    local orig = L.Refresh
    iconLists[#iconLists + 1] = L
    L.Refresh = function(self)
        orig(self)
        for i, r in ipairs(self.rows) do
            if not r.ic then
                r.ic = r:CreateTexture(nil, "OVERLAY"); r.ic:SetSize(18, 18); r.ic:SetPoint("RIGHT", x, 0); r.ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
            local d = self.data[self.offset + i]
            local tex = d and IconOf(getId(d))
            r.ic:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
            Shown(r.ic, d ~= nil)
            if extra then extra(r, d) end
        end
        iconPoll.n = 0; iconPoll:Show()
    end
end
local model = CreateFrame("DressUpModel", nil, p)
model:SetPoint("TOPLEFT", 372 + 70, -72); model:SetSize(250, 168)
local mbg = p:CreateTexture(nil, "BACKGROUND", nil, 1)
mbg:SetTexture(D.WHITE); mbg:SetPoint("TOPLEFT", model); mbg:SetPoint("BOTTOMRIGHT", model)
mbg:SetGradientAlpha("VERTICAL", 0.02, 0.02, 0.03, 1, 0.12, 0.12, 0.16, 1)
local facing, drag, dragX = 0, false, 0
model:EnableMouse(true)
model:SetScript("OnMouseDown", function() drag = true; dragX = GetCursorPosition() end)
model:SetScript("OnMouseUp", function() drag = false end)
model:SetScript("OnUpdate", function(self) if drag then local x = GetCursorPosition(); facing = facing + (x - dragX) * 0.02; dragX = x; self:SetFacing(facing) end end)
local lookItem
local function DressLook()
    model:SetUnit("player"); model:Undress()
    if lookItem then model:TryOn("item:" .. lookItem) end
    model:SetFacing(facing)
end
p.DressLook = DressLook

local srch = Edit(p, 190, 22); srch:SetPoint("TOPLEFT", 372 + 70, -282); srch:SetPlaceholder("搜索物品外观")
local results, spage, spages = {}, 0, 1
local function SlotIndex()
    local k = cur.kind
    if k == "armor" then
        local m = { [1] = 0, [3] = 1, [4] = 2, [5] = 3, [6] = 4, [7] = 5, [8] = 6, [9] = 7, [10] = 8, [16] = 9, [19] = 10, [14] = 12, [23] = 12 }
        return m[cur.aslot] or 14
    elseif k == "weapon" then
        local inv = 13
        for _, w in ipairs(WTYPE) do if w[1] == cur.wtype then inv = w[2] end end
        return (inv == 15 or inv == 26 or inv == 25) and 13 or 11
    end
    return 14
end
local list = MakeList(p, 8, 22, { { w = 150 }, { w = 40, color = C.dim, right = true } }, function(d)
    lookItem = d.id; dispE:SetText(tostring(d.disp)); lookName:SetText(d.name)
    lookIcon:SetTexture(IconOf(d.id) or "Interface\\Icons\\INV_Misc_QuestionMark")
    Fetch(d.id); DressLook()
end)
list:SetPoint("TOPLEFT", 372 + 70, -312); list:SetSize(250, 180)
list.format = function(d) return { d.name, tostring(d.id):sub(1, 6) } end
RowIcons(list, function(d) return d.id end, -4)
list.data = {}
local iconMode   -- 列表显示使用该图标的物品时，这里是图标名
local waiting = false
local function Run()
    list:Search(function(pg)
        waiting = true
        if iconMode then Send("ICONSEARCH", iconMode, pg) else Send("ISEARCH", srch:GetText(), SlotIndex(), pg, "", 1, 1) end
    end)
end
srch:SetScript("OnEnterPressed", function(self) self:ClearFocus(); iconMode = nil; Run() end)
dispE:SetScript("OnEnterPressed", function(self) self:ClearFocus(); lookItem = nil; lookName:SetText("模型 " .. self:GetText()) end)

-- 外观搜索与衣柜共享回复：只在本页发起请求时接收
local oldIB, oldIR, oldIE = H.IB, H.IR, H.IE
H.IB = function(a) if waiting then list:Begin(a[4]) elseif oldIB then oldIB(a) end end
H.IR = function(a)
    if waiting then Fetch(tonumber(a[2])); table.insert(list.data, { id = tonumber(a[2]), name = a[3] or "", q = tonumber(a[4]) or 1, disp = tonumber(a[5]) or 0 })
    elseif oldIR then oldIR(a) end
end
H.IE = function(a)
    if waiting then waiting = false; list:Done() elseif oldIE then oldIE(a) end
end

-- ------------------------------------------------------------------ 组装请求、保存、列表
local function Gold(v) return math.floor((tonumber(v) or 0) * 10000 + 0.5) end
local function Clean(s) return (tostring(s or ""):gsub("[;=~|\t\n]", " ")) end
local function Spec()
    local k, t = cur.kind, {}
    local function put(key, v) table.insert(t, key .. "=" .. tostring(v)) end
    put("id", cur.id or 0); put("name", Clean(nameE:GetText())); put("desc", Clean(descE:GetText()))
    put("q", cur.heir and 7 or cur.q); put("bond", cur.bond); put("ilvl", Num("ilvl", 1)); put("rlvl", Num("rlvl", 0))
    put("sell", Gold(edits.sell:GetText())); put("buy", Gold(edits.buy:GetText())); put("stack", Num("stack", 1)); put("dur", Num("dur", 0))
    put("disp", Num("disp", 0)); put("bound", (cur.bound or cur.heir) and 1 or 0)
    if k == "armor" then
        put("cls", 4); put("inv", cur.aslot)
        local sub = ({ [1] = cur.mat, [3] = cur.mat, [5] = cur.mat, [6] = cur.mat, [7] = cur.mat, [8] = cur.mat, [9] = cur.mat, [10] = cur.mat, [16] = 1, [14] = 6 })[cur.aslot] or 0
        put("sub", sub); put("armor", Num("armor", 0)); put("blk", Num("blk", 0))
    elseif k == "weapon" then
        local w = WTYPE[cur.widx or 1]
        put("cls", 2); put("sub", w[1]); put("inv", w[2])
        put("dmin", Num("dmin", 1)); put("dmax", Num("dmax", 2)); put("dspd", math.floor((tonumber(edits.dspd:GetText()) or 2) * 1000 + 0.5)); put("sheath", w[2] == 17 and 1 or 3)
    elseif k == "cons" then
        put("cls", 0); put("sub", 0); put("inv", 0)
    else
        put("cls", 15); put("sub", 0); put("inv", 0)
    end
    local n = 0
    for i = 1, 6 do
        local st, v = cur["st" .. i], tonumber(statE[i]:GetText()) or 0
        if st ~= 0 and v ~= 0 then n = n + 1; put("s" .. n, st .. ":" .. math.floor(v)) end
    end
    if Num("sp", 0) > 0 then put("sp", Num("sp", 0)); put("spt", cur.trig) end
    if cur.heir then
        local hv = {}
        for i, r in ipairs(hrows) do
            local per, st = tonumber(r.e:GetText()) or 0, cur["hs" .. i]
            if per > 0 and st ~= 0 then table.insert(hv, st .. ":" .. per) end
        end
        put("hv", table.concat(hv, ",")); put("hmax", Num("hmax", 80))
    end
    return table.concat(t, ";")
end
local function Chunked(s)
    Send("BUFC")
    for _, part in ipairs(D.Chunks(s, 180)) do Send("BUF", part) end
end

local saveB
local function Reset()
    cur.id = nil
    nameE:SetText(""); descE:SetText(""); spE:SetText("")
    for _, k in ipairs({ "sell", "buy", "dur" }) do edits[k]:SetText("0") end
    for i = 1, 6 do cur["st" .. i] = 0; statE[i]:SetText("0"); statB[i]:Paint() end
    for i = 1, 3 do cur["hs" .. i] = 0; hrows[i].e:SetText("0"); hrows[i].b:Paint() end
    cur.heir = false; heirC:Set(false); cur.bound = false; boundC:Set(false)
    lookItem = nil; dispE:SetText(""); lookName:SetText("或在下方选择物品"); lookIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark"); DressLook(); p.updateSpell()
    saveB:SetLabel("创建物品"); Layout()
end
saveB = Button(p, "创建物品", 130, 30, "accent", function()
    if nameE:GetText() == "" then return Toast("请先给物品起名", "err") end
    Chunked(Spec()); Send("IMAKE")
end)
saveB:SetPoint("TOPLEFT", 16, -526)
local newB = Button(p, "新物品", 90, 30, nil, Reset); newB:SetPoint("LEFT", saveB, "RIGHT", 8, 0)
local giveB = Button(p, "给我一个", 110, 30, nil, function() if cur.id then Send("IGIVE", cur.id, 1) else Toast("请先创建物品", "err") end end)
giveB:SetPoint("LEFT", newB, "RIGHT", 8, 0)
Tip(giveB, "给我一个", "把物品放入你的背包，以便试穿并查看提示。传家宝加成在装备时生效。")
local myB
local idText = Text(p, 10, C.dim); idText:SetPoint("LEFT", giveB, "RIGHT", 10, 0)

-- 我的物品（编辑你制作的内容）
local mine = CreateFrame("Frame", nil, p)
Skin(mine, { 0.05, 0.055, 0.07, 0.98 }, C.border)
mine:SetPoint("TOPLEFT", 16, -42); mine:SetSize(698, 470); mine:SetFrameLevel(p:GetFrameLevel() + 20); mine:Hide()
local mh = Header(mine, "已创建的物品（点击一行进行编辑）"); mh:SetPoint("TOPLEFT", 12, -12)
local mlist = MakeList(mine, 16, 22, { { w = 70, color = C.dim }, { w = 330 }, { w = 90, color = C.dim } }, function(d)
    mine:Hide(); Send("IGET", d.id)
end)
mlist:SetPoint("TOPLEFT", 12, -66); mlist:SetSize(672, 340)
mlist.format = function(d) return { tostring(d.id), d.name, ({ [0] = "粗糙", "普通", "优秀", "精良", "史诗", "传说", "神器", "传家宝" })[d.q] or "" } end
mlist.data = {}
local function Favs() IlusixnDevMenuDB.itemFavs = IlusixnDevMenuDB.itemFavs or {}; return IlusixnDevMenuDB.itemFavs end
mlist.isSelected = function(d) return mlist.sel == d.id end
for i, r in ipairs(mlist.rows) do
    r:HookScript("OnClick", function() local d = mlist.data[mlist.offset + i]; if d then mlist.sel = d.id; mlist:Refresh() end end)
    local give = Button(r, "给予", 44, 18, "accent", function() local d = mlist.data[mlist.offset + i]; if d then Send("IGIVE", d.id, 1) end end)
    give:SetPoint("RIGHT", -6, 0)
    Tip(give, "给我一个", "把一件放入你的背包。")
    local star = Button(r, "收藏", 34, 18, nil, function()
        local d = mlist.data[mlist.offset + i]
        if d then Favs()[d.id] = (not Favs()[d.id]) or nil; mlist:Rebuild() end
    end)
    star:SetPoint("RIGHT", give, "LEFT", -4, 0)
    r.star = star
end
RowIcons(mlist, function(d) return d.id end, -126, function(r, d)
    if d and r.star then r.star.label:SetText(Favs()[d.id] and "|cffffc840收藏|r" or "|cff777777收藏|r") end
end)
local mdel = Button(mine, "删除选中物品", 180, 26, "danger", function()
    if mlist.sel then Send("IDEL", mlist.sel); Send("ILIST") end
end)
mdel:SetPoint("BOTTOMLEFT", 12, 12)
local mclose = Button(mine, "关闭", 80, 26, nil, function() mine:Hide() end); mclose:SetPoint("BOTTOMRIGHT", -12, 12)
local favOnly = false
local favC = Check(mine, "仅显示收藏", function(v) favOnly = v; mlist:Rebuild() end)
favC:SetPoint("TOPLEFT", 12, -42)
local mrows = {}
function mlist:Rebuild()
    local out = {}
    for _, d in ipairs(mrows) do if not favOnly or Favs()[d.id] then out[#out + 1] = d end end
    table.sort(out, function(a, b)
        local fa, fb = Favs()[a.id] and 1 or 0, Favs()[b.id] and 1 or 0
        if fa ~= fb then return fa > fb end
        return a.id > b.id
    end)
    self.data = out; self.offset = 0; self:Refresh()
end
H.ILB = function() mrows = {} end
H.ILR = function(a) table.insert(mrows, { id = tonumber(a[2]), name = a[3] or "", q = tonumber(a[4]) or 1, disp = tonumber(a[5]) or 0 }) end
H.ILE = function() mlist:Rebuild() end
H.IDL = function() Send("ILIST") end
myB = Button(p, "我的物品", 110, 24, nil, function() Send("ILIST"); mine:Show() end)
myB:SetPoint("TOPRIGHT", -14, -10)

-- 编辑：服务器会把每个字段发回来
local loading
H.IGK = function(a)
    loading = loading or {}
    loading[a[2]] = a[3] or ""
end
H.IGE = function()
    local m = loading or {}; loading = nil
    local function N(k, d) return tonumber(m[k]) or d end
    Reset()
    cur.id = N("id", nil)
    nameE:SetText(m.name or ""); descE:SetText(m.desc or "")
    local cls = N("cls", 4)
    cur.kind = cls == 4 and "armor" or cls == 2 and "weapon" or cls == 0 and "cons" or "other"
    cur.q = N("q", 4); cur.bond = N("bond", 0); cur.aslot = N("inv", 1); cur.mat = N("sub", 4)
    if cur.kind == "armor" and cur.aslot == 14 then cur.mat = 4 end
    if cur.kind == "weapon" then
        for i, w in ipairs(WTYPE) do if w[1] == N("sub", 7) then cur.widx = i; cur.wtype = w[1] end end
        typeB:SetLabel(WTYPE[cur.widx or 1][3])
    end
    for _, k in ipairs({ "kind", "q", "bond", "aslot", "mat" }) do if cycles[k] then cycles[k]:Paint() end end
    edits.ilvl:SetText(N("ilvl", 1)); edits.rlvl:SetText(N("rlvl", 0)); edits.armor:SetText(N("armor", 0)); edits.blk:SetText(N("blk", 0))
    edits.dmin:SetText(N("dmin", 0)); edits.dmax:SetText(N("dmax", 0)); edits.dspd:SetText(N("dspd", 2000) / 1000)
    edits.sell:SetText(N("sell", 0) / 10000); edits.buy:SetText(N("buy", 0) / 10000); edits.stack:SetText(N("stack", 1)); edits.dur:SetText(N("dur", 0))
    edits.disp:SetText(N("disp", 0)); lookItem = nil; lookName:SetText("模型 " .. N("disp", 0))
    edits.sp:SetText(N("sp", 0) > 0 and N("sp", 0) or ""); p.updateSpell(); cur.trig = N("spt", 1); if cycles.trig then cycles.trig:Paint() end
    cur.bound = N("bound", 0) == 1; boundC:Set(cur.bound)
    for i = 1, 6 do
        local s = m["s" .. i]
        if s then local t, v = s:match("(%d+):(-?%d+)"); cur["st" .. i] = tonumber(t); statE[i]:SetText(v) end
        statB[i]:Paint()
    end
    cur.heir = m.hv ~= nil and m.hv ~= ""
    heirC:Set(cur.heir)
    if cur.heir then
        local i = 0
        for part in m.hv:gmatch("[^,]+") do
            i = i + 1
            local t, per = part:match("(%d+):([%d%.]+)")
            if hrows[i] then cur["hs" .. i] = tonumber(t); hrows[i].e:SetText(per); hrows[i].b:Paint() end
        end
        edits.hmax:SetText(N("hmax", 80))
    end
    saveB:SetLabel("保存修改"); idText:SetText("正在编辑物品 " .. tostring(cur.id))
    Layout(); DressLook()
end
H.IMK = function(a)
    cur.id = tonumber(a[2]); Fetch(cur.id)
    if mine:IsShown() then Send("ILIST") end
    saveB:SetLabel("保存修改"); idText:SetText("物品 " .. a[2])
    model:SetUnit("player"); model:Undress(); if cur.id then model:TryOn("item:" .. cur.id) end
end

local note = Text(p, 10, C.dim); note:SetPoint("TOPLEFT", 16, -566); note:SetWidth(690); note:SetJustifyH("LEFT")
note:SetText("物品会立即保存并在游戏中立即显示。外观需要一个存在于游戏文件中的模型。之后可在“我的物品”中编辑。")

function p:OnShowPage() Layout(); DressLook(); p.updateHeir(); if #list.data == 0 and not list.loading then Run() end end
p:SetScript("OnShow", function() DressLook() end)
Layout()

-- ------------------------------------------------------------------ 自定义图标（类似宏图标窗口）
local icp = CreateFrame("Frame", nil, p)
Skin(icp, { 0.05, 0.055, 0.07, 0.99 }, C.border)
icp:SetPoint("TOPLEFT", 16, -42); icp:SetSize(698, 500); icp:SetFrameLevel(p:GetFrameLevel() + 40); icp:Hide()
local ich = Header(icp, "选择图标（类似宏图标窗口）"); ich:SetPoint("TOPLEFT", 12, -12)
local icons = {}
local function LoadIcons()
    if #icons > 0 then return end
    icons[1] = "INV_MISC_QUESTIONMARK"
    local function Add(n) if n then n = tostring(n):match("[^\\/]*$"); icons[#icons + 1] = n end end
    -- 优先使用 3.3.5 API（数量 + 信息）；后续客户端的填表 API 作为后备
    if GetNumMacroIcons and GetMacroIconInfo then for i = 1, GetNumMacroIcons() do Add(GetMacroIconInfo(i)) end end
    if GetNumMacroItemIcons and GetMacroItemIconInfo then for i = 1, GetNumMacroItemIcons() do Add(GetMacroItemIconInfo(i)) end end
    if #icons < 10 then
        local t = {}
        if GetMacroIcons then pcall(GetMacroIcons, t) end
        if GetMacroItemIcons then pcall(GetMacroItemIcons, t) end
        for _, n in ipairs(t) do Add(n) end
    end
end
local COLS, ROWS, CELL = 14, 9, 44
local icOff, icCells = 0, {}
local icSlider
local function IcRefresh()
    for i, b in ipairs(icCells) do
        local name = icons[icOff * COLS + i]
        b.name = name
        Shown(b, name ~= nil)
        if name then b.tex:SetTexture("Interface\\Icons\\" .. name) end
    end
end
for i = 1, COLS * ROWS do
    local b = CreateFrame("Button", nil, icp)
    b:SetSize(40, 40); b:SetPoint("TOPLEFT", 14 + ((i - 1) % COLS) * CELL, -44 - math.floor((i - 1) / COLS) * CELL)
    Skin(b, { 0.03, 0.035, 0.045, 1 }, C.border)
    b.tex = b:CreateTexture(nil, "ARTWORK"); b.tex:SetPoint("TOPLEFT", 2, -2); b.tex:SetPoint("BOTTOMRIGHT", -2, 2); b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(C.accent)); icLabel = self.name end)
    b:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.border)) end)
    b:SetScript("OnClick", function(self)
        if not self.name then return end
        iconMode = self.name; icp:Hide()
        lookName:SetText("图标 " .. self.name)
        lookIcon:SetTexture("Interface\\Icons\\" .. self.name)
        Run()
    end)
    icCells[i] = b
end
icSlider = CreateFrame("Slider", nil, icp)
icSlider:SetOrientation("VERTICAL"); icSlider:SetSize(12, ROWS * CELL - 4); icSlider:SetPoint("TOPRIGHT", -12, -44)
Skin(icSlider, { 0.03, 0.035, 0.045, 1 }, C.border)
icSlider:SetThumbTexture(D.WHITE); icSlider:GetThumbTexture():SetVertexColor(unpack(C.accent)); icSlider:GetThumbTexture():SetSize(12, 24)
icSlider:SetValueStep(1)
icSlider:SetScript("OnValueChanged", function(self, v) icOff = math.floor(v + 0.5); IcRefresh() end)
icp:EnableMouseWheel(true)
icp:SetScript("OnMouseWheel", function(self, d) icSlider:SetValue(math.max(0, math.min(select(2, icSlider:GetMinMaxValues()), icOff - d * 2))) end)
local icNote = Text(icp, 10, C.dim); icNote:SetPoint("TOPLEFT", 14, -454); icNote:SetWidth(660); icNote:SetJustifyH("LEFT")
icNote:SetText("点击一个图标：列表会显示使用它的物品。选择一个，你的新物品就会获得该外观和图标。完全自由的新图标需要修改客户端数据，因为游戏会从物品外观中取图标。")
local icX = Button(icp, "关闭", 80, 24, nil, function() icp:Hide() end); icX:SetPoint("BOTTOMRIGHT", -12, 12)
icp:SetScript("OnShow", function()
    LoadIcons()
    icSlider:SetMinMaxValues(0, math.max(0, math.ceil(#icons / COLS) - ROWS)); icSlider:SetValue(0); icOff = 0; IcRefresh()
end)
local icB = Button(p, "自定义图标", 250, 22, nil, function() icp:Show() end)
icB:SetPoint("TOPLEFT", 372 + 70, -250)
Tip(icB, "自定义图标", "打开图标窗口：选择任意游戏图标并查看哪些物品使用它，然后取用它的外观。")
