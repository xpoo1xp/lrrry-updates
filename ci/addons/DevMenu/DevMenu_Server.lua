-- Dev Menu，第 8 部分：变形（变成任意模型，带预览）与服务器（时间、天气、地点、事件及其它世界工具）
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local D = CoADev
local C, Text, Header, Button, Edit, Check, Tip, MakeList, Send, Toast, H, Shown = D.C, D.Text, D.Header, D.Button, D.Edit, D.Check, D.Tip, D.MakeList, D.Send, D.Toast, D.H, D.Shown

-- ====================================================================== 变形
do
    local p = D.pages.morph
    Header(p, "变成任意模型"):SetPoint("TOPLEFT", 16, -14)
    local search = Edit(p, 240, 24); search:SetPoint("TOPLEFT", 16, -42); search:SetPlaceholder("生物名称或模型编号（回车）")
    local list
    local function Run() list:Search(function(pg) Send("MORSEARCH", search:GetText(), pg) end) end
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Run() end)
    local go = Button(p, "搜索", 70, 24, "accent", function() Run() end); go:SetPoint("LEFT", search, "RIGHT", 8, 0)

    local model = CreateFrame("DressUpModel", nil, p)
    model:SetPoint("TOPLEFT", 400, -42); model:SetSize(300, 360)
    local bg = p:CreateTexture(nil, "BACKGROUND", nil, 1)
    bg:SetTexture(D.WHITE); bg:SetPoint("TOPLEFT", model); bg:SetPoint("BOTTOMRIGHT", model)
    bg:SetGradientAlpha("VERTICAL", 0.02, 0.02, 0.03, 1, 0.12, 0.12, 0.16, 1)
    local facing, drag, dragX = 0, false, 0
    model:EnableMouse(true); model:EnableMouseWheel(true)
    local zoom = 0
    model:SetScript("OnMouseDown", function() drag = true; dragX = GetCursorPosition() end)
    model:SetScript("OnMouseUp", function() drag = false end)
    model:SetScript("OnMouseWheel", function(self, d) zoom = math.max(-2, math.min(4, zoom + d * 0.4)); self:SetPosition(zoom, 0, 0) end)
    model:SetScript("OnUpdate", function(self) if drag then local x = GetCursorPosition(); facing = facing + (x - dragX) * 0.02; dragX = x; self:SetFacing(facing) end end)

    local sel = { id = nil, name = "", entry = nil }
    local previewing, keep = false, false   -- 点击一行会先把你变成它以便预览；离开时恢复，除非按了“应用”
    local info = Text(p, 11, C.text); info:SetPoint("TOPLEFT", 400, -410); info:SetWidth(300); info:SetJustifyH("LEFT")
    local tries = 0
    local retry = CreateFrame("Frame"); retry:Hide()
    local Show3D
    retry:SetScript("OnUpdate", function(self, el)
        self.t = (self.t or 0) + el
        if self.t < 0.4 then return end
        self.t = 0; tries = tries + 1
        if sel.entry and p:IsShown() then model:SetCreature(sel.entry); model:SetFacing(facing); model:SetPosition(zoom, 0, 0) end
        if tries >= 6 then self:Hide() end
    end)
    function Show3D()
        -- 服务器会把你变形，并发送一个使用该模型的生物数据；面板绘制这个生物
        if sel.entry and sel.entry > 0 then
            model:SetCreature(sel.entry); tries = 0; retry:Show()
        else
            model:ClearModel()
        end
        model:SetFacing(facing); model:SetPosition(zoom, 0, 0)
        local what = sel.id and ("模型 " .. sel.id .. (sel.name ~= "" and ("   " .. sel.name) or "")) or "在列表中选择一个模型"
        if sel.id and not (sel.entry and sel.entry > 0) then what = what .. "\n（没有生物使用此模型，因此这里没有图像：请查看你的角色）" end
        info:SetText(what .. (previewing and not keep and "\n|cffffc840预览状态：离开时会恢复正常，除非你点击“应用”。|r" or ""))
    end
    local function Preview(id)
        previewing = true; keep = false
        Send("MORPH", id)
    end
    local function Revert()
        if previewing and not keep then Send("MORPH", 0) end
        previewing = false
    end

    list = MakeList(p, 14, 22, { { w = 56, color = C.dim, right = true }, { w = 260 } }, function(d)
        sel = { id = d.id, name = d.name }; Preview(d.id)
    end)
    list:SetPoint("TOPLEFT", 16, -76); list:SetSize(372, 312)
    list.format = function(d) return { tostring(d.id), d.name } end
    list.isSelected = function(d) return sel.id == d.id end
    list.data = {}
    for i, r in ipairs(list.rows) do r:HookScript("OnClick", function() list:Refresh() end) end
    local pager = Text(p, 10, C.dim); pager:SetPoint("TOPLEFT", 16, -396)

    local me = Button(p, "应用（保持此形态）", 190, 30, "accent", function()
        if not sel.id then return Toast("请先点击一个模型", "err") end
        keep = true; previewing = false; Show3D(); Toast("该形态会保持，直到点击“恢复正常”或登出", "ok")
    end)
    me:SetPoint("TOPLEFT", 16, -430)
    Tip(me, "应用", "点击模型会先把你变成它以便查看。如果未点“应用”就离开此页或关闭菜单，你会恢复自己的模型。")
    local back = Button(p, "恢复正常", 130, 30, "danger", function() keep = false; previewing = false; Send("MORPH", 0) end); back:SetPoint("LEFT", me, "RIGHT", 8, 0)

    Header(p, "遍历所有模型编号"):SetPoint("TOPLEFT", 16, -478)
    local idE = Edit(p, 80, 24, true); idE:SetPoint("TOPLEFT", 16, -504); idE:SetPlaceholder("模型编号")
    local goId = Button(p, "预览", 70, 24, "accent", function() local id = tonumber(idE:GetText()) or 0; sel = { id = id, name = "" }; Preview(id) end); goId:SetPoint("LEFT", idE, "RIGHT", 6, 0)
    local function Step(dir) previewing = true; keep = false; Send("MORSTEP", tonumber(idE:GetText()) or sel.id or 1, dir) end
    local prev = Button(p, "< 上一个模型", 120, 24, nil, function() Step(-1) end); prev:SetPoint("LEFT", goId, "RIGHT", 14, 0)
    local nxt = Button(p, "下一个模型 >", 110, 24, nil, function() Step(1) end); nxt:SetPoint("LEFT", prev, "RIGHT", 6, 0)
    local tip = Text(p, 10, C.dim); tip:SetPoint("TOPLEFT", 16, -536); tip:SetWidth(690); tip:SetJustifyH("LEFT")
    tip:SetText("“上一个 / 下一个”会让你变成相邻的有效模型，从而可以逐个浏览。喜欢哪个就点“应用”保留。")

    local redraw = CreateFrame("Frame"); redraw:Hide()
    redraw:SetScript("OnUpdate", function(self, el) self.t = (self.t or 0) + el; if self.t > 0.4 then self:Hide(); self.t = 0; Show3D() end end)
    H.MORN = function(a)
        local id = tonumber(a[2]) or 0
        if id > 0 then idE:SetText(tostring(id)); sel.id = id; sel.entry = tonumber(a[3]); if not sel.name then sel.name = "" end end
        redraw:Show()
    end
    H.MORB = function(a) list:Begin(a[4]) end
    H.MORR = function(a) table.insert(list.data, { id = tonumber(a[2]), name = a[3] or "" }) end
    H.MORE = function(a)
        list:Done()
        pager:SetText((a[2] or "0") .. " 个模型（滚动加载更多）")
    end
    p:HookScript("OnHide", Revert)
    D.M:HookScript("OnHide", Revert)
    function p:OnShowPage() if #list.data == 0 then Run() end; Show3D() end
