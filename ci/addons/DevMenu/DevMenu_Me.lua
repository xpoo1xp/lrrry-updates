-- Dev Menu，第 7 部分：你的角色。对自己使用一键 GM 工具：无敌、等级、金币、坐骑、传家宝、套装、飞行点……
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local D = CoADev
local C, Text, Header, Button, Edit, Check, Tip, MakeList, Send, Toast, p, H = D.C, D.Text, D.Header, D.Button, D.Edit, D.Check, D.Tip, D.MakeList, D.Send, D.Toast, D.pages.me, D.H

local function Lbl(t, x, y) local l = Text(p, 10, C.dim); l:SetPoint("TOPLEFT", x, y); l:SetText(t); return l end

-- ------------------------------------------------------------------ 能力开关
Header(p, "能力"):SetPoint("TOPLEFT", 16, -14)
local POWERS = {
    { "god", "无敌模式", "你不会受到伤害，也不会死亡。" },
    { "gm", "GM 模式", "对应 .gm on 状态：GM 标记，可被识别为 GM，免疫大多数效果。" },
    { "cast", "瞬发施法", "所有法术都瞬发。" },
    { "cd", "无冷却", "法术和技能没有冷却。" },
    { "power", "无限资源", "法力、怒气与能量永不枯竭：施法不消耗资源。" },
    { "gmfly", "随处飞行", "无需坐骑即可拥有飞行坐骑速度，所有区域有效。" },
    { "water", "水面行走", "可以在水面上站立和奔跑。" },
    { "taxi", "解锁所有飞行点", "所有飞行管理员节点均已解锁。" },
}
local checks = {}
for i, w in ipairs(POWERS) do
    local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
    local c = Check(p, w[2], function(v) Send("ME", w[1], v and 1 or 0) end)
    c:SetPoint("TOPLEFT", 16 + col * 176, -44 - row * 24)
    Tip(c, w[2], w[3])
    checks[w[1]] = c
end

-- ------------------------------------------------------------------ 快捷操作
Header(p, "快捷操作"):SetPoint("TOPLEFT", 16, -150)
local ACTIONS = {
    { "治疗 / 复活", { "heal" }, "死亡时复活你，并补满生命和法力。" },
    { "清除冷却", { "cooldowns" } },
    { "修理全部装备", { "repair" } },
    { "显示整张地图", { "explore" }, "把所有区域标记为已探索。" },
    { "学习本职业法术", { "learn", "class" }, "你职业的所有训练师法术、天赋和职业任务法术。" },
    { "学习所有坐骑", { "learn", "mounts" }, "服务器有对应物品的所有坐骑。" },
    { "学习所有宠物", { "learn", "pets" }, "服务器有对应物品的所有伙伴宠物。" },
    { "技能满级", { "learn", "skills" }, "武器与专业技能提升到你当前等级的上限。" },
    { "学习语言", { "learn", "lang" } },
}
for i, a in ipairs(ACTIONS) do
    local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
    local b = Button(p, a[1], 164, 26, nil, function() Send("ME", unpack(a[2])) end)
    b:SetPoint("TOPLEFT", 16 + col * 170, -176 - row * 30)
    if a[3] then Tip(b, a[1], a[3]) end
end

-- ------------------------------------------------------------------ 等级
Header(p, "等级"):SetPoint("TOPLEFT", 16, -306)
local lvText = Text(p, 11, C.text); lvText:SetPoint("TOPLEFT", 60, -306); lvText:SetText("")
for i, lv in ipairs({ 1, 10, 20, 30, 40, 50, 60, 70, 80 }) do
    local b = Button(p, tostring(lv), 34, 24, "chip", function() Send("ME", "level", lv) end)
    b:SetPoint("TOPLEFT", 16 + (i - 1) * 38, -330)
