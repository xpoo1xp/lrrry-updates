-- Dev Menu，第 5 部分：选中 NPC 的“战斗”页（自动攻击 + 战斗时施放的法术，通过 SmartAI 行实现）
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local D = CoADev
local C, Text, Tip, Button, Edit, Header, MakeList, Send, Toast, S, H = D.C, D.Text, D.Tip, D.Button, D.Edit, D.Header, D.MakeList, D.Send, D.Toast, D.S, D.H
local f = S.subs.combat
local function G() return S.selected and S.selected.guid end
local function Lbl(t, x, y) local l = Text(f, 10, C.dim); l:SetPoint("TOPLEFT", x, y); l:SetText(t); return l end

local cur = {}   -- 最近一次 CB 回复：最小值、最大值、速度、倍率

-- ---- 自动攻击
Header(f, "自动攻击"):SetPoint("TOPLEFT", 14, -12)
local now = Text(f, 11, C.text); now:SetPoint("TOPLEFT", 14, -32); now:SetWidth(700)
Lbl("每次命中伤害（平均）", 14, -54); local eDmg = Edit(f, 90, 24, true); eDmg:SetPoint("TOPLEFT", 14, -68)
Lbl("攻击速度（秒）", 150, -54); local eSpd = Edit(f, 70, 24); eSpd:SetPoint("TOPLEFT", 150, -68)
Lbl("伤害倍率", 270, -54); local eMod = Edit(f, 70, 24); eMod:SetPoint("TOPLEFT", 270, -68)
local bApply = Button(f, "应用", 90, 24, "accent", function()
    if not G() or not cur.mod then return end
    local mod = tonumber(eMod:GetText()) or cur.mod
    local want = tonumber(eDmg:GetText())
    local avg = (cur.min + cur.max) / 2
    if want and avg > 0 and math.abs(want - avg) >= 1 then mod = cur.mod * want / avg end   -- 伤害 = 等级基础值 × 倍率
    if math.abs(mod - cur.mod) > 0.001 then Send("TSET", G(), "damage", string.format("%.3f", mod), 0) end
    local spd = tonumber(eSpd:GetText())
    if spd and spd > 0 and math.floor(spd * 1000 + 0.5) ~= cur.speed then Send("TSET", G(), "attacktime", math.floor(spd * 1000 + 0.5), 0) end
    Send("CGET", G())
end)
bApply:SetPoint("TOPLEFT", 360, -68)
Tip(bApply, "应用", "输入你希望每次命中的伤害：倍率会自动计算。保存在 NPC 类型上（该类型的所有刷新共享）。若只想改一个刷新，请先在“身份”页点击“立即将此刷新设为唯一”。")

-- ---- 施放的法术
Header(f, "战斗法术"):SetPoint("TOPLEFT", 14, -106)
local aiNote = Text(f, 10, C.dim); aiNote:SetPoint("TOPLEFT", 150, -110); aiNote:SetWidth(560)
local TGT = { [2] = "当前目标", [1] = "自身", [5] = "随机敌人" }
local mine
mine = MakeList(f, 5, 22, { { w = 50, color = C.dim }, { w = 230 }, { w = 150, size = 10 }, { w = 110, size = 10 }, { w = 60, size = 10 } }, function(d) f.selRow = d; mine:Refresh() end)
mine:SetPoint("TOPLEFT", 14, -126); mine:SetPoint("TOPRIGHT", -14, -126); mine:SetHeight(112)
mine.format = function(d)
    local every = (d.rmin / 1000) .. (d.rmax ~= d.rmin and ("-" .. d.rmax / 1000) or "")
    return { d.spell, d.name, "每 " .. every .. " 秒，首次 " .. d.first / 1000 .. " 秒", "目标：" .. (TGT[d.tgt] or d.tgt), d.chance .. "%" }
end
mine.isSelected = function(d) return d == f.selRow end
local bDel = Button(f, "移除选中", 130, 22, "danger", function()
    if not f.selRow or not G() then return Toast("请先在列表中点击一个法术", "err") end
    Send("CDEL", G(), f.selRow.id); f.selRow = nil
end)
bDel:SetPoint("TOPRIGHT", mine, "BOTTOMRIGHT", 0, -4)

