-- Dev Menu，第 5 部分：导出 SQL。菜单的每次修改都会被记录；“导出”会把当前行（先删除再插入）写成一个可重复执行的 .sql 文件，
-- 放在 worldserver 旁边的 devmenu_sql/ 目录中。
-- 汉化：lrrry 2026-11-12
--By lrrry 2026-11-12
--End By lrrry
local D = CoADev
local C, Text, Header, Button, Edit, Card, Tip, Send, Toast, p, H = D.C, D.Text, D.Header, D.Button, D.Edit, D.Card, D.Tip, D.Send, D.Toast, D.pages.share, D.H

local h = Header(p, "把你的成果导出为 SQL"); h:SetPoint("TOPLEFT", 16, -16)
local info = Text(p, 11, C.text); info:SetPoint("TOPLEFT", 16, -42); info:SetWidth(690); info:SetJustifyH("LEFT")
info:SetText("你用菜单做的每次修改都会加入变更集：刷出或删除的 NPC 与物件、路径、外观、名称、商人、训练师、对话菜单、法术、任务。"
    .. "“导出”会把当前这些行写成一个 .sql 文件。任何人都可以在自己的世界数据库中执行它（重复执行也安全），从而看到相同位置上的相同 NPC。")

local cnt = Text(p, 22, C.accent); cnt:SetPoint("TOPLEFT", 16, -104); cnt:SetText("...")
local cntSub = Text(p, 10, C.dim); cntSub:SetPoint("LEFT", cnt, "RIGHT", 10, -2); cntSub:SetText("变更集中已记录的行数")

local ah = Header(p, "加入你以前做的工作（或别人的）"); ah:SetPoint("TOPLEFT", 16, -148)
local rl = Text(p, 11, C.dim); rl:SetPoint("TOPLEFT", 16, -178); rl:SetText("范围")
local re = Edit(p, 60, 24, true); re:SetPoint("LEFT", rl, "RIGHT", 8, 0); re:SetText("150")
local yl = Text(p, 11, C.dim); yl:SetPoint("LEFT", re, "RIGHT", 6, 0); yl:SetText("码以内")
local bArea = Button(p, "添加区域", 110, 26, "accent", function() Send("SQLAREA", tonumber(re:GetText()) or 150) end)
bArea:SetPoint("LEFT", yl, "RIGHT", 10, 0)
Tip(bArea, "添加区域", "把你周围所有已保存的 NPC 和物件连同它们的路径一起加入。用菜单创建的 NPC 类型会带上外观、装备、商店和菜单。")
local bZone = Button(p, "添加我整个区域", 150, 26, nil, function() Send("SQLAREA", 0) end)
bZone:SetPoint("LEFT", bArea, "RIGHT", 8, 0)
local bAll = Button(p, "添加开发者菜单创建的全部内容", 260, 26, nil, function() Send("SQLALL") end)
bAll:SetPoint("TOPLEFT", 16, -212)
Tip(bAll, "开发者菜单创建的全部内容", "菜单编号段内的所有 NPC 类型、物件类型和任务，以及它们的全部刷新。")

local eh = Header(p, "导出"); eh:SetPoint("TOPLEFT", 16, -262)
local nl = Text(p, 11, C.dim); nl:SetPoint("TOPLEFT", 16, -292); nl:SetText("文件名")
local ne = Edit(p, 220, 24); ne:SetPoint("LEFT", nl, "RIGHT", 8, 0); ne:SetText("my_city")
local bExp = Button(p, "导出 SQL", 130, 30, "accent", function() Send("SQLEXP", ne:GetText()) end)
bExp:SetPoint("LEFT", ne, "RIGHT", 10, 0)

local outL = Text(p, 10, C.dim); outL:SetPoint("TOPLEFT", 16, -330); outL:SetText("保存位置（服务器本机路径，点击可全选并 Ctrl+C 复制）：")
local out = Edit(p, 690, 24); out:SetPoint("TOPLEFT", 16, -348)
out:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)

local clr, armed = nil, false
clr = Button(p, "清空变更集", 150, 26, "danger", function()
    if not armed then
        armed = true; clr:SetLabel("再次点击确认清空")
        return Toast("清空只会忘记已记录的内容（不会改变你的世界）。再次点击确认。", "err")
    end
    armed = false; clr:SetLabel("清空变更集"); Send("SQLCLR")
end)
clr:SetPoint("TOPLEFT", 16, -388)
Tip(clr, "清空变更集", "开始一份新的变更集，例如在导出之后。不会改变世界中的任何内容。")

local tips = Text(p, 10, C.dim); tips:SetPoint("TOPLEFT", 16, -426); tips:SetWidth(690); tips:SetJustifyH("LEFT")
tips:SetText("注意事项：\n"
    .. "- 文件使用的是本服务器的编号。目标服务器不应已经占用相同的刷新编号（否则会被覆盖）。\n"
    .. "- 穿衣 NPC 需要目标服务器安装开发者菜单模块，或者对它们进行烘焙：导出后运行“烘焙穿衣 NPC”（会生成 _baked.sql 和客户端补丁）。")

H.SQLN = function(a) cnt:SetText(a[2] or "0") end
H.SQLF = function(a)
    out:SetText(a[2] or ""); out:SetCursorPosition(0)
    Toast(("已导出 %s 行"):format(a[3] or "0"), "ok")
end
function p:OnShowPage()
    armed = false; clr:SetLabel("清空变更集"); Send("SQLN") end