end
local lvE = Edit(p, 50, 24, true); lvE:SetPoint("TOPLEFT", 16, -360); lvE:SetText("80")
local lvB = Button(p, "设置等级", 80, 24, "accent", function() Send("ME", "level", tonumber(lvE:GetText()) or 80) end); lvB:SetPoint("LEFT", lvE, "RIGHT", 8, 0)
Tip(lvB, "设置等级", "把你的等级设为 1 到服务器上限之间的任意值。天赋点会重新计算。")

-- ------------------------------------------------------------------ 金币与点数
Header(p, "金币与点数"):SetPoint("TOPLEFT", 16, -398)
local goldText = Text(p, 11, C.text); goldText:SetPoint("TOPLEFT", 190, -398)
local GOLD = { { 1, "+1金" }, { 100, "+100金" }, { 1000, "+1千" }, { 10000, "+1万" }, { 100000, "+10万" } }
for i, g in ipairs(GOLD) do
    local b = Button(p, g[2], 62, 24, "chip", function() Send("ME", "money", g[1]) end)
    b:SetPoint("TOPLEFT", 16 + (i - 1) * 66, -422)
end
local gE = Edit(p, 90, 24, true); gE:SetPoint("TOPLEFT", 16, -452); gE:SetPlaceholder("金币")
local gB = Button(p, "增加金币", 80, 24, "accent", function() Send("ME", "money", tonumber(gE:GetText()) or 0) end); gB:SetPoint("LEFT", gE, "RIGHT", 8, 0)
local gB2 = Button(p, "扣除金币", 80, 24, nil, function() Send("ME", "money", -(tonumber(gE:GetText()) or 0)) end); gB2:SetPoint("LEFT", gB, "RIGHT", 6, 0)
local pts = {
    { "荣誉 +5000", { "honor", 5000 } }, { "竞技场 +500", { "arena", 500 } },
    { "冰霜徽章 x100", { "emblem", "frost", 100 } }, { "凯旋徽章 x100", { "emblem", "triumph", 100 } }, { "征服徽章 x100", { "emblem", "conquest", 100 } },
    { "勇气徽章 x100", { "emblem", "valor", 100 } },
}
for i, a in ipairs(pts) do
    local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
    local b = Button(p, a[1], 108, 24, nil, function() Send("ME", unpack(a[2])) end)
    b:SetPoint("TOPLEFT", 16 + col * 112, -484 - row * 28)
end

-- ------------------------------------------------------------------ 速度与体型
Header(p, "速度与体型"):SetPoint("TOPLEFT", 16, -548)
for i, s in ipairs({ 1, 2, 4, 8, 15 }) do
    local b = Button(p, "x" .. s, 36, 24, "chip", function() Send("ME", "speed", s) end)
    b:SetPoint("TOPLEFT", 16 + (i - 1) * 40, -572)
end
local szl = Text(p, 10, C.dim); szl:SetPoint("TOPLEFT", 216, -578); szl:SetText("体型")
for i, s in ipairs({ 0.5, 1, 2, 4 }) do
    local b = Button(p, tostring(s), 26, 24, "chip", function() Send("ME", "scale", s) end)
    b:SetPoint("TOPLEFT", 240 + (i - 1) * 29, -572)
end

-- ------------------------------------------------------------------ 右侧：传家宝、套装、任意物品
local RX = 372
Header(p, "传家宝"):SetPoint("TOPLEFT", RX, -14)
local hb1 = Button(p, "本职业全套", 160, 28, "accent", function() Send("ME", "heirloom", "class") end); hb1:SetPoint("TOPLEFT", RX, -40)
Tip(hb1, "全套传家宝", "你的职业可用的肩、胸、戒指、饰品和武器。这些是真正的传家宝，会随你的等级成长。")
local hb2 = Button(p, "所有传家宝", 150, 28, nil, function() Send("ME", "heirloom", "all") end); hb2:SetPoint("LEFT", hb1, "RIGHT", 8, 0)