-- ---- 添加法术：搜索服务器上的所有法术，或复制另一个 NPC 的法术
Lbl("查找法术：名称或编号，或输入  npc:<编号>  查看另一个生物施放的法术", 14, -246)
local eFind = Edit(f, 300, 24); eFind:SetPoint("TOPLEFT", 14, -260); eFind:SetPlaceholder("例如 火球术、133、npc:448  （回车）")
local page, total = 0, 0
local found
found = MakeList(f, 6, 20, { { w = 55, color = C.dim }, { w = 250 }, { w = 70, size = 10 }, { w = 50, size = 10 } }, function(d) f.pick = d; found:Refresh() end)
found:SetPoint("TOPLEFT", 14, -290); found:SetSize(450, 124)
found.format = function(d) return { d.id, d.name, d.cast == 0 and "瞬发" or (d.cast / 1000 .. " 秒施法"), d.range .. " 码" } end
found.isSelected = function(d) return d == f.pick end
local pageTxt = Text(f, 10, C.dim); pageTxt:SetPoint("TOPLEFT", found, "BOTTOMLEFT", 0, -6)
local function Search(pg) page = pg or 0; found.data = {}; found.offset = 0; f.pick = nil; Send("SPSEARCH", eFind:GetText(), page) end
eFind:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Search(0) end)
local bPrev = Button(f, "<", 24, 20, nil, function() if page > 0 then Search(page - 1) end end); bPrev:SetPoint("TOPRIGHT", found, "BOTTOMRIGHT", -28, -2)
local bNext = Button(f, ">", 24, 20, nil, function() if (page + 1) * 30 < total then Search(page + 1) end end); bNext:SetPoint("LEFT", bPrev, "RIGHT", 4, 0)

local x0 = 480
Lbl("首次施放延迟（秒）", x0, -290); local eFirst = Edit(f, 60, 22); eFirst:SetPoint("TOPLEFT", x0, -304); eFirst:SetText("3")
Lbl("重复间隔（秒）：最小 / 最大", x0, -330); local eMin = Edit(f, 50, 22); eMin:SetPoint("TOPLEFT", x0, -344); eMin:SetText("10")
local eMax = Edit(f, 50, 22); eMax:SetPoint("LEFT", eMin, "RIGHT", 6, 0); eMax:SetText("15")
Lbl("几率 %", x0 + 130, -330); local eCh = Edit(f, 50, 22, true); eCh:SetPoint("TOPLEFT", x0 + 130, -344); eCh:SetText("100")
local tgt = 2
local tBtn
tBtn = Button(f, "施放目标：当前目标", 200, 22, nil, function()
    tgt = tgt == 2 and 1 or tgt == 1 and 5 or 2
    tBtn:SetText("施放目标：" .. TGT[tgt])
end)
tBtn:SetPoint("TOPLEFT", x0, -372)
local bAdd = Button(f, "加入 NPC", 200, 26, "accent", function()
    if not G() then return end
    if not f.pick then return Toast("请先搜索并点击一个法术", "err") end
    local function ms(e, d) return math.floor((tonumber(e:GetText()) or d) * 1000 + 0.5) end
    Send("CADD", G(), f.pick.id, ms(eFirst, 3), ms(eMin, 10), ms(eMax, 15), tgt, tonumber(eCh:GetText()) or 100)
end)
bAdd:SetPoint("TOPLEFT", x0, -400)
Tip(bAdd, "加入 NPC", "该类型的所有 NPC 在战斗时都会施放它，无论敌对还是友好。附近属于该 NPC 类型的每个副本都会立即切换（正在战斗的会在战斗结束后切换）。")

-- ---- 回复
H.SPB = function() found.data = {} end
H.SP = function(a) found.data[#found.data + 1] = { id = a[2], name = a[3], cast = tonumber(a[4]) or 0, range = a[5] }; found:Refresh() end
H.SPE = function(a)
    total = tonumber(a[2]) or 0
    found:Refresh()
    pageTxt:SetText(total == 0 and "未找到法术" or ("第 " .. (page + 1) .. " / " .. math.ceil(total / 30) .. " 页  （共 " .. total .. " 个法术）"))
end
H.CB = function(a)
    cur = { min = tonumber(a[3]) or 0, max = tonumber(a[4]) or 0, speed = tonumber(a[5]) or 2000, mod = tonumber(a[6]) or 1 }
    mine.data = {}; mine.offset = 0; f.selRow = nil
    now:SetText(string.format("当前：每次命中 %d - %d 伤害，每 %.1f 秒一击  （每秒 %.0f 伤害）",
        cur.min, cur.max, cur.speed / 1000, (cur.min + cur.max) / 2 / math.max(0.1, cur.speed / 1000)))
    if not eDmg:HasFocus() then eDmg:SetText(math.floor((cur.min + cur.max) / 2)) end
    if not eSpd:HasFocus() then eSpd:SetText(string.format("%.1f", cur.speed / 1000)) end
    if not eMod:HasFocus() then eMod:SetText(string.format("%.2f", cur.mod)) end
    aiNote:SetText(tonumber(a[7]) == 2 and "|cffff9040此 NPC 类型带有 C++ 脚本：添加法术会把它切换为 SmartAI。|r" or "")
end
H.CS = function(a)
    mine.data[#mine.data + 1] = { id = a[2], spell = a[3], name = a[4], rmin = tonumber(a[5]) or 0, rmax = tonumber(a[6]) or 0, first = tonumber(a[7]) or 0, tgt = tonumber(a[8]) or 2, chance = a[9] }
    mine:Refresh()
end
H.CE = function() mine:Refresh() end

-- 打开标签页或选择变化时重新加载
local seen
f:HookScript("OnShow", function() seen = nil end)
f:HookScript("OnUpdate", function() if G() and G() ~= seen then seen = G(); Send("CGET", seen) end end)