end

-- ====================================================================== 服务器
do
    local p = D.pages.server
    Header(p, "时间"):SetPoint("TOPLEFT", 16, -14)
    local speed = 1
    local speedChips = {}
    local function SetTime(h, m) Send("SRV", "time", h, m, speed) end
    local TIMES = { { "黎明", 5, 30 }, { "早晨", 9, 0 }, { "正午", 12, 0 }, { "黄昏", 18, 30 }, { "夜晚", 22, 0 }, { "午夜", 0, 0 } }
    for i, t in ipairs(TIMES) do
        local b = Button(p, t[1], 54, 24, "chip", function() SetTime(t[2], t[3]) end)
        b:SetPoint("TOPLEFT", 16 + (i - 1) * 58, -40)
    end
    local hE = Edit(p, 36, 24, true); hE:SetPoint("TOPLEFT", 16, -72); hE:SetText("12")
    local mE = Edit(p, 36, 24, true); mE:SetPoint("LEFT", hE, "RIGHT", 4, 0); mE:SetText("00")
    local tb = Button(p, "设置时间", 80, 24, "accent", function() SetTime(tonumber(hE:GetText()) or 12, tonumber(mE:GetText()) or 0) end); tb:SetPoint("LEFT", mE, "RIGHT", 8, 0)
    for i, s in ipairs({ { 1, "正常" }, { 0, "冻结" }, { 10, "10 倍速" } }) do
        local b = Button(p, s[2], 56, 24, "chip", function()
            speed = s[1]
            for _, c in ipairs(speedChips) do c:SetActive(c.v == speed) end
            Toast("已选择时钟速度：" .. s[2] .. "。请点击一个时间以应用。", "ok")
        end)
        b.v = s[1]; b:SetPoint("LEFT", tb, "RIGHT", 8 + (i - 1) * 60, 0); speedChips[i] = b
    end
    speedChips[1]:SetActive(true)
    local tnote = Text(p, 10, C.dim); tnote:SetPoint("TOPLEFT", 16, -102); tnote:SetWidth(330); tnote:SetJustifyH("LEFT")
    tnote:SetText("为所有在线玩家设置时钟。“冻结”会保持你设置的时间。玩家登录后其时钟会恢复为真实时间。")

    Header(p, "天气"):SetPoint("TOPLEFT", 16, -138)
    local grade = 0.6
    local gradeChips = {}
    for i, g in ipairs({ { 0.3, "小" }, { 0.6, "中" }, { 1, "大" } }) do
        local b = Button(p, g[2], 60, 22, "chip", function()
            grade = g[1]; for _, c in ipairs(gradeChips) do c:SetActive(c.v == grade) end
        end)
        b.v = g[1]; b:SetPoint("TOPLEFT", 16 + (i - 1) * 64, -164); gradeChips[i] = b
    end
    gradeChips[2]:SetActive(true)
    for i, w in ipairs({ { 0, "晴朗" }, { 1, "下雨" }, { 2, "下雪" }, { 3, "沙尘暴" } }) do
        local b = Button(p, w[2], 76, 26, nil, function() Send("SRV", "weather", w[1], w[1] == 0 and 0 or grade) end)
        b:SetPoint("TOPLEFT", 16 + (i - 1) * 80, -192)
    end
    local wnote = Text(p, 10, C.dim); wnote:SetPoint("TOPLEFT", 16, -224); wnote:SetWidth(330); wnote:SetJustifyH("LEFT")
    wnote:SetText("更改你所在区域的天气。请先选择强度。")

    Header(p, "玩家"):SetPoint("TOPLEFT", 16, -258)
    local nameE = Edit(p, 130, 24); nameE:SetPoint("TOPLEFT", 16, -284); nameE:SetPlaceholder("玩家名称")
    local ap = Button(p, "传送到对方", 90, 24, nil, function() Send("SRV", "appear", nameE:GetText()) end); ap:SetPoint("LEFT", nameE, "RIGHT", 6, 0)
    local su = Button(p, "把对方拉过来", 90, 24, nil, function() Send("SRV", "summon", nameE:GetText()) end); su:SetPoint("LEFT", ap, "RIGHT", 6, 0)

    Header(p, "公告"):SetPoint("TOPLEFT", 16, -324)
    local annE = Edit(p, 250, 24); annE:SetPoint("TOPLEFT", 16, -350); annE:SetPlaceholder("发送给全服的消息")
    local annB = Button(p, "发送", 70, 24, "accent", function() Send("SRV", "announce", annE:GetText()) end); annB:SetPoint("LEFT", annE, "RIGHT", 6, 0)

    Header(p, "服务器"):SetPoint("TOPLEFT", 16, -390)
    local sinfo = Text(p, 11, C.text); sinfo:SetPoint("TOPLEFT", 16, -416); sinfo:SetText("")
    local ib = Button(p, "刷新", 70, 22, nil, function() Send("SRV", "info") end); ib:SetPoint("TOPLEFT", 16, -438)
    local sv = Button(p, "保存所有玩家", 120, 22, nil, function() Send("SRV", "saveall") end); sv:SetPoint("LEFT", ib, "RIGHT", 6, 0)
    local rl = Text(p, 10, C.dim); rl:SetPoint("TOPLEFT", 16, -472); rl:SetText("在数据库中修改表之后重新加载")
    local RELOAD = { "creature_template", "gameobject_template", "npc_vendor", "smart_scripts", "gossip_menu", "creature_text", "quest_template", "conditions", "game_tele", "loot_templates" }
    local cx, cy = 16, -490
    for _, n in ipairs(RELOAD) do
        local b = Button(p, n, 10, 22, "chip", function() Send("SRV", "reload", n) end)
        b:SetWidth(math.max(40, b.label:GetStringWidth() + 14))
        if cx + b:GetWidth() > 350 then cx = 16; cy = cy - 26 end
        b:SetPoint("TOPLEFT", cx, cy); cx = cx + b:GetWidth() + 4
    end

    -- 右侧：地点与事件
    local RX = 372
    local mode = "places"
    local search = Edit(p, 200, 24); search:SetPoint("TOPLEFT", RX, -42); search:SetPlaceholder("搜索（回车）")
    local chipP = Button(p, "地点", 70, 24, "chip", nil); chipP:SetPoint("TOPLEFT", RX, -14)
    local chipE = Button(p, "事件", 70, 24, "chip", nil); chipE:SetPoint("LEFT", chipP, "RIGHT", 6, 0)
    local list
    list = MakeList(p, 14, 22, { { w = 226 }, { w = 74, color = C.dim, right = true } }, function(d)
        if mode == "places" then Send("SRV", "tele", d.id)
        else Send("SRV", "event", d.active and "stop" or "start", d.id); d.active = not d.active; list:Refresh() end
    end)
    list:SetPoint("TOPLEFT", RX, -76); list:SetSize(342, 312)
    list.format = function(d)
        if mode == "places" then return { d.name, "地图 " .. d.map } end
        return { d.name, d.active and "开启" or "关闭" }
    end
    list.data = {}
    local pager = Text(p, 10, C.dim); pager:SetPoint("TOPLEFT", RX, -400)
    local function Run()
        list:Search(function(pg)
            if mode == "places" then Send("SRVTELE", search:GetText(), pg) else Send("SRVEV", search:GetText(), pg) end
        end)
    end
    local function SetMode(m)
        mode = m; list.data = {}; list:Refresh()
        chipP:SetActive(m == "places"); chipE:SetActive(m == "events")
        pager:SetText(""); Run()
    end
    chipP:SetScript("OnClick", function() SetMode("places") end)
    chipE:SetScript("OnClick", function() SetMode("events") end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Run() end)
    local help = Text(p, 10, C.dim); help:SetPoint("TOPLEFT", RX, -428); help:SetWidth(342); help:SetJustifyH("LEFT")
    help:SetText("地点：点击即可传送（使用 game_tele 表，因此所有 .tele 名称都可用）。\n事件：点击可开启或关闭节日与世界事件。")
    local function Rows(a, isEv)
        return { id = tonumber(a[2]), name = a[3] or "", map = a[4], active = a[4] == "1" }
    end
    H.TLB = function(a) list:Begin(a[4]) end
    H.TLR = function(a) table.insert(list.data, Rows(a)) end
    H.TLE = function(a) if mode ~= "places" then return end list:Done(); pager:SetText((a[2] or "0") .. " 个地点（滚动加载更多）") end
    H.EVB = function(a) list:Begin(a[4]) end
    H.EVR = function(a) table.insert(list.data, Rows(a, true)) end
    H.EVE = function(a) if mode ~= "events" then return end list:Done(); pager:SetText((a[2] or "0") .. " 个事件（滚动加载更多）") end
    H.SI = function(a)
        local s = tonumber(a[3]) or 0
        sinfo:SetText(("%s 名玩家在线   已运行 %d 天 %d 小时 %d 分"):format(a[2] or "?", math.floor(s / 86400), math.floor(s % 86400 / 3600), math.floor(s % 3600 / 60)))
    end
    function p:OnShowPage() Send("SRV", "info"); chipP:SetActive(mode == "places"); chipE:SetActive(mode == "events"); if #list.data == 0 then Run() end end
end