Header(p, "装备套装"):SetPoint("TOPLEFT", RX, -84)
local srch = Edit(p, 190, 24); srch:SetPoint("TOPLEFT", RX, -110); srch:SetPlaceholder("套装名称（回车）")
local mine = Check(p, "仅我的职业", function() end); mine:SetPoint("LEFT", srch, "RIGHT", 10, 0); mine:Set(true)
local sp, lvlSel = 0, 0
local list
local function Run() list:Search(function(pg) Send("MESETS", srch:GetText(), pg, mine.value and 1 or 0, lvlSel) end) end
srch:SetScript("OnEnterPressed", function(self) self:ClearFocus(); sp = 0; Run() end)
mine:SetScript("PostClick", function() sp = 0; Run() end)
local CH = { "Gladiator", "Wrathful", "Relentless", "Furious", "Deadly", "Hateful", "Savage", "Plate", "Battlegear" }
local cx, cy = RX, -140
for i, n in ipairs(CH) do
    local b = Button(p, n, 10, 22, "chip", function() srch:SetText(n); sp = 0; Run() end)
    b:SetWidth(math.max(40, b.label:GetStringWidth() + 14))
    if cx + b:GetWidth() > RX + 340 then cx = RX; cy = cy - 26 end
    b:SetPoint("TOPLEFT", cx, cy)
    cx = cx + b:GetWidth() + 4
end
-- 等级筛选：只显示需求该等级的套装（1 = 1-9 级，10 = 10-19 级……80）
local lvChips = {}
for i, lv in ipairs({ 0, 1, 10, 20, 30, 40, 50, 60, 70, 80 }) do
    local w = lv == 0 and 34 or 29
    local b = Button(p, lv == 0 and "全部" or tostring(lv), w, 22, "chip", function()
        lvlSel = lv; sp = 0
        for _, c in ipairs(lvChips) do c:SetActive(c.v == lvlSel) end
        Run()
    end)
    b.v = lv
    b:SetPoint("TOPLEFT", RX + (i == 1 and 0 or (34 + 4 + (i - 2) * 33)), -194)
    lvChips[i] = b
end
lvChips[1]:SetActive(true)
Tip(lvChips[2], "等级筛选", "只显示装备需求该等级段的套装：1 = 1 到 9 级，10 = 10 到 19 级，依此类推。“全部”表示不筛选。")
list = MakeList(p, 12, 22, { { w = 176 }, { w = 60, color = C.dim, right = true }, { w = 54, color = C.dim, right = true } }, function(d)
    Send("ME", "set", d.id)
end)
list:SetPoint("TOPLEFT", RX, -222); list:SetSize(342, 268)
list.format = function(d) return { d.name, "物品等级 " .. d.ilvl, d.count .. " 件" } end
list.data = {}
Tip(list, "装备套装", "点击一套即可把它的全部部件放入背包。按物品等级排序，最好的在前。")
local pager = Text(p, 10, C.dim); pager:SetPoint("TOPLEFT", RX, -499)

Header(p, "添加任意物品"):SetPoint("TOPLEFT", RX, -530)
local idE = Edit(p, 90, 24, true); idE:SetPoint("TOPLEFT", RX, -556); idE:SetPlaceholder("物品编号")
local nE = Edit(p, 50, 24, true); nE:SetPoint("LEFT", idE, "RIGHT", 6, 0); nE:SetText("1")
local giveB = Button(p, "放入背包", 120, 24, "accent", function() Send("IGIVE", tonumber(idE:GetText()) or 0, tonumber(nE:GetText()) or 1) end)
giveB:SetPoint("LEFT", nE, "RIGHT", 8, 0)

-- ------------------------------------------------------------------ 回复
H.MS = function(a)
    local keys = { "gm", "god", "cast", "cd", "power", "water", "gmchat", "gmfly", "taxi" }
    for i, k in ipairs(keys) do if checks[k] then checks[k]:Set(a[1 + i] == "1") end end
    lvText:SetText("（当前 " .. (a[11] or "?") .. "）")
    goldText:SetText("你有 " .. (a[12] or "?") .. " 金币")
end
H.MSB = function(a) list:Begin(a[4]) end
H.MSR = function(a) table.insert(list.data, { id = tonumber(a[2]), name = a[3] or "", ilvl = a[4] or "0", count = a[5] or "0" }) end
H.MSE = function(a)
    list:Done()
    pager:SetText((a[2] or "0") .. " 套装备（滚动加载更多）")
end

-- ------------------------------------------------------------------ 声望与阵营（覆盖右侧）
local rp = CreateFrame("Frame", nil, p)
D.Skin(rp, { 0.07, 0.075, 0.09, 1 }, { 0.07, 0.075, 0.09, 1 })
rp:SetPoint("TOPLEFT", RX - 8, -4); rp:SetPoint("BOTTOMRIGHT", -4, 4); rp:SetFrameLevel(p:GetFrameLevel() + 10); rp:Hide()
local STAND = { { -42000, "仇恨" }, { 0, "中立" }, { 3000, "友好" }, { 9000, "尊敬" }, { 21000, "崇敬" }, { 42000, "崇拜" } }
local pick = 42000
local pickChips = {}
Header(rp, "阵营"):SetPoint("TOPLEFT", 8, -12)
for i, f in ipairs({ { "alliance", "联盟" }, { "neutral", "中立" }, { "horde", "部落" } }) do
    local b = Button(rp, f[2], 100, 28, i == 1 and "accent" or nil, function() Send("ME", "faction", f[1]) end)
    b:SetPoint("TOPLEFT", 8 + (i - 1) * 106, -38)
    if f[1] == "neutral" then Tip(b, "中立", "登出前对所有人友好（没有人会攻击你）。") else Tip(b, f[2], "把你的角色切换到" .. f[2] .. "阵营（种族、起始区域、声望）。登出到角色选择界面后完成。") end
end
Header(rp, "声望等级"):SetPoint("TOPLEFT", 8, -84)
for i, st in ipairs(STAND) do
    local b = Button(rp, st[2], 52, 24, "chip", function()
        pick = st[1]; for _, c in ipairs(pickChips) do c:SetActive(c.v == pick) end
    end)
    b.v = st[1]; b:SetPoint("TOPLEFT", 8 + (i - 1) * 56, -110); pickChips[i] = b
end
pickChips[6]:SetActive(true)
local allB = Button(rp, "把所有声望设为所选等级", 330, 26, "accent", function() Send("ME", "rep", "all", pick) end)
allB:SetPoint("TOPLEFT", 8, -142)
Header(rp, "单个阵营（点击设置）"):SetPoint("TOPLEFT", 8, -184)
local rs = Edit(rp, 200, 24); rs:SetPoint("TOPLEFT", 8, -210); rs:SetPlaceholder("阵营名称（回车）")
local rlist
local function RRun() rlist:Search(function(pg) Send("REPSEARCH", rs:GetText(), pg) end) end
rs:SetScript("OnEnterPressed", function(self) self:ClearFocus(); RRun() end)
rlist = MakeList(rp, 12, 22, { { w = 230 }, { w = 80, color = C.dim, right = true } }, function(d)
    Send("ME", "rep", "one", pick, d.id); d.st = pick; rlist:Refresh()
end)
rlist:SetPoint("TOPLEFT", 8, -240); rlist:SetSize(342, 270)
rlist.format = function(d) return { d.name, tostring(d.st) } end
rlist.data = {}
local rpager = Text(rp, 10, C.dim); rpager:SetPoint("TOPLEFT", 8, -520)
H.RPB = function(a) rlist:Begin(a[4]) end
H.RPR = function(a) table.insert(rlist.data, { id = tonumber(a[2]), name = a[3] or "", st = tonumber(a[4]) or 0 }) end
H.RPE = function(a)
    rlist:Done()
    rpager:SetText((a[2] or "0") .. " 个阵营（滚动加载更多）")
end
local back = Button(rp, "< 返回", 70, 24, nil, function() rp:Hide() end); back:SetPoint("TOPRIGHT", -10, -10)
local repB = Button(p, "声望 / 阵营", 110, 24, nil, function() rp:Show(); RRun() end)
repB:SetPoint("TOPRIGHT", -14, -10)
Tip(repB, "声望与阵营", "一次性修改所有声望、逐个阵营修改，或切换到联盟、部落、中立。")

-- ------------------------------------------------------------------ 背包预设（保存在插件数据中：本账号的每个角色都能看到）
local bp = CreateFrame("Frame", nil, p)
D.Skin(bp, { 0.07, 0.075, 0.09, 1 }, { 0.07, 0.075, 0.09, 1 })
bp:SetPoint("TOPLEFT", RX - 8, -4); bp:SetPoint("BOTTOMRIGHT", -4, 4); bp:SetFrameLevel(p:GetFrameLevel() + 10); bp:Hide()
local function Bags() IlusixnDevMenuDB.bags = IlusixnDevMenuDB.bags or {}; return IlusixnDevMenuDB.bags end
local scan = CreateFrame("GameTooltip", "CoADevBagScan", UIParent, "GameTooltipTemplate")
scan:SetOwner(UIParent, "ANCHOR_NONE")
local function ItemName(id)
    local n = GetItemInfo(id)
    if not n then scan:SetOwner(UIParent, "ANCHOR_NONE"); scan:SetHyperlink("item:" .. id); scan:Hide() end
    return n or ("物品 " .. id)
end
local curBag, curItem = nil, nil
Header(bp, "背包预设"):SetPoint("TOPLEFT", 8, -12)
local bback = Button(bp, "< 返回", 70, 24, nil, function() bp:Hide() end); bback:SetPoint("TOPRIGHT", -10, -10)
local plist = MakeList(bp, 5, 22, { { w = 240 }, { w = 70, color = C.dim, right = true } }, function(d) curBag = d.bag; curItem = nil; bp:Refresh() end)
plist:SetPoint("TOPLEFT", 8, -40); plist:SetSize(342, 114)
plist.format = function(d) return { d.bag.name, #d.bag.items .. " 件物品" } end
plist.isSelected = function(d) return d.bag == curBag end
local nameE = Edit(bp, 190, 24); nameE:SetPoint("TOPLEFT", 8, -164); nameE:SetPlaceholder("新预设名称")
local newB = Button(bp, "创建", 70, 24, "accent", function()
    local n = nameE:GetText(); if n == "" then return Toast("请先给预设起名", "err") end
    local b = { name = n, items = {} }; table.insert(Bags(), b); curBag = b; nameE:SetText(""); nameE:ClearFocus(); bp:Refresh()
end)
newB:SetPoint("LEFT", nameE, "RIGHT", 6, 0)
local delB = Button(bp, "删除预设", 90, 24, "danger", function()
    if not curBag then return end
    for i, b in ipairs(Bags()) do if b == curBag then table.remove(Bags(), i) break end end
    curBag = nil; bp:Refresh()
end)
delB:SetPoint("LEFT", newB, "RIGHT", 6, 0)
local bh = Header(bp, "所选预设中的物品"); bh:SetPoint("TOPLEFT", 8, -204)
local ilist = MakeList(bp, 9, 22, { { w = 210 }, { w = 62, color = C.dim, right = true }, { w = 36, color = C.dim, right = true } }, function(d) curItem = d; bp:Refresh() end)
ilist:SetPoint("TOPLEFT", 8, -230); ilist:SetSize(342, 204)
ilist.format = function(d) return { ItemName(d.it.id), tostring(d.it.id), "x" .. d.it.n } end
ilist.isSelected = function(d) return d == curItem end
local aid = Edit(bp, 130, 24); aid:SetPoint("TOPLEFT", 8, -444); aid:SetPlaceholder("物品编号或物品链接")
local acount = Edit(bp, 46, 24, true); acount:SetPoint("LEFT", aid, "RIGHT", 6, 0); acount:SetText("1")
local addB = Button(bp, "添加", 56, 24, "accent", function()
    if not curBag then return Toast("请先选择或创建一个预设", "err") end
    local txt = aid:GetText() or ""
    local id = tonumber(txt:match("item:(%d+)") or txt)
    if not id then return Toast("请输入物品编号，或按住 Shift 点击物品链接", "err") end
    for _, it in ipairs(curBag.items) do if it.id == id then it.n = it.n + (tonumber(acount:GetText()) or 1); aid:SetText(""); return bp:Refresh() end end
    table.insert(curBag.items, { id = id, n = tonumber(acount:GetText()) or 1 }); aid:SetText(""); bp:Refresh()
end)
addB:SetPoint("LEFT", acount, "RIGHT", 6, 0)
local rmB = Button(bp, "移除选中", 110, 24, nil, function()
    if not (curBag and curItem) then return end
    for i, it in ipairs(curBag.items) do if it == curItem.it then table.remove(curBag.items, i) break end end
    curItem = nil; bp:Refresh()
end)
rmB:SetPoint("LEFT", addB, "RIGHT", 6, 0)
-- 逐个发放物品（服务器会回复每个请求）
local queue = {}
local qf = CreateFrame("Frame"); qf:Hide()
qf:SetScript("OnUpdate", function(self, el)
    self.t = (self.t or 0) + el
    if self.t < 0.2 then return end
    self.t = 0
    local it = table.remove(queue, 1)
    if it then Send("IGIVE", it.id, it.n) else self:Hide() end
end)
local giveBag = Button(bp, "把这套物品放入我的背包", 342, 30, "accent", function()
    if not curBag or #curBag.items == 0 then return Toast("此预设为空", "err") end
    for _, it in ipairs(curBag.items) do table.insert(queue, it) end
    qf:Show(); Toast(("正在添加 %d 件物品……"):format(#curBag.items), "ok")
end)
giveBag:SetPoint("TOPLEFT", 8, -482)
Tip(giveBag, "把这套物品放入我的背包", "把预设中的每件物品都放入你当前角色的背包。预设随插件保存，因此本账号的任何角色都能使用。")
local bnote = Text(bp, 10, C.dim); bnote:SetPoint("TOPLEFT", 8, -520); bnote:SetWidth(342); bnote:SetJustifyH("LEFT")
bnote:SetText("点击编号输入框，然后按住 Shift 点击物品即可粘贴链接。需要背包有足够空位。")
hooksecurefunc("ChatEdit_InsertLink", function(link) if link and aid:HasFocus() then aid:SetText(link) end end)
function bp:Refresh()
    local d = {}
    for _, b in ipairs(Bags()) do d[#d + 1] = { bag = b } end
    plist.data = d; plist:Refresh()
    local it = {}
    if curBag then for _, x in ipairs(curBag.items) do it[#it + 1] = { it = x } end end
    ilist.data = it; ilist.offset = 0; ilist:Refresh()
    bh:SetText(curBag and ("预设中的物品：" .. curBag.name) or "所选预设中的物品")
end
bp:SetScript("OnShow", function(self) self:Refresh() end)
local bagB = Button(p, "背包预设", 100, 24, nil, function() bp:Show() end)
bagB:SetPoint("TOPRIGHT", -150, -10)
Tip(bagB, "背包预设", "只整理一次物品清单，之后一键把全部物品放入任意角色的背包。")

function p:OnShowPage()
    Send("ME", "state")
    if #list.data == 0 then Run() end
end
